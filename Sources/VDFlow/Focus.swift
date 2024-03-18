import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {

	/// Modifies this view by binding its focus state to the given state value.
	///
	/// Use this modifier to cause the view to receive focus whenever the
	/// the `binding` equals the `value`. Typically, you create an enumeration
	/// of fields that may receive focus, bind an instance of this enumeration,
	/// and assign its cases to focusable views.
	///
	/// The following example uses the cases of a `LoginForm` enumeration to
	/// bind the focus state of two ``TextField`` views. A sign-in button
	/// validates the fields and sets the bound `focusedField` value to
	/// any field that requires the user to correct a problem.
	///
	///     struct LoginForm {
	///         enum Field: Hashable {
	///             case usernameField
	///             case passwordField
	///         }
	///
	///         @State private var username = ""
	///         @State private var password = ""
	///         @State private var focusedField: Field?
	///
	///         var body: some View {
	///             Form {
	///                 TextField("Username", text: $username)
	///                     .focused($focusedField, equals: .usernameField)
	///
	///                 SecureField("Password", text: $password)
	///                     .focused($focusedField, equals: .passwordField)
	///
	///                 Button("Sign In") {
	///                     if username.isEmpty {
	///                         focusedField = .usernameField
	///                     } else if password.isEmpty {
	///                         focusedField = .passwordField
	///                     } else {
	///                         handleLogin(username, password)
	///                     }
	///                 }
	///             }
	///         }
	///     }
	///
	/// To control focus using a Boolean, use the ``View/focused(_:)`` method
	/// instead.
	///
	/// - Parameters:
	///   - binding: The state binding to register. When focus moves to the
	///     modified view, the binding sets the bound value to the corresponding
	///     match value. If a caller sets the state value programmatically to the
	///     matching value, then focus moves to the modified view. When focus
	///     leaves the modified view, the binding sets the bound value to
	///     `nil`. If a caller sets the value to `nil`, SwiftUI automatically
	///     dismisses focus.
	///   - value: The value to match against when determining whether the
	///     binding should change.
	/// - Returns: The modified view.
	func focused<T: Hashable>(_ binding: Binding<T?>, equals value: T) -> some View {
		modifier(StepFocusModifier(equals: value, binding: binding))
	}

	/// Modifies this view by binding its focus state to the given Boolean state
	/// value.
	///
	/// Use this modifier to cause the view to receive focus whenever the
	/// the `condition` value is `true`. You can use this modifier to
	/// observe the focus state of a single view, or programmatically set and
	/// remove focus from the view.
	///
	/// In the following example, a single ``TextField`` accepts a user's
	/// desired `username`. The text field binds its focus state to the
	/// Boolean value `usernameFieldIsFocused`. A "Submit" button's action
	/// verifies whether the name is available. If the name is unavailable, the
	/// button sets `usernameFieldIsFocused` to `true`, which causes focus to
	/// return to the text field, so the user can enter a different name.
	///
	///     @State private var username: String = ""
	///     @State private var usernameFieldIsFocused: Bool
	///     @State private var showUsernameTaken = false
	///
	///     var body: some View {
	///         VStack {
	///             TextField("Choose a username.", text: $username)
	///                 .focused($usernameFieldIsFocused)
	///             if showUsernameTaken {
	///                 Text("That username is taken. Please choose another.")
	///             }
	///             Button("Submit") {
	///                 showUsernameTaken = false
	///                 if !isUserNameAvailable(username: username) {
	///                     usernameFieldIsFocused = true
	///                     showUsernameTaken = true
	///                 }
	///             }
	///         }
	///     }
	///
	/// To control focus by matching a value, use the
	/// ``View/focused(_:equals:)`` method instead.
	///
	/// - Parameter condition: The focus state to bind. When focus moves
	///   to the view, the binding sets the bound value to `true`. If a caller
	///   sets the value to  `true` programmatically, then focus moves to the
	///   modified view. When focus leaves the modified view, the binding
	///   sets the value to `false`. If a caller sets the value to `false`,
	///   SwiftUI automatically dismisses focus.
	///
	/// - Returns: The modified view.
	func focused(_ binding: Binding<Bool>, equals value: Bool = true) -> some View {
		modifier(StepFocusModifier(equals: value, binding: binding))
	}
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct StepFocusModifier<T: Hashable>: ViewModifier {

	let focus: FocusState<T>
	let value: T
	let binding: Binding<T>
	@State private var hasAppeared = false

	init<W>(equals value: W, binding: Binding<T>) where T == W? {
		focus = FocusState<T>()
		self.value = value
		self.binding = binding
	}

	func body(content: Content) -> some View {
		content
			.focused(focus.projectedValue, equals: value)
			.onAppear {
				guard !hasAppeared else { return }
				hasAppeared = true
				guard focus.wrappedValue != binding.wrappedValue else { return }
				focus.wrappedValue = binding.wrappedValue
			}
			.onChange(of: binding.wrappedValue) {
				guard focus.wrappedValue != $0 else { return }
				focus.wrappedValue = $0
			}
			.onChange(of: focus.wrappedValue) {
				guard binding.wrappedValue != $0 else { return }
				focus.wrappedValue = $0
			}
	}
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension StepFocusModifier<Bool> {

	init(equals value: Bool, binding: Binding<T>) {
		focus = FocusState<Bool>()
		self.value = value
		self.binding = binding
	}
}
