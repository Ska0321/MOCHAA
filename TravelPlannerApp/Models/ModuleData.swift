import Foundation

enum ModuleData: Codable, Equatable {
    case flight(FlightData)
    case hotel(HotelData)
    case transportation(TransportationData)
    case restaurant(RestaurantData)
    case activity(ActivityData)
    case cost(CostData)
    case toBring(ToBringData)
}

struct FlightData: Codable, Equatable {
    var flightNumber: String
    var departureDate: Date
    var departureTime: Date
    var departureAirport: String
    var arrivalAirport: String
    var cost: Double?
    var notes: String
    var isBooked: Bool
    var bookingReference: String
    
    init(flightNumber: String = "", departureDate: Date = Date(), departureTime: Date = Date(), departureAirport: String = "", arrivalAirport: String = "", cost: Double? = nil, notes: String = "", isBooked: Bool = false, bookingReference: String = "") {
        self.flightNumber = flightNumber
        self.departureDate = departureDate
        self.departureTime = departureTime
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.cost = cost
        self.notes = notes
        self.isBooked = isBooked
        self.bookingReference = bookingReference
    }
}

struct HotelData: Codable, Equatable {
    var hotelName: String
    var checkInDate: Date
    var checkOutDate: Date
    var roomType: String
    var address: String
    var cost: Double?
    var notes: String
    var isBooked: Bool
    var bookingReference: String
    
    init(hotelName: String = "", checkInDate: Date = Date(), checkOutDate: Date = Date(), roomType: String = "", address: String = "", cost: Double? = nil, notes: String = "", isBooked: Bool = false, bookingReference: String = "") {
        self.hotelName = hotelName
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.roomType = roomType
        self.address = address
        self.cost = cost
        self.notes = notes
        self.isBooked = isBooked
        self.bookingReference = bookingReference
    }
}

struct TransportationData: Codable, Equatable {
    var type: String // car, bus, bike, metro, or custom
    var destination: String
    var departureLocation: String
    var duration: String
    var departureTime: Date
    var arrivalTime: Date
    var startDate: Date
    var cost: Double?
    var notes: String
    var isBooked: Bool
    var bookingReference: String
    
    init(type: String = "", destination: String = "", departureLocation: String = "", duration: String = "", departureTime: Date = Date(), arrivalTime: Date = Date(), startDate: Date = Date(), cost: Double? = nil, notes: String = "", isBooked: Bool = false, bookingReference: String = "") {
        self.type = type
        self.destination = destination
        self.departureLocation = departureLocation
        self.duration = duration
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.startDate = startDate
        self.cost = cost
        self.notes = notes
        self.isBooked = isBooked
        self.bookingReference = bookingReference
    }
}

struct RestaurantData: Codable, Equatable {
    var name: String
    var time: Date
    var startDate: Date
    var hasReservation: Bool
    var reservationName: String
    var cuisine: String
    var rating: Double?
    var cost: Double?
    var notes: String
    
    init(name: String = "", time: Date = Date(), startDate: Date = Date(), hasReservation: Bool = false, reservationName: String = "", cuisine: String = "", rating: Double? = nil, cost: Double? = nil, notes: String = "") {
        self.name = name
        self.time = time
        self.startDate = startDate
        self.hasReservation = hasReservation
        self.reservationName = reservationName
        self.cuisine = cuisine
        self.rating = rating
        self.cost = cost
        self.notes = notes
    }
}

struct CostData: Codable, Equatable {
    var totalCost: Double
    var breakdown: [CostItem]
    var isBooked: Bool
    var bookingReference: String
    
    init(totalCost: Double = 0.0, breakdown: [CostItem] = [], isBooked: Bool = false, bookingReference: String = "") {
        self.totalCost = totalCost
        self.breakdown = breakdown
        self.isBooked = isBooked
        self.bookingReference = bookingReference
    }
}

struct ActivityData: Codable, Equatable {
    var name: String
    var type: String // sightseeing, adventure, cultural, shopping, etc.
    var location: String
    var address: String
    var startDate: Date
    var startTime: Date
    var endTime: Date
    var duration: String
    var cost: Double?
    var notes: String
    var isBooked: Bool
    var bookingReference: String
    
    init(name: String = "", type: String = "", location: String = "", address: String = "", startDate: Date = Date(), startTime: Date = Date(), endTime: Date = Date(), duration: String = "", cost: Double? = nil, notes: String = "", isBooked: Bool = false, bookingReference: String = "") {
        self.name = name
        self.type = type
        self.location = location
        self.address = address
        self.startDate = startDate
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.cost = cost
        self.notes = notes
        self.isBooked = isBooked
        self.bookingReference = bookingReference
    }
}

struct CostItem: Identifiable, Codable, Equatable {
    let id: String
    let moduleId: String
    let description: String
    let amount: Double
    
    init(id: String = UUID().uuidString, moduleId: String, description: String, amount: Double) {
        self.id = id
        self.moduleId = moduleId
        self.description = description
        self.amount = amount
    }
}

struct ToBringData: Codable, Equatable {
    var title: String
    var items: [ToBringItem]
    var notes: String
    
    init(title: String = "", items: [ToBringItem] = [], notes: String = "") {
        self.title = title
        self.items = items
        self.notes = notes
    }
}

struct ToBringItem: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var isChecked: Bool
    var category: String // clothing, electronics, toiletries, documents, etc.
    var notes: String
    
    init(id: String = UUID().uuidString, name: String, isChecked: Bool = false, category: String = "general", notes: String = "") {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.category = category
        self.notes = notes
    }
}
