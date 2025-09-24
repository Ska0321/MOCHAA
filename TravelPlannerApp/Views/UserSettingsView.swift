import SwiftUI

struct UserSettingsView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteConfirmation = false
    @State private var showingDeleteAlert = false
    @State private var deleteAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        VStack(spacing: 20) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: geometry.size.width > 768 ? 100 : 80))
                                .foregroundColor(.blue)
                            
                            Text("Account Settings")
                                .font(geometry.size.width > 768 ? .system(size: 34, weight: .bold) : .largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            if let user = authManager.currentUser {
                                Text("Signed in as \(user.username)")
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, geometry.size.width > 768 ? 60 : 40)
                        .padding(.bottom, geometry.size.width > 768 ? 40 : 30)
                
                        // Settings Options
                        VStack(spacing: 0) {
                            // Account Information
                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 24 : 16) {
                                Text("Account Information")
                                    .font(geometry.size.width > 768 ? .title2 : .headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                                    .padding(.top, geometry.size.width > 768 ? 30 : 20)
                                
                                VStack(spacing: geometry.size.width > 768 ? 16 : 12) {
                                    if let user = authManager.currentUser {
                                        SettingsRow(
                                            icon: "person.fill",
                                            title: "Username",
                                            value: user.username,
                                            iconColor: .blue,
                                            isIPad: geometry.size.width > 768
                                        )
                                        
                                        if let email = user.email {
                                            SettingsRow(
                                                icon: "envelope.fill",
                                                title: "Email",
                                                value: email,
                                                iconColor: .green,
                                                isIPad: geometry.size.width > 768
                                            )
                                        }
                                        
                                        SettingsRow(
                                            icon: "calendar",
                                            title: "Account Type",
                                            value: user.isTemporary ? "Guest Account" : "Full Account",
                                            iconColor: user.isTemporary ? .orange : .purple,
                                            isIPad: geometry.size.width > 768
                                        )
                                    }
                                }
                                .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                                .padding(.bottom, geometry.size.width > 768 ? 30 : 20)
                            }
                            
                            Divider()
                                .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                            
                            // Danger Zone
                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 24 : 16) {
                                Text("Danger Zone")
                                    .font(geometry.size.width > 768 ? .title2 : .headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                                    .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                                    .padding(.top, geometry.size.width > 768 ? 30 : 20)
                                
                                VStack(spacing: geometry.size.width > 768 ? 16 : 12) {
                                    Button(action: {
                                        showingDeleteConfirmation = true
                                    }) {
                                        HStack {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                                .frame(width: geometry.size.width > 768 ? 28 : 24, height: geometry.size.width > 768 ? 28 : 24)
                                            
                                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 4 : 2) {
                                                Text("Delete Account")
                                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.red)
                                                
                                                Text("Permanently delete your account and all data")
                                                    .font(geometry.size.width > 768 ? .body : .caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(geometry.size.width > 768 ? .body : .caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, geometry.size.width > 768 ? 24 : 20)
                                        .padding(.vertical, geometry.size.width > 768 ? 20 : 16)
                                        .background(Color.red.opacity(0.05))
                                        .cornerRadius(geometry.size.width > 768 ? 16 : 12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                                .padding(.bottom, geometry.size.width > 768 ? 30 : 20)
                            }
                        }
                        
                        // Bottom padding to ensure content is accessible
                        Spacer(minLength: geometry.size.width > 768 ? 60 : 40)
                    }
                    .padding(.bottom, geometry.size.width > 768 ? 40 : 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete Account",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data, including trips and personal information.")
        }
        .alert("Account Deletion", isPresented: $showingDeleteAlert) {
            Button("OK") { }
        } message: {
            Text(deleteAlertMessage)
        }
    }
    
    private func deleteAccount() {
        authManager.deleteAccount()
        
        // Show success message and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if authManager.errorMessage == nil {
                deleteAlertMessage = "Your account has been successfully deleted."
                showingDeleteAlert = true
                dismiss()
            } else {
                deleteAlertMessage = authManager.errorMessage ?? "Failed to delete account."
                showingDeleteAlert = true
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    let isIPad: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: isIPad ? 28 : 24, height: isIPad ? 28 : 24)
            
            VStack(alignment: .leading, spacing: isIPad ? 4 : 2) {
                Text(title)
                    .font(isIPad ? .title3 : .body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(isIPad ? .body : .caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, isIPad ? 20 : 16)
        .padding(.vertical, isIPad ? 16 : 12)
        .background(Color(.systemGray6))
        .cornerRadius(isIPad ? 12 : 8)
    }
}

#Preview {
    UserSettingsView()
        .environmentObject(AuthenticationManager())
}
