import Foundation
import Firebase
import SwiftUI
//import FirebaseFirestoreSwift

struct Trip: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var startDate: Date
    var endDate: Date
    var createdBy: String
    var participants: [String] // User IDs
    var modules: [TripModule]
    var inviteCode: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, title: String, description: String = "", startDate: Date, endDate: Date, createdBy: String) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.createdBy = createdBy
        self.participants = [createdBy]
        self.modules = []
        self.inviteCode = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Custom initializer for loading from Firestore
    init(id: String, title: String, description: String, startDate: Date, endDate: Date, createdBy: String, participants: [String], modules: [TripModule]) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.createdBy = createdBy
        self.participants = participants
        self.modules = modules
        self.inviteCode = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Custom initializer for loading from Firestore with dates
    init(id: String, title: String, description: String, startDate: Date, endDate: Date, createdBy: String, participants: [String], modules: [TripModule], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.createdBy = createdBy
        self.participants = participants
        self.modules = modules
        self.inviteCode = nil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct TripModule: Identifiable, Codable {
    let id: String
    var type: ModuleType
    var data: ModuleData
    var isLocked: Bool
    var lockedBy: String?
    var position: Int
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, type: ModuleType, data: ModuleData, position: Int) {
        self.id = id
        self.type = type
        self.data = data
        self.isLocked = false
        self.lockedBy = nil
        self.position = position
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ModuleType: String, CaseIterable, Codable {
    case flight = "flight"
    case hotel = "hotel"
    case transportation = "transportation"
    case restaurant = "restaurant"
    case activity = "activity"
    case cost = "cost"
    case toBring = "toBring"
    
    var color: Color {
        switch self {
        case .flight: return .blue
        case .hotel: return .green
        case .transportation: return .orange
        case .restaurant: return .red
        case .activity: return .purple
        case .cost: return .blue
        case .toBring: return .teal
        }
    }
    
    var displayName: String {
        switch self {
        case .flight: return "Flight"
        case .hotel: return "Hotel"
        case .transportation: return "Transportation"
        case .restaurant: return "Restaurant"
        case .activity: return "Activity"
        case .cost: return "Cost"
        case .toBring: return "To Bring"
        }
    }
}
