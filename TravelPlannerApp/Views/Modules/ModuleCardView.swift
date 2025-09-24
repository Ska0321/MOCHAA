import SwiftUI

struct ModuleCardView: View {
    let module: TripModule
    let tripId: String
    let currentModules: [TripModule]
    @EnvironmentObject var syncService: RealtimeSyncService
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showingDetail = false
    
    var isLocked: Bool {
        guard let userId = authManager.currentUser?.id else { return false }
        // Check if this module is locked by someone else
        return syncService.isSectionLocked(moduleId: module.id, by: userId)
    }
    
    var isLockedByMe: Bool {
        guard let userId = authManager.currentUser?.id else { return false }
        // Check if this module is locked by me
        return syncService.lockedSections[module.id] == userId
    }
    
    var lockIndicator: some View {
        Group {
            if isLockedByMe {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Editing...")
                }
                .font(.caption)
                .foregroundColor(.orange)
            } else if isLocked {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Locked by other user")
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        }
    }
    
    // Helper computed property for date formatting
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    // Helper computed property for time formatting
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    // Module color based on type
    private var moduleColor: Color {
        switch module.type {
        case .flight:
            return .blue
        case .hotel:
            return .green
        case .transportation:
            return .orange
        case .restaurant:
            return .red
        case .activity:
            return .purple
        case .cost:
            return .indigo
        case .toBring:
            return .teal
        }
    }
    
    // Dynamic title based on user-entered data
    private var dynamicTitle: String {
        switch module.data {
        case .hotel:
            // Always show "Hotel" for hotel modules
            return "Hotel"
        case .transportation(let transportData):
            // Use the transportation type if available, otherwise fall back to "Transportation"
            return transportData.type.isEmpty ? "Transportation" : transportData.type
        case .activity(let activityData):
            // Use the activity name if available, otherwise fall back to "Activity"
            return activityData.name.isEmpty ? "Activity" : activityData.name
        case .toBring(let toBringData):
            // Use the to bring title if available, otherwise fall back to "To Bring"
            return toBringData.title.isEmpty ? "To Bring" : toBringData.title
        default:
            // For other module types, use the default display name
            return module.type.displayName
        }
    }
    
    var moduleCoverContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header with module type, lock indicator, and completion status
            HStack {
                HStack(spacing: 4) {
                    Text(dynamicTitle)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(module.isCompleted ? .secondary : .primary)
                    
                    if module.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                Spacer()
                lockIndicator
            }
            
            // Dynamic content that grows based on available data
            if hasModuleContent {
                VStack(alignment: .leading, spacing: 4) {
                    // Main content section
                    VStack(alignment: .leading, spacing: 4) {
                        switch module.data {
                        case .flight(let flightData):
                            // Flight information - grows with content
                            if !flightData.flightNumber.isEmpty {
                                Text("✈️ \(flightData.flightNumber)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                            
                            // Airport route - this is the key dynamic element
                            if !flightData.departureAirport.isEmpty && !flightData.arrivalAirport.isEmpty {
                                Text("🛫 \(flightData.departureAirport) → \(flightData.arrivalAirport)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    .lineLimit(1)
                            } else if !flightData.departureAirport.isEmpty {
                                Text("🛫 From: \(flightData.departureAirport)")
                                    .font(.body)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            } else if !flightData.arrivalAirport.isEmpty {
                                Text("🛬 To: \(flightData.arrivalAirport)")
                                    .font(.body)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                            
                            // Date and time
                            if flightData.departureDate != Date() {
                                HStack {
                                    Text("📅 \(dateFormatter.string(from: flightData.departureDate))")
                                        .font(.subheadline)
                                        .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    
                                    if flightData.departureTime != Date() {
                                        Text("🕐 \(timeFormatter.string(from: flightData.departureTime))")
                                            .font(.subheadline)
                                            .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    }
                                }
                            }
                            
                        case .hotel(let hotelData):
                            // Hotel information
                            if !hotelData.hotelName.isEmpty {
                                Text("🏨 \(hotelData.hotelName)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                            
                            // Date
                            if hotelData.checkInDate != Date() {
                                HStack {
                                    Text("📅 \(dateFormatter.string(from: hotelData.checkInDate))")
                                        .font(.subheadline)
                                        .foregroundColor(module.isCompleted ? .secondary : .primary)
                                }
                            }
                            
                        case .transportation(let transportData):
                            // Destination (vital item)
                            if !transportData.destination.isEmpty {
                                Text("📍 \(transportData.destination)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                            
                            // Date and time
                            if transportData.startDate != Date() {
                                HStack {
                                    Text("📅 \(dateFormatter.string(from: transportData.startDate))")
                                        .font(.subheadline)
                                        .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    
                                    if transportData.departureTime != Date() {
                                        Text("🕐 \(timeFormatter.string(from: transportData.departureTime))")
                                            .font(.subheadline)
                                            .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    }
                                }
                            }
                            
                        case .restaurant(let restaurantData):
                            // Restaurant name
                            if !restaurantData.name.isEmpty {
                                Text("🍽️ \(restaurantData.name)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    .lineLimit(1)
                            }
                            
                            // Date and time
                            if restaurantData.startDate != Date() {
                                HStack {
                                    Text("📅 \(dateFormatter.string(from: restaurantData.startDate))")
                                        .font(.subheadline)
                                        .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    
                                    if restaurantData.time != Date() {
                                        Text("🕐 \(timeFormatter.string(from: restaurantData.time))")
                                            .font(.subheadline)
                                            .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    }
                                }
                            }
                            
                        case .activity(let activityData):
                            // Location (vital item)
                            if !activityData.location.isEmpty {
                                Text("📍 \(activityData.location)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                            
                            // Date and time
                            if activityData.startDate != Date() {
                                HStack {
                                    Text("📅 \(dateFormatter.string(from: activityData.startDate))")
                                        .font(.subheadline)
                                        .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    
                                    if activityData.startTime != Date() {
                                        Text("🕐 \(timeFormatter.string(from: activityData.startTime))")
                                            .font(.subheadline)
                                            .foregroundColor(module.isCompleted ? .secondary : .primary)
                                    }
                                }
                            }
                            
                        case .cost(let costData):
                            // Total cost
                            Text("💰 $\(String(format: "%.2f", costData.totalCost))")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(module.isCompleted ? .secondary : .primary)
                            
                            // Item count
                            if !costData.breakdown.isEmpty {
                                Text("📋 \(costData.breakdown.count) item\(costData.breakdown.count == 1 ? "" : "s")")
                                    .font(.body)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                        
                        case .toBring(let toBringData):
                            // Item count
                            if !toBringData.items.isEmpty {
                                let checkedCount = toBringData.items.filter { $0.isChecked }.count
                                Text("📋 \(checkedCount)/\(toBringData.items.count) items")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(module.isCompleted ? .secondary : .primary)
                            }
                            
                            // Show first few items
                            if !toBringData.items.isEmpty {
                                let displayItems = Array(toBringData.items.prefix(2))
                                ForEach(displayItems) { item in
                                    HStack {
                                        Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(item.isChecked ? .green : .gray)
                                        Text(item.name)
                                            .font(.subheadline)
                                            .foregroundColor(module.isCompleted ? .secondary : .primary)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                }
                                
                                if toBringData.items.count > 2 {
                                    Text("+ \(toBringData.items.count - 2) more items")
                                        .font(.caption)
                                        .foregroundColor(module.isCompleted ? .secondary : .secondary)
                                }
                            }
                        }
                    }
                    

                }
            } else {
                // Minimal placeholder when no content
                Text("Tap to add \(module.type.displayName.lowercased()) details")
                    .font(.subheadline)
                    .foregroundColor(module.isCompleted ? .secondary.opacity(0.7) : .secondary)
                    .italic()
            }
        }
        .padding(.leading, 8)
    }
    
    var hasModuleContent: Bool {
        switch module.data {
        case .flight(let data):
            return !data.flightNumber.isEmpty || !data.departureAirport.isEmpty || !data.arrivalAirport.isEmpty || data.cost != nil
        case .hotel(let data):
            return !data.hotelName.isEmpty || !data.roomType.isEmpty || !data.address.isEmpty || data.cost != nil || data.checkInDate != Date()
        case .transportation(let data):
            return !data.type.isEmpty || !data.departureLocation.isEmpty || !data.destination.isEmpty || data.cost != nil
        case .restaurant(let data):
            return !data.name.isEmpty || !data.cuisine.isEmpty || data.cost != nil
        case .activity(let data):
            return !data.name.isEmpty || !data.type.isEmpty || !data.location.isEmpty || data.cost != nil
        case .cost(let data):
            return data.totalCost > 0 || !data.breakdown.isEmpty
        case .toBring(let data):
            return !data.title.isEmpty || !data.items.isEmpty || !data.notes.isEmpty
        }
    }
    
    private func getNotes(from moduleData: ModuleData) -> String? {
        switch moduleData {
        case .flight(let data): return data.notes
        case .hotel(let data): return data.notes
        case .transportation(let data): return data.notes
        case .restaurant(let data): return data.notes
        case .activity(let data): return data.notes
        case .cost: return nil // CostData doesn't have notes property
        case .toBring(let data): return data.notes
        }
    }
    
    // Helper function to get booking status for any module type
    private func getBookingStatus(from moduleData: ModuleData) -> (isBooked: Bool, text: String) {
        switch moduleData {
        case .flight(let data):
            return (data.isBooked, data.isBooked ? "Booked" : "Not Booked")
        case .hotel(let data):
            return (data.isBooked, data.isBooked ? "Booked" : "Not Booked")
        case .transportation(let data):
            return (data.isBooked, data.isBooked ? "Booked" : "Not Booked")
        case .restaurant(let data):
            return (data.hasReservation, data.hasReservation ? "Booked" : "Not Booked")
        case .activity(let data):
            return (data.isBooked, data.isBooked ? "Booked" : "Not Booked")
        case .cost(let data):
            return (data.isBooked, data.isBooked ? "Booked" : "Not Booked")
        case .toBring(let data):
            // For To Bring, show completion status instead of booking status
            let checkedCount = data.items.filter { $0.isChecked }.count
            let totalCount = data.items.count
            if totalCount == 0 {
                return (false, "Empty")
            } else if checkedCount == totalCount {
                return (true, "Complete")
            } else {
                return (false, "\(checkedCount)/\(totalCount)")
            }
        }
    }
    
    var body: some View {
        HStack {
            NavigationLink(destination: ModuleDetailView(module: module, tripId: tripId)
                .environmentObject(syncService)
                .environmentObject(authManager)
                .onAppear {
                    if let userId = authManager.currentUser?.id {
                        syncService.lockSection(tripId: tripId, moduleId: module.id, userId: userId)
                    }
                }
                .onDisappear {
                    if let userId = authManager.currentUser?.id {
                        syncService.unlockSection(tripId: tripId, moduleId: module.id, userId: userId)
                    }
                }
            ) {
                VStack(spacing: 0) {
                    // Main module content
                    HStack {
                        moduleCoverContent
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Booking status indicator on the right
                        VStack {
                            let bookingStatus = getBookingStatus(from: module.data)
                            Text(bookingStatus.text)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(module.isCompleted ? .secondary : (bookingStatus.isBooked ? .primary : .secondary))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(module.isCompleted ? Color.secondary.opacity(0.1) : (bookingStatus.isBooked ? Color.primary.opacity(0.1) : Color.secondary.opacity(0.1)))
                                )
                        }
                        .frame(width: 85, alignment: .trailing)
                    }
                    .padding()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Done button
            Button(action: {
                syncService.toggleModuleCompletion(tripId: tripId, moduleId: module.id, currentModules: currentModules)
            }) {
                Image(systemName: module.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(module.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(module.isCompleted ? Color.gray.opacity(0.1) : moduleColor.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(module.isCompleted ? Color.gray.opacity(0.3) : moduleColor.opacity(0.4), lineWidth: 1.5)
        )
        .shadow(color: moduleColor.opacity(0.3), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: module.isCompleted)
        .opacity(module.isCompleted ? 0.7 : 1.0)
    }
}

// MARK: - Cover Views with Dynamic Sizing
struct FlightCoverView: View {
    let data: FlightData
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var hasContent: Bool {
        !data.flightNumber.isEmpty || !data.departureAirport.isEmpty || !data.arrivalAirport.isEmpty
    }
    
    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                if !data.flightNumber.isEmpty {
                    Text("Flight \(data.flightNumber)")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                if !data.departureAirport.isEmpty || !data.arrivalAirport.isEmpty {
                    HStack {
                        Text(data.departureAirport.isEmpty ? "From" : data.departureAirport)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                        Text(data.arrivalAirport.isEmpty ? "To" : data.arrivalAirport)
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                }
                
                if data.departureDate != Date() || data.departureTime != Date() {
                    HStack {
                        Text("📅")
                        Text(data.departureDate, style: .date)
                        if data.departureTime != Date() {
                            Text("• \(timeFormatter.string(from: data.departureTime))")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        } else {
            Text("Tap to add flight details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

struct HotelCoverView: View {
    let data: HotelData
    
    var hasContent: Bool {
        !data.hotelName.isEmpty || data.checkInDate != Date() || data.checkOutDate != Date()
    }
    
    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                if !data.hotelName.isEmpty {
                    Text(data.hotelName)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                if data.checkInDate != Date() || data.checkOutDate != Date() {
                    HStack {
                        Text("📅")
                        Text(data.checkInDate, style: .date)
                        Text("→")
                        Text(data.checkOutDate, style: .date)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        } else {
            Text("Tap to add hotel details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

struct TransportationCoverView: View {
    let data: TransportationData
    
    var hasContent: Bool {
        !data.type.isEmpty || !data.destination.isEmpty || !data.duration.isEmpty
    }
    
    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if !data.type.isEmpty {
                        Text(data.type.capitalized)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    
                    if !data.destination.isEmpty {
                        Text("to \(data.destination)")
                            .font(.title3)
                    }
                }
                
                if !data.duration.isEmpty {
                    Text("Duration: \(data.duration)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if data.startDate != Date() {
                    HStack {
                        Text("📅")
                        Text(data.startDate, style: .date)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        } else {
            Text("Tap to add transportation details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

struct RestaurantCoverView: View {
    let data: RestaurantData
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var hasContent: Bool {
        !data.name.isEmpty || data.time != Date() || !data.cuisine.isEmpty
    }
    
    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                if !data.name.isEmpty {
                    Text(data.name)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                if !data.cuisine.isEmpty {
                    Text(data.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if data.time != Date() {
                    Text(timeFormatter.string(from: data.time))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if data.startDate != Date() {
                    HStack {
                        Text("📅")
                        Text(data.startDate, style: .date)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        } else {
            Text("Tap to add restaurant details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

struct ActivityCoverView: View {
    let data: ActivityData
    
    var hasContent: Bool {
        !data.name.isEmpty || !data.location.isEmpty || !data.type.isEmpty
    }
    
    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                if !data.name.isEmpty {
                    Text(data.name)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                if !data.type.isEmpty {
                    Text(data.type.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !data.location.isEmpty {
                    Text(data.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if data.startDate != Date() {
                    HStack {
                        Text("📅")
                        Text(data.startDate, style: .date)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
        } else {
            Text("Tap to add activity details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}

struct CostCoverView: View {
    let data: CostData
    
    var hasContent: Bool {
        data.totalCost > 0 || !data.breakdown.isEmpty
    }
    
    var body: some View {
        if hasContent {
            VStack(alignment: .leading, spacing: 6) {
                Text("Total: $\(data.totalCost, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.medium)
                
                if !data.breakdown.isEmpty {
                    Text("\(data.breakdown.count) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        } else {
            Text("Tap to add cost details")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
        }
    }
}
