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
            didSet {
                didSetStep(_\(raw: name))
                _\(raw: name)._selectionState.reset()
            }
            """
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
		return ["@Step", "@StepID(.\(raw: name))"]
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
        guard declaration.is(StructDeclSyntax.self) else {
            throw MacroError("Steps macro can only be applied to structs")
        }
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
            
            if name == "none" {
                isOptional = true
            }
        }
        
        guard !cases.isEmpty, cases != ["none"] else {
            throw MacroError("Steps must have at least one variable")
        }

        let stepsType = "Steps" + (isOptional ? "?" : "")
        var result: [DeclSyntax] = []
        let selectionStates: DeclSyntax = "public var _selectionState = SelectionState()"
        result.append(selectionStates)
        let initDecl: DeclSyntax =
            """
            private init(_ selected: \(raw: stepsType)) {
                self.selected = selected
                if let wrapperPath = Self.selectionPaths[selected] {
                    self[keyPath: wrapperPath].select(needUpdate: false)
                }
            }
            """
        result.append(initDecl)
        let selected: DeclSyntax =
            """
            public var selected: \(raw: stepsType) {
                didSet {
                    didSetSelected(oldValue)
                }
            }
            """
        result.append(selected)
        let typealiasDecl: DeclSyntax = "public typealias AllSteps = \(raw: stepsType)"
        result.append(typealiasDecl)
        let stepsEnum: DeclSyntax =
            """
            public enum Steps: String, CaseIterable, Codable, Sendable, Hashable {
                case \(raw: cases.filter({ $0 != "none" }).joined(separator: ", "))
            }
            """
        result.append(stepsEnum)
        let mutateIDs: DeclSyntax =
            """
            private static let selectionPaths: [AllSteps: WritableKeyPath<Self, SelectionState>] = [
                \(raw: cases.map { ".\($0): \\.$\($0)._selectionState" }.joined(separator: ", "))
            ]
            """
        result.append(mutateIDs)
        let didSetStepFunc: DeclSyntax =
            """
            private mutating func didSetStep<T>(_ wrapper: StepWrapper<Self, T>) {
                print("didSetStep \\(wrapper.id), \\(wrapper._selectionState.needUpdate)")
                guard wrapper._selectionState.needUpdate else { return }
                print("didSetStep \\(wrapper.id) and update selected")
                let isSelected = wrapper._selectionState.isSelected
                if isSelected {
                    selected = wrapper.id
                } else {
                    \(raw: isOptional ? "selected = nil" : "didSetSelected(selected)")
                }
            }
            """
        result.append(didSetStepFunc)
        let didSetSelectedFunc: DeclSyntax =
            """
            private mutating func didSetSelected(_ oldValue: \(raw: stepsType)) {
                print("didSetSelected \\(selected)")
                guard
                    let oldWrapperPath = Self.selectionPaths[oldValue],
                    let newWrapperPath = Self.selectionPaths[selected]
                else { return }
                if true {
                print("didSetSelected \\(selected) and update parent")
                    _selectionState.select(needUpdate: true)
                }
                if oldValue != selected {
                    print("didSetSelected \\(selected) and update wrappers")
                    self[keyPath: oldWrapperPath].deselect(needUpdate: false)
                    self[keyPath: newWrapperPath].select(needUpdate: false)
                }
            }
            """
        result.append(didSetSelectedFunc)
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
