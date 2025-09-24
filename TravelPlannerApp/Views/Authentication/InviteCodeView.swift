import SwiftUI
import FirebaseFirestore

struct InviteCodeView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var inviteCode = ""
    @State private var showingRegistration = false
    @State private var isValidCode = false
    @State private var tripId: String = ""
    @FocusState private var isInviteCodeFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Join with Invite Code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter the 6-digit code shared by your trip organizer")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    TextField("Invite Code", text: $inviteCode)
                        .padding()
                        .background(isInviteCodeFocused ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($isInviteCodeFocused)
                        .keyboardType(.numberPad)
                        .onChange(of: inviteCode) { newValue in
                            // Limit to 6 digits
                            if newValue.count > 6 {
                                inviteCode = String(newValue.prefix(6))
                            }
                        }
                }
                .padding(.horizontal)
                
                Button(action: {
                    validateInviteCode()
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(inviteCode.count == 6 ? Color.black : Color.gray.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 0)
                        )
                        .foregroundColor(inviteCode.count == 6 ? .white : .gray)
                }
                .padding(.horizontal)
                .disabled(inviteCode.count != 6)
                
                if authManager.isLoading {
                    ProgressView()
                        .padding()
                }
                
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
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
        .sheet(isPresented: $showingRegistration) {
            InviteCodeRegistrationView(inviteCode: inviteCode, tripId: tripId)
                .environmentObject(authManager)
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
    
    private func validateInviteCode() {
        authManager.isLoading = true
        authManager.errorMessage = nil
        
        // Check if invite code is valid
        let db = Firestore.firestore()
        db.collection("inviteCodes").document(inviteCode).getDocument { document, error in
            DispatchQueue.main.async {
                authManager.isLoading = false
                
                if let error = error {
                    authManager.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data(),
                      let tripId = data["tripId"] as? String,
                      let isActive = data["isActive"] as? Bool,
                      isActive else {
                    authManager.errorMessage = "Invalid or expired invite code"
                    return
                }
                
                // Code is valid, show registration screen
                self.tripId = tripId
                self.showingRegistration = true
            }
        }
    }
}

struct InviteCodeRegistrationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    let inviteCode: String
    let tripId: String
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password, confirmPassword, username
    }
    
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !username.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter your details to join the trip")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(focusedField == .email ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .email ? Color.blue : Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(focusedField == .username ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .username ? Color.blue : Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .username)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(focusedField == .password ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .password ? Color.blue : Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .password)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(focusedField == .confirmPassword ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(focusedField == .confirmPassword ? Color.blue : Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($focusedField, equals: .confirmPassword)
                }
                .padding(.horizontal)
                
                if password != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords do not match")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if password.count < 6 && !password.isEmpty {
                    Text("Password must be at least 6 characters")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    if isFormValid {
                        authManager.signUpWithInviteCode(email: email, password: password, username: username, inviteCode: inviteCode, tripId: tripId)
                    }
                }) {
                    Text("Create Account & Join Trip")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isFormValid ? Color.black : Color.gray.opacity(0.3))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 0)
                        )
                        .foregroundColor(isFormValid ? .white : .gray)
                }
                .padding(.horizontal)
                .disabled(!isFormValid)
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("OR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.3))
                }
                .padding(.horizontal)
                
                Button(action: {
                    // Join without creating account - one-time access
                    authManager.joinTripWithoutAccount(inviteCode: inviteCode, tripId: tripId)
                }) {
                    Text("Join Without Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.indigo, lineWidth: 2)
                        )
                        .foregroundColor(.indigo)
                }
                .padding(.horizontal)
                
                if authManager.isLoading {
                    ProgressView()
                        .padding()
                }
                
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
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
}
