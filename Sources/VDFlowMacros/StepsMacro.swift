#if canImport(SwiftCompilerPlugin)
import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

@main
struct VDFlowMacrosPlugin: CompilerPlugin {

	let providingMacros: [Macro.Type] = [
		StepsMacro.self,
	]
}

public struct StepsMacro: MemberAttributeMacro, ExtensionMacro, MemberMacro, AccessorMacro {

	public static func expansion(
		of node: AttributeSyntax,
		providingAccessorsOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [AccessorDeclSyntax] {
		guard
			let variable = declaration.as(VariableDeclSyntax.self),
			variable.storedVarName != nil
		else {
			throw MacroError("@Step can only be applied to stored properties")
		}
		return []
	}

	public static func expansion(
		of node: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingAttributesFor member: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [AttributeSyntax] {
		if !declaration.is(StructDeclSyntax.self) {
			return []
		}
		guard let variable = member.as(VariableDeclSyntax.self), let name = variable.storedVarName else { return [] }
		let hasStepVars = declaration.memberBlock.members.contains(where: \.decl.hasStepAttribute)
		guard hasStepVars ? variable.hasStepAttribute : true else { return [] }
		if
			let binding = variable.bindings.first,
			let type = binding.typeAnnotation?.type.trimmed.description,
			binding.initializer == nil,
			type != "EmptyStep",
			!type.isOptional
		{
			throw MacroError("`\(name): \(type)` must have default value or be optional")
		}
		return ["@StepID(.\(raw: name))"]
	}

	public static func expansion(
		of node: AttributeSyntax,
		attachedTo declaration: some DeclGroupSyntax,
		providingExtensionsOf type: some TypeSyntaxProtocol,
		conformingTo protocols: [TypeSyntax],
		in context: some MacroExpansionContext
	) throws -> [ExtensionDeclSyntax] {
		[
			ExtensionDeclSyntax(
				extendedType: type,
				inheritanceClause: InheritanceClauseSyntax(
					inheritedTypes: InheritedTypeListSyntax {
						InheritedTypeSyntax(
							type: TypeSyntax(
								stringLiteral: "StepsCollection"
							)
						)
					}
				),
				memberBlock: MemberBlockSyntax(members: MemberBlockItemListSyntax())
			),
		]
	}

	public static func enumExpansion(
		of node: AttributeSyntax,
		providingMembersOf declaration: some DeclGroupSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		guard declaration.is(EnumDeclSyntax.self) else {
			if declaration.is(StructDeclSyntax.self) {
				return try expansion(of: node, providingMembersOf: declaration, in: context)
			}
			throw MacroError("Steps macro can only be applied to enums or structs")
		}
		let cases = declaration.memberBlock.members.flatMap {
			$0.decl.as(EnumCaseDeclSyntax.self)?.elements ?? []
		}
		guard cases.contains(where: \.hasParameters) else {
			return ["""
			public typealias AllSteps = Self

			public var selected: Self {
			    get { self }
			    set { 
				   StepSystem.observer.stepWillChange(to: newValue, in: Self.self, with: ())
			       self = newValue 
			       StepSystem.observer.stepDidChange(to: newValue, in: Self.self, with: ())
			    }
			}
			"""]
		}
		var isOptional = false
		var parameters: [String: [(type: String, value: String, name: String?)]] = [:]
		for caseItem in cases {
			if caseItem.name.text == "none" {
				isOptional = true
			}
			guard
				let caseParameters = caseItem.parameterClause?.parameters,
				!caseParameters.isEmpty
			else {
				continue
			}
			var params: [(type: String, value: String, name: String?)] = []
			for parameter in caseParameters {
				let type = parameter.type.trimmed.description
				var value = ""
				if let defaultValue = parameter.defaultValue?.value {
					value = defaultValue.description
				} else {
					if type.isOptional {
						value = "nil"
					} else {
						throw MacroError("All parameters of a case must have a default value or be optional")
					}
				}
				params.append((type, value, parameter.firstName?.text))
			}
			if !params.isEmpty {
				parameters[caseItem.name.text] = params
			}
		}
		let selected: DeclSyntax =
			"""
			public var selected: Steps {
			    get {
			        switch self {
			        \(raw: cases.map { "case .\($0.name.text): return .\($0.name.text)" }.joined(separator: "\n"))
			        }
			    }
			    set {
			        switch newValue {
			        \(raw: cases.map { "case .\($0.name.text): self = .\($0.name.text)\(parameters[$0.name.text] == nil ? "" : "()")" }.joined(separator: "\n"))
			        }
			    }
			}
			"""
		let stepsEnum: DeclSyntax =
			"""
			public enum Steps: String, CaseIterable, Codable, Sendable\(raw: isOptional ? ", OptionalStep" : "") {
			    case \(raw: cases.map(\.name.text).joined(separator: ", "))
			}
			"""
		var result = [selected, stepsEnum]
		for caseItem in cases {
			let name = caseItem.name.text
			let params = parameters[name] ?? []
			guard !params.isEmpty else {
				result.append(
					"""
					public var \(raw: name): EmptyStep {
					    get { EmptyStep() }
					    set {}
					}
					"""
				)
				continue
			}
			var type = params.map(\.type).joined(separator: ", ")
			if params.count > 1 {
				type = "(\(type))"
			}
			let isOptional = params.contains(where: \.value.isEmpty)
			if isOptional {
				type += "?"
			}
			var value = isOptional ? "nil" : params.map(\.value).joined(separator: ", ")
			if params.count > 1 {
				value = "(\(value))"
			}
			let args = params.indices.map { "arg\($0)" }.joined(separator: ", ")
			let newArgs = params.count == 1
				? "newValue"
				: params.indices
				.map { "\(params[$0].name.map { "\($0): " } ?? "")newValue.\($0)" }
				.joined(separator: ", ")
			let caseVar: DeclSyntax =
				"""
				public var \(raw: name): \(raw: type) {
				    get {
				        if case let .\(raw: name)(\(raw: args)) = self {
				            return \(raw: params.count > 1 ? "(\(args))" : "arg0")
				        }
				        return \(raw: value)
				    }
				    set {
				        if case .\(raw: name) = self\(raw: isOptional ? ", let newValue" : "") {
				            self = .\(raw: name)(\(raw: newArgs))
				        }
				    }
				}
				"""
			result.append(caseVar)
		}
		return result
	}

	public static func expansion(
		of node: AttributeSyntax,
		providingMembersOf declaration: some DeclGroupSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		guard declaration.is(StructDeclSyntax.self) else {
			throw MacroError("Steps macro can only be applied to structs")
		}
		var isOptional = false
		var cases: [String] = []
		var functions: [String: String] = [:]
		var hasStepVars = false
		var hasVarWithoutStep = false
		for member in declaration.memberBlock.members {
			if member.decl.hasStepAttribute {
				hasStepVars = true
			} else {
				hasVarWithoutStep = true
			}
		}
		for member in declaration.memberBlock.members {
			guard
				let variable = member.decl.as(VariableDeclSyntax.self),
				!hasStepVars || variable.hasStepAttribute,
				!variable.isStatic
			else {
				continue
			}
			guard
				let name = variable.storedVarName
			else {
				throw MacroError("Steps macro can contain only stored properties")
			}

			if name == "none" {
				isOptional = true
			}

			cases.append(name)

			guard !hasStepVars || !hasVarWithoutStep else { continue }

			if let binding = variable.bindings.first {
				var type = binding.typeAnnotation?.type.description ?? ""
				if type.isEmpty {
					if let value = binding.initializer?.value {
						if value.is(StringLiteralExprSyntax.self) {
							type = "String"
						} else if value.is(BooleanLiteralExprSyntax.self) {
							type = "Bool"
						} else if value.is(IntegerLiteralExprSyntax.self) {
							type = "Int"
						} else if value.is(FloatLiteralExprSyntax.self) {
							type = "Double"
                        } else if let typeName = value.baseName, typeName.first?.isLowercase == false {
                            type = typeName
                        } else {
							throw MacroError("Type of `\(name)` must be provided explicitly with `:`")
						}
					} else {
						functions[name] = ""
					}
				}
				var defaultValue = binding.initializer?.value.description
				if defaultValue == nil {
					if type.isOptional {
						defaultValue = "nil"
					} else if !type.isEmpty {
						throw MacroError("Default value of `\(name)` must be provided")
					}
				}
				if functions[name] == nil {
					functions[name] = "(_ value: \(type)\(defaultValue.map { " = \($0)" } ?? ""))"
				}
			}
		}

		guard !cases.isEmpty, cases != ["none"] else {
			throw MacroError("Steps must have at least one stored variable")
		}

		var result: [DeclSyntax] = []
		let canInitWithSelected = !hasStepVars || !hasVarWithoutStep

		var hasDeselected = false
		if !canInitWithSelected, !isOptional {
			isOptional = true
			hasDeselected = true
			let deselectedVar: DeclSyntax =
				"""
				var _deselectedMutateID = MutateID()
				"""
			result.append(deselectedVar)
		}
		let stepsType = "Steps" + (isOptional ? "?" : "")

		let lastMutateID: DeclSyntax = "public var _lastMutateID: MutateID? { lastMutateStepID?.1 }"
		result.append(lastMutateID)

		let defaultValue = canInitWithSelected ? "initialSelected" : "nil"
		let selected: DeclSyntax =
			"""
			public var selected: \(raw: stepsType) {
			    get { if let result = lastMutateStepID { return result.0 } else { return \(raw: defaultValue) } }
			    set {
			        guard let selection = Self._selections[newValue] else {
			            \(raw: hasDeselected ? "_deselectedMutateID._update()" : "")
			            return
			        }
				    selection(&self)
			    }
			}
			"""
		result.append(selected)
        
        let isSelected: DeclSyntax =
            """
            public func isSelected<T>(_ keyPath: WritableKeyPath<Self, StepID<T>>) -> Bool {
                selected == self[keyPath: keyPath].id
            }
            """
		result.append(isSelected)

		let typealiasDecl: DeclSyntax = "public typealias AllSteps = \(raw: stepsType)"
		result.append(typealiasDecl)

		let stepsEnum: DeclSyntax =
			"""
			public enum Steps: String, CaseIterable, Codable, Sendable, Hashable {
			    case \(raw: cases.filter { $0 != "none" }.joined(separator: ", "))
			}
			"""
		result.append(stepsEnum)

		let mutateIDs: DeclSyntax =
			"""
			private static var _selections: [AllSteps: (inout Self) -> Void] {
			    [\(raw: cases.map { ".\($0): { $0.$\($0).select() }" }.joined(separator: ", "))]
			}
			"""
		result.append(mutateIDs)

		let _lastMutateStepID: DeclSyntax =
			"""
			private var lastMutateStepID: (\(raw: stepsType), MutateID)? {
			    [
			        \(raw: (cases.map { "_\($0)._lastMutateID" } + (hasDeselected ? ["(nil, _deselectedMutateID)"] : [])).joined(separator: ",\n"))
			    ]
			    .compactMap { $0 }
			    .sorted(by: { $0.1 > $1.1 })
			    .first
			}
			"""
		result.append(_lastMutateStepID)

		guard canInitWithSelected else { return result }

		let initialSelected: DeclSyntax =
			"""
			private let initialSelected: \(raw: stepsType)
			"""
		result.append(initialSelected)

		let initDecl: DeclSyntax =
			"""
			private init(_ selected: \(raw: stepsType)) {
			    initialSelected = selected
			}
			"""
		result.append(initDecl)

		result += cases.map {
			let function = functions[$0] ?? ""
			let isVar = function.isEmpty

			var funcString = "public static \(isVar ? "var" : "func") \($0)\(function)\(isVar ? ":" : " ->") Self {"
			if isVar {
				funcString += "\nSelf.init(.\($0))\n"
			} else {
				funcString +=
					"""
					    var result = Self.init(.\($0))
					    result.\($0) = value
					    return result
					"""
			}
			funcString += "}"
			return DeclSyntax(stringLiteral: funcString)
		}
		return result
	}
}

extension EnumCaseElementSyntax {

	var hasParameters: Bool {
		(parameterClause?.parameters.count ?? 0) > 0
	}
}

extension DeclSyntaxProtocol {

	var hasStepAttribute: Bool {
		if let variable = self.as(VariableDeclSyntax.self),
		   variable.attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.trimmed.description == "Step" })
		{
			return true
		}
		return false
	}
}

extension VariableDeclSyntax {

	var storedVarName: String? {
		guard
			!modifiers.contains(where: \.name.isStaticOrLazyOrLet)
		else {
			return nil
		}
		var name: String?
		for binding in bindings {
			guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
				continue
			}
			name = identifier.identifier.text
			if let closure = binding.accessorBlock {
				guard
					let list = closure.accessors.as(AccessorDeclListSyntax.self),
					list.contains(where: \.accessorSpecifier.isWillSetOrDidSet)
				else {
					return nil
				}
			}
		}
		return name
	}

	var isStatic: Bool {
		modifiers.contains { $0.name.tokenKind == .keyword(.static) }
	}
}

extension TokenSyntax {

	var isWillSetOrDidSet: Bool {
		tokenKind == .keyword(.didSet) || tokenKind == .keyword(.willSet)
	}

	var isStaticOrLazyOrLet: Bool {
		[.keyword(.static), .keyword(.lazy), .keyword(.let)].contains(tokenKind)
	}
}

private extension String {

	var isOptional: Bool {
		hasSuffix("?") || hasPrefix("Optional<")
	}
}

private extension ExprSyntax {
    
    var baseName: String? {
        self.as(FunctionCallExprSyntax.self)?.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.trimmed.text ??
        self.as(FunctionCallExprSyntax.self)?.calledExpression.as(GenericSpecializationExprSyntax.self)?.trimmed.description
    }
}

private struct MacroError: LocalizedError, CustomStringConvertible {

	var errorDescription: String
	var description: String { errorDescription }

	init(_ errorDescription: String) {
		self.errorDescription = errorDescription
	}
}
#endif
