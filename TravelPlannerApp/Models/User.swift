import Foundation
import Firebase
//import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let email: String?
    let isTemporary: Bool
    let createdAt: Date
    
    init(id: String = UUID().uuidString, username: String, email: String? = nil, isTemporary: Bool = false) {
        self.id = id
        self.username = username
        self.email = email
        self.isTemporary = isTemporary
        self.createdAt = Date()
    }
}
