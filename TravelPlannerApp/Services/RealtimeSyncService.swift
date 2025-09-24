import Foundation
import Firebase
//import FirebaseFirestoreSwift
import Combine

class RealtimeSyncService: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    @Published var lockedSections: [String: String] = [:] // moduleId: userId
    
    private var tripListener: ListenerRegistration?
    private var lockListener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    // MARK: - Trip Management
    func loadUserTrips(userId: String) {
        print("🔄 Loading trips for user: \(userId)")
        
        // Check if Firebase is configured
        guard FirebaseApp.app() != nil else {
            print("❌ Firebase not configured, cannot load trips")
            return
        }
        
        // Load all trips and filter in the app since Firestore doesn't support OR queries easily
        let tripsRef = db.collection("trips")
            .order(by: "updatedAt", descending: true)
        
        tripListener = tripsRef.addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("Error loading trips: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self?.trips = documents.compactMap { document in
                let data = document.data()
                
                // Check if user has access to this trip (either participant or creator)
                let participants = data["participants"] as? [String] ?? []
                let createdBy = data["createdBy"] as? String ?? ""
                
                if !participants.contains(userId) && createdBy != userId {
                    print("Skipping trip \(data["id"] as? String ?? "unknown") - user not authorized")
                    return nil
                }
                
                print("Including trip: \(data["title"] as? String ?? "unknown") for user: \(userId)")
                
                // Parse modules with proper deserialization
                let modulesData = data["modules"] as? [[String: Any]] ?? []
                print("Found \(modulesData.count) modules for trip: \(data["title"] as? String ?? "unknown")")
                
                let modules = modulesData.compactMap { moduleDict -> TripModule? in
                    guard let id = moduleDict["id"] as? String,
                          let typeString = moduleDict["type"] as? String,
                          let type = ModuleType(rawValue: typeString),
                          let position = moduleDict["position"] as? Int else {
                        print("❌ Failed to parse module: missing required fields")
                        return nil
                    }
                    
                    // Parse the module data properly
                    let moduleDataDict = moduleDict["data"] as? [String: Any] ?? [:]
                    guard let moduleData = self?.deserializeModuleData(moduleDataDict, type: type) else {
                        print("❌ Failed to deserialize module data for type: \(typeString)")
                        return nil
                    }
                    
                    print("✅ Successfully parsed module: \(typeString) with ID: \(id)")
                    
                    var module = TripModule(id: id, type: type, data: moduleData, position: position)
                    module.isLocked = moduleDict["isLocked"] as? Bool ?? false
                    module.lockedBy = moduleDict["lockedBy"] as? String
                    module.isCompleted = moduleDict["isCompleted"] as? Bool ?? false
                    module.createdAt = (moduleDict["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    module.updatedAt = (moduleDict["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                    
                    return module
                }
                
                return Trip(
                    id: data["id"] as? String ?? "",
                    title: data["title"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                    endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                    createdBy: data["createdBy"] as? String ?? "",
                    participants: data["participants"] as? [String] ?? [],
                    modules: modules,
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                    updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
        }
    }
    
    func createTrip(_ trip: Trip) {
        // Ensure the creator is in the participants array
        var participants = trip.participants
        if !participants.contains(trip.createdBy) {
            participants.append(trip.createdBy)
        }
        
        let tripData: [String: Any] = [
            "id": trip.id,
            "title": trip.title,
            "description": trip.description,
            "startDate": Timestamp(date: trip.startDate),
            "endDate": Timestamp(date: trip.endDate),
            "createdBy": trip.createdBy,
            "participants": participants,
            "modules": [],
            "createdAt": Timestamp(date: trip.createdAt),
            "updatedAt": Timestamp(date: trip.updatedAt)
        ]
        
        db.collection("trips").document(trip.id).setData(tripData) { [weak self] error in
            if let error = error {
                print("Error creating trip: \(error)")
            } else {
                print("Trip created successfully: \(trip.id)")
                // Refresh the trips list after creating
                self?.loadUserTrips(userId: trip.createdBy)
            }
        }
    }
    
    func updateTrip(_ trip: Trip) {
        var updatedTrip = trip
        updatedTrip.updatedAt = Date()
        
        let tripData: [String: Any] = [
            "id": updatedTrip.id,
            "title": updatedTrip.title,
            "description": updatedTrip.description,
            "startDate": Timestamp(date: updatedTrip.startDate),
            "endDate": Timestamp(date: updatedTrip.endDate),
            "participants": updatedTrip.participants,
            "modules": updatedTrip.modules.map { module in
                [
                    "id": module.id,
                    "type": module.type.rawValue,
                    "data": serializeModuleData(module.data),
                    "isLocked": module.isLocked,
                    "lockedBy": module.lockedBy ?? "",
                    "position": module.position,
                    "isCompleted": module.isCompleted,
                    "createdAt": Timestamp(date: module.createdAt),
                    "updatedAt": Timestamp(date: module.updatedAt)
                ]
            },
            "createdAt": Timestamp(date: updatedTrip.createdAt),
            "updatedAt": Timestamp(date: updatedTrip.updatedAt)
        ]
        
        db.collection("trips").document(trip.id).setData(tripData) { error in
            if let error = error {
                print("Error updating trip: \(error)")
            }
        }
    }
    
    // MARK: - Trip Parsing
    private func parseTripDocument(_ data: [String: Any], documentId: String) -> Trip? {
        // Parse modules with proper deserialization
        let modulesData = data["modules"] as? [[String: Any]] ?? []
        print("Found \(modulesData.count) modules for trip: \(data["title"] as? String ?? "unknown")")
        
        let modules = modulesData.compactMap { moduleDict -> TripModule? in
            guard let id = moduleDict["id"] as? String,
                  let typeString = moduleDict["type"] as? String,
                  let type = ModuleType(rawValue: typeString),
                  let position = moduleDict["position"] as? Int else {
                print("❌ Failed to parse module: missing required fields")
                return nil
            }
            
            // Parse the module data properly
            let moduleDataDict = moduleDict["data"] as? [String: Any] ?? [:]
            guard let moduleData = deserializeModuleData(moduleDataDict, type: type) else {
                print("❌ Failed to deserialize module data for type: \(typeString)")
                return nil
            }
            
            print("✅ Successfully parsed module: \(typeString) with ID: \(id)")
            
            var module = TripModule(id: id, type: type, data: moduleData, position: position)
            module.isLocked = moduleDict["isLocked"] as? Bool ?? false
            module.lockedBy = moduleDict["lockedBy"] as? String
            module.isCompleted = moduleDict["isCompleted"] as? Bool ?? false
            module.createdAt = (moduleDict["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            module.updatedAt = (moduleDict["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
            
            return module
        }
        
        return Trip(
            id: data["id"] as? String ?? "",
            title: data["title"] as? String ?? "",
            description: data["description"] as? String ?? "",
            startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
            endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
            createdBy: data["createdBy"] as? String ?? "",
            participants: data["participants"] as? [String] ?? [],
            modules: modules,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    // MARK: - Module Management
    private func serializeModuleData(_ moduleData: ModuleData) -> [String: Any] {
        switch moduleData {
        case .flight(let flightData):
            return [
                "type": "flight",
                "flightNumber": flightData.flightNumber,
                "departureDate": Timestamp(date: flightData.departureDate),
                "departureTime": Timestamp(date: flightData.departureTime),
                "departureAirport": flightData.departureAirport,
                "arrivalAirport": flightData.arrivalAirport,
                "cost": flightData.cost ?? 0.0,
                "notes": flightData.notes,
                "isBooked": flightData.isBooked,
                "bookingReference": flightData.bookingReference
            ]
        case .hotel(let hotelData):
            return [
                "type": "hotel",
                "hotelName": hotelData.hotelName,
                "checkInDate": Timestamp(date: hotelData.checkInDate),
                "checkOutDate": Timestamp(date: hotelData.checkOutDate),
                "roomType": hotelData.roomType,
                "address": hotelData.address,
                "cost": hotelData.cost ?? 0.0,
                "notes": hotelData.notes,
                "isBooked": hotelData.isBooked,
                "bookingReference": hotelData.bookingReference
            ]
        case .transportation(let transportData):
            return [
                "type": "transportation",
                "transportType": transportData.type,
                "destination": transportData.destination,
                "departureLocation": transportData.departureLocation,
                "duration": transportData.duration,
                "startDate": Timestamp(date: transportData.startDate),
                "departureTime": Timestamp(date: transportData.departureTime),
                "arrivalTime": Timestamp(date: transportData.arrivalTime),
                "cost": transportData.cost ?? 0.0,
                "notes": transportData.notes,
                "isBooked": transportData.isBooked,
                "bookingReference": transportData.bookingReference
            ]
        case .restaurant(let restaurantData):
            return [
                "type": "restaurant",
                "name": restaurantData.name,
                "time": Timestamp(date: restaurantData.time),
                "startDate": Timestamp(date: restaurantData.startDate),
                "hasReservation": restaurantData.hasReservation,
                "reservationName": restaurantData.reservationName,
                "cuisine": restaurantData.cuisine,
                "rating": restaurantData.rating ?? 0.0,
                "cost": restaurantData.cost ?? 0.0,
                "notes": restaurantData.notes
            ]
        case .activity(let activityData):
            return [
                "type": "activity",
                "name": activityData.name,
                "activityType": activityData.type,
                "location": activityData.location,
                "address": activityData.address,
                "startDate": Timestamp(date: activityData.startDate),
                "startTime": Timestamp(date: activityData.startTime),
                "endTime": Timestamp(date: activityData.endTime),
                "duration": activityData.duration,
                "cost": activityData.cost ?? 0.0,
                "notes": activityData.notes,
                "isBooked": activityData.isBooked,
                "bookingReference": activityData.bookingReference
            ]
        case .cost(let costData):
            return [
                "type": "cost",
                "totalCost": costData.totalCost,
                "breakdown": costData.breakdown.map { item in
                    [
                        "id": item.id,
                        "moduleId": item.moduleId,
                        "description": item.description,
                        "amount": item.amount
                    ]
                },
                "isBooked": costData.isBooked,
                "bookingReference": costData.bookingReference
            ]
        case .toBring(let toBringData):
            return [
                "type": "toBring",
                "title": toBringData.title,
                "items": toBringData.items.map { item in
                    [
                        "id": item.id,
                        "name": item.name,
                        "isChecked": item.isChecked,
                        "category": item.category,
                        "notes": item.notes
                    ]
                },
                "notes": toBringData.notes
            ]
        }
    }
    
    // MARK: - Module Deserialization
    private func deserializeModuleData(_ data: [String: Any], type: ModuleType) -> ModuleData? {
        switch type {
        case .flight:
            let flightData = FlightData(
                flightNumber: data["flightNumber"] as? String ?? "",
                departureDate: (data["departureDate"] as? Timestamp)?.dateValue() ?? Date(),
                departureTime: (data["departureTime"] as? Timestamp)?.dateValue() ?? Date(),
                departureAirport: data["departureAirport"] as? String ?? "",
                arrivalAirport: data["arrivalAirport"] as? String ?? "",
                cost: data["cost"] as? Double,
                notes: data["notes"] as? String ?? "",
                isBooked: data["isBooked"] as? Bool ?? false,
                bookingReference: data["bookingReference"] as? String ?? ""
            )
            return .flight(flightData)
            
        case .hotel:
            let hotelData = HotelData(
                hotelName: data["hotelName"] as? String ?? "",
                checkInDate: (data["checkInDate"] as? Timestamp)?.dateValue() ?? Date(),
                checkOutDate: (data["checkOutDate"] as? Timestamp)?.dateValue() ?? Date(),
                roomType: data["roomType"] as? String ?? "",
                address: data["address"] as? String ?? "",
                cost: data["cost"] as? Double,
                notes: data["notes"] as? String ?? "",
                isBooked: data["isBooked"] as? Bool ?? false,
                bookingReference: data["bookingReference"] as? String ?? ""
            )
            return .hotel(hotelData)
            
        case .transportation:
            let transportData = TransportationData(
                type: data["transportType"] as? String ?? "",
                destination: data["destination"] as? String ?? "",
                departureLocation: data["departureLocation"] as? String ?? "",
                duration: data["duration"] as? String ?? "",
                departureTime: (data["departureTime"] as? Timestamp)?.dateValue() ?? Date(),
                arrivalTime: (data["arrivalTime"] as? Timestamp)?.dateValue() ?? Date(),
                startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                cost: data["cost"] as? Double,
                notes: data["notes"] as? String ?? "",
                isBooked: data["isBooked"] as? Bool ?? false,
                bookingReference: data["bookingReference"] as? String ?? ""
            )
            return .transportation(transportData)
            
        case .restaurant:
            let restaurantData = RestaurantData(
                name: data["name"] as? String ?? "",
                time: (data["time"] as? Timestamp)?.dateValue() ?? Date(),
                startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                hasReservation: data["hasReservation"] as? Bool ?? false,
                reservationName: data["reservationName"] as? String ?? "",
                cuisine: data["cuisine"] as? String ?? "",
                rating: data["rating"] as? Double,
                cost: data["cost"] as? Double,
                notes: data["notes"] as? String ?? ""
            )
            return .restaurant(restaurantData)
            
        case .activity:
            let activityData = ActivityData(
                name: data["name"] as? String ?? "",
                type: data["activityType"] as? String ?? "",
                location: data["location"] as? String ?? "",
                address: data["address"] as? String ?? "",
                startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                startTime: (data["startTime"] as? Timestamp)?.dateValue() ?? Date(),
                endTime: (data["endTime"] as? Timestamp)?.dateValue() ?? Date(),
                duration: data["duration"] as? String ?? "",
                cost: data["cost"] as? Double,
                notes: data["notes"] as? String ?? "",
                isBooked: data["isBooked"] as? Bool ?? false,
                bookingReference: data["bookingReference"] as? String ?? ""
            )
            return .activity(activityData)
            
        case .cost:
            let breakdownData = data["breakdown"] as? [[String: Any]] ?? []
            let breakdown = breakdownData.compactMap { itemData -> CostItem? in
                guard let id = itemData["id"] as? String,
                      let moduleId = itemData["moduleId"] as? String,
                      let description = itemData["description"] as? String,
                      let amount = itemData["amount"] as? Double else {
                    return nil
                }
                return CostItem(id: id, moduleId: moduleId, description: description, amount: amount)
            }
            
            let costData = CostData(
                totalCost: data["totalCost"] as? Double ?? 0.0,
                breakdown: breakdown,
                isBooked: data["isBooked"] as? Bool ?? false,
                bookingReference: data["bookingReference"] as? String ?? ""
            )
            return .cost(costData)
        case .toBring:
            let itemsData = data["items"] as? [[String: Any]] ?? []
            let items = itemsData.compactMap { itemData -> ToBringItem? in
                guard let id = itemData["id"] as? String,
                      let name = itemData["name"] as? String else {
                    return nil
                }
                return ToBringItem(
                    id: id,
                    name: name,
                    isChecked: itemData["isChecked"] as? Bool ?? false,
                    category: itemData["category"] as? String ?? "general",
                    notes: itemData["notes"] as? String ?? ""
                )
            }
            
            let toBringData = ToBringData(
                title: data["title"] as? String ?? "",
                items: items,
                notes: data["notes"] as? String ?? ""
            )
            return .toBring(toBringData)
        }
    }
    
    func addModule(to tripId: String, module: TripModule) {
        print("🔄 Adding module: \(module.type.rawValue) to trip: \(tripId)")
        
        let tripRef = db.collection("trips").document(tripId)
        
        let moduleData: [String: Any] = [
            "id": module.id,
            "type": module.type.rawValue,
            "data": serializeModuleData(module.data),
            "isLocked": module.isLocked,
            "lockedBy": module.lockedBy ?? "",
            "position": module.position,
            "isCompleted": module.isCompleted,
            "createdAt": Timestamp(date: module.createdAt),
            "updatedAt": Timestamp(date: module.updatedAt)
        ]
        
        print("📦 Module data to save: \(moduleData)")
        
        tripRef.updateData([
            "modules": FieldValue.arrayUnion([moduleData]),
            "updatedAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("❌ Error adding module: \(error)")
            } else {
                print("✅ Module added successfully: \(module.id)")
            }
        }
    }
    
    func updateModule(tripId: String, module: TripModule) {
        print("🔄 Updating module: \(module.id)")
        
        let tripRef = db.collection("trips").document(tripId)
        
        // First, fetch the current trip data from Firestore
        tripRef.getDocument { [weak self] document, error in
            if let error = error {
                print("❌ Error fetching trip for update: \(error)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("❌ Trip document not found: \(tripId)")
                return
            }
            
            // Parse the current trip data
            guard let trip = self?.parseTripDocument(data, documentId: tripId) else {
                print("❌ Failed to parse trip data")
                return
            }
            
            // Update the specific module
            var updatedTrip = trip
            if let moduleIndex = updatedTrip.modules.firstIndex(where: { $0.id == module.id }) {
                var updatedModule = module
                updatedModule.updatedAt = Date()
                updatedTrip.modules[moduleIndex] = updatedModule
                updatedTrip.updatedAt = Date()
                
                // Update local trips array
                if let tripIndex = self?.trips.firstIndex(where: { $0.id == tripId }) {
                    self?.trips[tripIndex] = updatedTrip
                }
                
                // Prepare modules data for Firestore
                let modulesData = updatedTrip.modules.map { module in
                    [
                        "id": module.id,
                        "type": module.type.rawValue,
                        "data": self?.serializeModuleData(module.data) ?? [:],
                        "isLocked": module.isLocked,
                        "lockedBy": module.lockedBy ?? "",
                        "position": module.position,
                        "isCompleted": module.isCompleted,
                        "createdAt": Timestamp(date: module.createdAt),
                        "updatedAt": Timestamp(date: module.updatedAt)
                    ]
                }
                
                // Update Firestore
                tripRef.updateData([
                    "modules": modulesData,
                    "updatedAt": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        print("❌ Error updating module in Firestore: \(error)")
                    } else {
                        print("✅ Module updated successfully in Firestore")
                    }
                }
            } else {
                print("❌ Module not found in trip: \(module.id)")
            }
        }
    }
    
    func updateModulesBatch(tripId: String, modules: [TripModule]) {
        print("🔄 Updating \(modules.count) modules in batch for trip: \(tripId)")
        
        let tripRef = db.collection("trips").document(tripId)
        
        // Prepare modules data for Firestore
        let modulesData = modules.map { module in
            [
                "id": module.id,
                "type": module.type.rawValue,
                "data": serializeModuleData(module.data),
                "isLocked": module.isLocked,
                "lockedBy": module.lockedBy ?? "",
                "position": module.position,
                "isCompleted": module.isCompleted,
                "createdAt": Timestamp(date: module.createdAt),
                "updatedAt": Timestamp(date: module.updatedAt)
            ]
        }
        
        // Update Firestore with all modules at once
        tripRef.updateData([
            "modules": modulesData,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            if let error = error {
                print("❌ Error updating modules batch in Firestore: \(error)")
                // Revert local changes on error
                if self?.trips.contains(where: { $0.id == tripId }) == true {
                    // Reload the trip from Firestore to get the correct state
                    self?.loadTripFromFirestore(tripId: tripId)
                }
            } else {
                print("✅ Modules batch updated successfully in Firestore")
                
                // Update local trips array
                if let tripIndex = self?.trips.firstIndex(where: { $0.id == tripId }) {
                    var updatedTrip = self?.trips[tripIndex]
                    updatedTrip?.modules = modules
                    updatedTrip?.updatedAt = Date()
                    if let updatedTrip = updatedTrip {
                        self?.trips[tripIndex] = updatedTrip
                    }
                }
            }
        }
    }
    
    func toggleModuleCompletion(tripId: String, moduleId: String, currentModules: [TripModule]) {
        // Find the module in the provided modules array
        guard let moduleIndex = currentModules.firstIndex(where: { $0.id == moduleId }) else {
            print("❌ Module not found: \(moduleId)")
            return
        }
        
        // Create updated modules array
        var updatedModules = currentModules
        var updatedModule = updatedModules[moduleIndex]
        updatedModule.isCompleted.toggle()
        updatedModule.updatedAt = Date()
        updatedModules[moduleIndex] = updatedModule
        
        // Update Firestore
        let tripRef = db.collection("trips").document(tripId)
        let modulesData = updatedModules.map { module in
            [
                "id": module.id,
                "type": module.type.rawValue,
                "data": serializeModuleData(module.data),
                "isLocked": module.isLocked,
                "lockedBy": module.lockedBy ?? "",
                "position": module.position,
                "isCompleted": module.isCompleted,
                "createdAt": Timestamp(date: module.createdAt),
                "updatedAt": Timestamp(date: module.updatedAt)
            ]
        }
        
        tripRef.updateData([
            "modules": modulesData,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            if let error = error {
                print("❌ Error toggling module completion: \(error)")
                // Revert local changes on error
                if self?.trips.contains(where: { $0.id == tripId }) == true {
                    // Reload the trip from Firestore to get the correct state
                    self?.loadTripFromFirestore(tripId: tripId)
                }
            } else {
                print("✅ Module completion toggled successfully")
                
                // Update local trips array if the trip exists
                if let tripIndex = self?.trips.firstIndex(where: { $0.id == tripId }) {
                    var updatedTrip = self?.trips[tripIndex]
                    updatedTrip?.modules = updatedModules
                    updatedTrip?.updatedAt = Date()
                    if let updatedTrip = updatedTrip {
                        self?.trips[tripIndex] = updatedTrip
                    }
                }
            }
        }
    }
    
    func deleteModule(tripId: String, moduleId: String) {
        print("🗑️ Deleting module: \(moduleId)")
        
        // Find the trip in the trips array
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripId }) else {
            print("❌ Trip not found: \(tripId)")
            return
        }
        
        var updatedTrip = trips[tripIndex]
        updatedTrip.modules.removeAll { $0.id == moduleId }
        updatedTrip.updatedAt = Date()
        trips[tripIndex] = updatedTrip
        
        let tripRef = db.collection("trips").document(tripId)
        
        let modulesData = updatedTrip.modules.map { module in
            [
                "id": module.id,
                "type": module.type.rawValue,
                "data": serializeModuleData(module.data),
                "isLocked": module.isLocked,
                "lockedBy": module.lockedBy ?? "",
                "position": module.position,
                "isCompleted": module.isCompleted,
                "createdAt": Timestamp(date: module.createdAt),
                "updatedAt": Timestamp(date: module.updatedAt)
            ]
        }
        
        tripRef.updateData([
            "modules": modulesData,
            "updatedAt": FieldValue.serverTimestamp()
        ]) { [weak self] error in
            if let error = error {
                print("❌ Error deleting module: \(error)")
                // Revert local changes on error
                if let tripIndex = self?.trips.firstIndex(where: { $0.id == tripId }) {
                    self?.trips[tripIndex] = self?.trips[tripIndex] ?? Trip(id: tripId, title: "", description: "", startDate: Date(), endDate: Date(), createdBy: "")
                }
            } else {
                print("✅ Module deleted successfully")
            }
        }
    }
    
    func deleteTrip(tripId: String) {
        print("🗑️ Deleting trip: \(tripId)")
        
        // Remove trip from local array
        trips.removeAll { $0.id == tripId }
        
        // Delete from Firestore
        let tripRef = db.collection("trips").document(tripId)
        
        tripRef.delete { error in
            if let error = error {
                print("❌ Error deleting trip: \(error)")
            } else {
                print("✅ Trip deleted successfully")
            }
        }
    }
    
    // MARK: - Section Locking
    func lockSection(tripId: String, moduleId: String, userId: String) {
        print("�� Locking section \(moduleId) for user \(userId)")
        
        let lockRef = db.collection("tripLocks").document(tripId)
        
        lockRef.setData([
            moduleId: userId
        ], merge: true) { [weak self] error in
            if let error = error {
                print("❌ Error locking section: \(error)")
            } else {
                print("✅ Section locked successfully")
                DispatchQueue.main.async {
                    self?.lockedSections[moduleId] = userId
                }
            }
        }
    }
    
    func unlockSection(tripId: String, moduleId: String, userId: String) {
        print("🔓 Unlocking section \(moduleId) for user \(userId)")
        
        let lockRef = db.collection("tripLocks").document(tripId)
        
        lockRef.updateData([
            moduleId: FieldValue.delete()
        ]) { [weak self] error in
            if let error = error {
                print("❌ Error unlocking section: \(error)")
            } else {
                print("✅ Section unlocked successfully")
                DispatchQueue.main.async {
                    self?.lockedSections.removeValue(forKey: moduleId)
                }
            }
        }
    }
    
    func listenToTripUpdates(tripId: String, completion: @escaping (Trip) -> Void) {
        let tripRef = db.collection("trips").document(tripId)
        
        tripRef.addSnapshotListener { [weak self] document, error in
            if let error = error {
                print("Error listening to trip updates: \(error)")
                return
            }
            
            guard let data = document?.data() else { return }
            
            // Parse modules with proper deserialization
            let modulesData = data["modules"] as? [[String: Any]] ?? []
            
            let modules = modulesData.compactMap { moduleDict -> TripModule? in
                guard let id = moduleDict["id"] as? String,
                      let typeString = moduleDict["type"] as? String,
                      let type = ModuleType(rawValue: typeString),
                      let position = moduleDict["position"] as? Int else {
                    return nil
                }
                
                let moduleDataDict = moduleDict["data"] as? [String: Any] ?? [:]
                guard let moduleData = self?.deserializeModuleData(moduleDataDict, type: type) else {
                    return nil
                }
                
                            var module = TripModule(id: id, type: type, data: moduleData, position: position)
                module.isLocked = moduleDict["isLocked"] as? Bool ?? false
                module.lockedBy = moduleDict["lockedBy"] as? String
                module.isCompleted = moduleDict["isCompleted"] as? Bool ?? false
                module.createdAt = (moduleDict["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                module.updatedAt = (moduleDict["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                
                return module
            }
            
            let trip = Trip(
                id: data["id"] as? String ?? "",
                title: data["title"] as? String ?? "",
                description: data["description"] as? String ?? "",
                startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                createdBy: data["createdBy"] as? String ?? "",
                participants: data["participants"] as? [String] ?? [],
                modules: modules,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            completion(trip)
        }
    }
    
    func listenToSectionLocks(tripId: String) {
        let lockRef = db.collection("tripLocks").document(tripId)
        
        lockListener = lockRef.addSnapshotListener { [weak self] document, error in
            if let error = error {
                print("Error listening to locks: \(error)")
                return
            }
            
            guard let data = document?.data() else { return }
            
            DispatchQueue.main.async {
                self?.lockedSections = data.compactMapValues { $0 as? String }
            }
        }
    }
    
    func isSectionLocked(moduleId: String, by userId: String) -> Bool {
        // If no lock exists, it's not locked
        guard let lockedBy = lockedSections[moduleId] else { return false }
        // If locked by someone else, it's locked
        return lockedBy != userId
    }
    
    // MARK: - Helper Functions
    private func loadTripFromFirestore(tripId: String) {
        let tripRef = db.collection("trips").document(tripId)
        tripRef.getDocument { [weak self] document, error in
            if let error = error {
                print("❌ Error loading trip from Firestore: \(error)")
                return
            }
            
            guard let data = document?.data() else {
                print("❌ No data found for trip: \(tripId)")
                return
            }
            
            // Parse the trip data
            let modulesData = data["modules"] as? [[String: Any]] ?? []
            let modules = modulesData.compactMap { moduleDict -> TripModule? in
                guard let id = moduleDict["id"] as? String,
                      let typeString = moduleDict["type"] as? String,
                      let type = ModuleType(rawValue: typeString),
                      let position = moduleDict["position"] as? Int else {
                    return nil
                }
                
                let moduleDataDict = moduleDict["data"] as? [String: Any] ?? [:]
                guard let moduleData = self?.deserializeModuleData(moduleDataDict, type: type) else {
                    return nil
                }
                
                var module = TripModule(id: id, type: type, data: moduleData, position: position)
                module.isLocked = moduleDict["isLocked"] as? Bool ?? false
                module.lockedBy = moduleDict["lockedBy"] as? String
                module.isCompleted = moduleDict["isCompleted"] as? Bool ?? false
                module.createdAt = (moduleDict["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                module.updatedAt = (moduleDict["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
                
                return module
            }
            
            let trip = Trip(
                id: data["id"] as? String ?? "",
                title: data["title"] as? String ?? "",
                description: data["description"] as? String ?? "",
                startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                createdBy: data["createdBy"] as? String ?? "",
                participants: data["participants"] as? [String] ?? [],
                modules: modules,
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            
            // Update local trips array
            DispatchQueue.main.async {
                if let tripIndex = self?.trips.firstIndex(where: { $0.id == tripId }) {
                    self?.trips[tripIndex] = trip
                } else {
                    self?.trips.append(trip)
                }
            }
        }
    }
    
    // MARK: - Cleanup
    func stopListening() {
        tripListener?.remove()
        lockListener?.remove()
        tripListener = nil
        lockListener = nil
    }
    
    deinit {
        stopListening()
    }
}
