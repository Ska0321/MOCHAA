import Foundation
import Firebase
//import FirebaseFirestoreSwift

class InvitationService: ObservableObject {
    
    func generateInviteCode(for tripId: String) -> String {
        let code = String(format: "%06d", Int.random(in: 100000...999999))
        
        let db = Firestore.firestore()
        let inviteData: [String: Any] = [
            "tripId": tripId,
            "isActive": true,
            "createdAt": FieldValue.serverTimestamp()
            // expiresAt removed as it's nil and not needed
        ]
        
        db.collection("inviteCodes").document(code).setData(inviteData) { error in
            if let error = error {
                print("Error creating invite code: \(error)")
            }
        }
        
        return code
    }
    
    func validateInviteCode(_ code: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("inviteCodes").document(code).getDocument { document, error in
            if let error = error {
                print("Error validating invite code: \(error)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let tripId = data["tripId"] as? String,
                  let isActive = data["isActive"] as? Bool,
                  isActive else {
                completion(nil)
                return
            }
            
            completion(tripId)
        }
    }
    
    func deactivateInviteCode(_ code: String) {
        let db = Firestore.firestore()
        db.collection("inviteCodes").document(code).updateData([
            "isActive": false
        ])
    }
}
