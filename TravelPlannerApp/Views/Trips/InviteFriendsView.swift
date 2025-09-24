import SwiftUI

struct InviteFriendsView: View {
    let tripId: String
    @Binding var inviteCode: String?
    @EnvironmentObject var invitationService: InvitationService
    @Environment(\.dismiss) var dismiss
    
    @State private var generatedCode: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Invite Friends")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(spacing: 16) {
                    Text("Share this code with friends to let them join your trip")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if let code = generatedCode {
                        VStack(spacing: 12) {
                            Text(code)
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            
                            Button(action: {
                                UIPasteboard.general.string = code
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy Code")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    } else {
                        Button(action: {
                            generateCode()
                        }) {
                            Text("Generate Invite Code")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("How it works:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Friends can join without creating an account")
                        Text("• They just need to enter their name and the code")
                        Text("• Code is valid as long as the app is running")
                        Text("• Everyone can collaborate in real-time")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generateCode() {
        let code = invitationService.generateInviteCode(for: tripId)
        generatedCode = code
        inviteCode = code
    }
}
