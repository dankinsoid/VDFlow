#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import Foundation

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
		guard let name = declaration.storedVarName else { return [] }
		return [
			"""
			didSet { selected = .\(raw: name) }
			""",
		]
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
		guard let name = member.storedVarName else { return [] }
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
            )
        ]
	}
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(EnumDeclSyntax.self) else {
            if declaration.is(StructDeclSyntax.self) {
                return try structExpansion(of: node, providingMembersOf: declaration, in: context)
            }
            throw MacroError("Steps macro can only be applied to enums or structs")
        }
        let cases = declaration.memberBlock.members.flatMap {
            $0.decl.as(EnumCaseDeclSyntax.self)?.elements ?? []
        }
        guard cases.contains(where: \.hasParameters) else {
            return ["""
            public typealias Steps = Self

            public var selected: Steps {
                get { self }
                set { self = newValue }
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

    public static func structExpansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var isOptional = false
        var cases: [String] = []
        var functions: [String: String] = [:]
        for member in declaration.memberBlock.members {
            guard
                let variable = member.decl.as(VariableDeclSyntax.self),
                let name = variable.storedVarName
            else { continue }
            cases.append(name)
            
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
                        } else {
                            throw MacroError("Type of `\(name)` must be provided explicitly with `:`")
                        }
                    } else {
                        functions[name] = ""
                    }
                }
                var defaultValue = binding.initializer?.value.description
                if defaultValue == nil, type.isOptional {
                    defaultValue = "nil"
                }
                if functions[name] == nil {
                    functions[name] = "(_ value: \(type)\(defaultValue.map { " = \($0)" } ?? ""))"
                }
            }
            
            if name == "none" {
                isOptional = true
            }
        }

        var result: [DeclSyntax] = []
        let initDecl: DeclSyntax =
            """
            private init(_ selected: Steps\(raw: isOptional ? " = nil" : "")) {
                self.selected = selected
            }
            """
        result.append(initDecl)
        result.append("public var selected: Steps")
        let stepsEnum: DeclSyntax =
            """
            public enum Steps: String, CaseIterable, Codable, Sendable\(raw: isOptional ? ", OptionalStep" : "") {
                case \(raw: cases.joined(separator: ", "))
            }
            """
        result.append(stepsEnum)
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
		   variable.attributes.contains(where: { $0.as(AttributeSyntax.self)?.attributeName.description == "Step" })
		{
			return true
		}
		return false
	}
    
	var storedVarName: String? {
		guard
			let variable = self.as(VariableDeclSyntax.self),
			//            includeAttributes || variable.attributes.isEmpty,
			!variable.modifiers.contains(where: \.name.isStaticOrLazy)
		else {
			return nil
		}
		var name: String?
		for binding in variable.bindings {
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
}

extension TokenSyntax {

	var isWillSetOrDidSet: Bool {
		tokenKind == .keyword(.didSet) || tokenKind == .keyword(.willSet)
	}

	var isStaticOrLazy: Bool {
		isStatic || tokenKind == .keyword(.lazy)
	}

	var isStatic: Bool {
		tokenKind == .keyword(.static)
	}
}

private extension String {
    
    var isOptional: Bool {
        hasSuffix("?") || hasPrefix("Optional<")
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
