import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(isEmailFocused ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .focused($isEmailFocused)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(isPasswordFocused ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($isPasswordFocused)
                }
                .padding(.horizontal)
                
                Button(action: {
                    if isFormValid() {
                        authManager.signIn(email: email, password: password)
                    }
                }) {
                    Text("Sign In")
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
                
                // Create Account option
                VStack(spacing: 12) {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingSignUp = true
                    }) {
                        Text("Create New Account")
                            .fontWeight(.medium)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.1))
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black, lineWidth: 1)
                            )
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 20)
                
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
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
    }
    
    // MARK: - Form Validation
    
    private func isFormValid() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
}
