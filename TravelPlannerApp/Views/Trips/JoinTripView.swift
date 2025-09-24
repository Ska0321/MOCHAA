import SwiftUI
import Firebase

struct JoinTripView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var syncService: RealtimeSyncService
    @StateObject private var invitationService = InvitationService()
    @Environment(\.dismiss) var dismiss
    
    @State private var inviteCode = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccess = false
    @FocusState private var isInviteCodeFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.indigo)
                    
                    Text("Join a Trip")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Enter the 6-digit invite code shared with you to join an existing trip")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Invite Code Input
                VStack(spacing: 16) {
                    TextField("Invite Code", text: $inviteCode)
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding()
                        .background(isInviteCodeFocused ? Color(.systemGray6) : Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        .focused($isInviteCodeFocused)
                        .keyboardType(.numberPad)
                        .textInputAutocapitalization(.characters)
                        .onChange(of: inviteCode) { newValue in
                            // Limit to 6 digits and convert to uppercase
                            if newValue.count > 6 {
                                inviteCode = String(newValue.prefix(6))
                            }
                            inviteCode = newValue.uppercased()
                        }
                        .padding(.horizontal)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Join Button
                Button(action: {
                    joinTrip()
                }) {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "person.badge.plus")
                        }
                        Text(isLoading ? "Joining..." : "Join Trip")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(inviteCode.count == 6 && !isLoading ? Color.indigo : Color.gray.opacity(0.3))
                    )
                    .foregroundColor(.white)
                }
                .disabled(inviteCode.count != 6 || isLoading)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
        }
        .alert("Success!", isPresented: $showingSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("You have successfully joined the trip!")
        }
    }
    
    private func joinTrip() {
        guard let currentUser = authManager.currentUser else {
            errorMessage = "You must be logged in to join a trip"
            return
        }
        
        guard inviteCode.count == 6 else {
            errorMessage = "Please enter a valid 6-digit invite code"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // First, validate the invite code and get trip details
        invitationService.validateInviteCode(inviteCode) { tripId in
            DispatchQueue.main.async {
                if let tripId = tripId {
                    // Check if user is already in this trip
                    checkIfUserAlreadyInTrip(tripId: tripId, userId: currentUser.id)
                } else {
                    isLoading = false
                    errorMessage = "Invalid invite code. Please check and try again."
                }
            }
        }
    }
    
    private func checkIfUserAlreadyInTrip(tripId: String, userId: String) {
        let db = Firestore.firestore()
        db.collection("trips").document(tripId).getDocument { document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Failed to verify trip details: \(error.localizedDescription)"
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data() else {
                    self.isLoading = false
                    self.errorMessage = "Trip not found"
                    return
                }
                
                let createdBy = data["createdBy"] as? String ?? ""
                let participants = data["participants"] as? [String] ?? []
                
                // Check if user is the trip owner
                if createdBy == userId {
                    self.isLoading = false
                    self.errorMessage = "You cannot join your own trip"
                    return
                }
                
                // Check if user is already a participant
                if participants.contains(userId) {
                    self.isLoading = false
                    self.errorMessage = "You are already a participant in this trip"
                    return
                }
                
                // All validations passed, join the trip
                self.joinTripToFirestore(tripId: tripId, userId: userId)
            }
        }
    }
    
    private func joinTripToFirestore(tripId: String, userId: String) {
        let db = Firestore.firestore()
        db.collection("trips").document(tripId).updateData([
            "participants": FieldValue.arrayUnion([userId])
        ]) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to join trip: \(error.localizedDescription)"
                } else {
                    self.showingSuccess = true
                    // Refresh the user's trips list
                    self.syncService.loadUserTrips(userId: userId)
                }
            }
        }
    }
}
