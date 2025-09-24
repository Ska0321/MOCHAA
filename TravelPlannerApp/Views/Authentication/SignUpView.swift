import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool
    
    // Validation states
    @State private var emailValidationMessage = ""
    @State private var passwordValidationMessage = ""
    @State private var confirmPasswordValidationMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(isEmailFocused ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .focused($isEmailFocused)
                            .onChange(of: email) { _ in
                                validateEmail()
                            }
                        
                        if !emailValidationMessage.isEmpty {
                            Text(emailValidationMessage)
                                .font(.caption)
                                .foregroundColor(emailValidationMessage.contains("✓") ? .green : .red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(isPasswordFocused ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .focused($isPasswordFocused)
                            .onChange(of: password) { _ in
                                validatePassword()
                                validateConfirmPassword()
                            }
                        
                        if !passwordValidationMessage.isEmpty {
                            Text(passwordValidationMessage)
                                .font(.caption)
                                .foregroundColor(passwordValidationMessage.contains("✓") ? .green : .red)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(isConfirmPasswordFocused ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                            .focused($isConfirmPasswordFocused)
                            .onChange(of: confirmPassword) { _ in
                                validateConfirmPassword()
                            }
                        
                        if !confirmPasswordValidationMessage.isEmpty {
                            Text(confirmPasswordValidationMessage)
                                .font(.caption)
                                .foregroundColor(confirmPasswordValidationMessage.contains("✓") ? .green : .red)
                        }
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    if isFormValid() {
                        authManager.signUp(email: email, password: password)
                    }
                }) {
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isFormValid() ? Color.black : Color.gray.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 0)
                        )
                        .foregroundColor(isFormValid() ? .white : .gray)
                }
                .padding(.horizontal)
                .disabled(!isFormValid())
                
                if authManager.isLoading {
                    ProgressView()
                        .padding()
                }
                
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    // MARK: - Validation Methods
    
    private func validateEmail() {
        if email.isEmpty {
            emailValidationMessage = ""
        } else if !isValidEmail(email) {
            emailValidationMessage = "Please enter a valid email address"
        } else {
            emailValidationMessage = "✓ Email looks good"
        }
    }
    
    private func validatePassword() {
        if password.isEmpty {
            passwordValidationMessage = ""
        } else if password.count < 6 {
            passwordValidationMessage = "Password must be at least 6 characters"
        } else if password.count < 8 {
            passwordValidationMessage = "Password should be at least 8 characters for better security"
        } else {
            let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
            let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
            let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
            
            if hasUppercase && hasLowercase && hasDigit {
                passwordValidationMessage = "✓ Strong password"
            } else {
                passwordValidationMessage = "Include uppercase, lowercase, and numbers for better security"
            }
        }
    }
    
    private func validateConfirmPassword() {
        if confirmPassword.isEmpty {
            confirmPasswordValidationMessage = ""
        } else if password != confirmPassword {
            confirmPasswordValidationMessage = "Passwords do not match"
        } else {
            confirmPasswordValidationMessage = "✓ Passwords match"
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isFormValid() -> Bool {
        return !email.isEmpty &&
               !password.isEmpty &&
               !confirmPassword.isEmpty &&
               emailValidationMessage.contains("✓") &&
               passwordValidationMessage.contains("✓") &&
               confirmPasswordValidationMessage.contains("✓")
    }
}
