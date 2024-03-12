#if canImport(SwiftCompilerPlugin)
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
        StepsMacro.self
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
            """
        ]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let name = member.storedVarName else { return [] }
        return ["@Step(.\(raw: name))", "@StepDidSet"]
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [stepsCollectionExtension(for: type)]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let names = declaration.memberBlock.members.compactMap(\.decl.storedVarName)
        let cases = names.map {
            "\n        case \($0)"
        }
        .joined()
        
        let stepsEnum: DeclSyntax =
      """
      public var selected: Steps?

      public init(_ selected: Steps?) {
          self.selected = selected
      }
      
      public enum Steps: String, CaseIterable, Codable {
          \(raw: cases)
      }
      """
        return [stepsEnum]
    }
}

extension DeclSyntaxProtocol {
    
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

private func stepsCollectionExtension(for type: some TypeSyntaxProtocol) -> ExtensionDeclSyntax {
    ExtensionDeclSyntax(
        extendedType: type,
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: TypeSyntax(stringLiteral: "StepsCollection")
                )
            }
        ),
        memberBlock: MemberBlockSyntax(members: MemberBlockItemListSyntax())
    )
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
#endif
