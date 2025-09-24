import SwiftUI

struct ModuleDetailView: View {
    let module: TripModule
    let tripId: String
    @EnvironmentObject var syncService: RealtimeSyncService
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var editedModule: TripModule
    @State private var showingSaveAlert = false
    @State private var showingCancelAlert = false
    
    init(module: TripModule, tripId: String) {
        self.module = module
        self.tripId = tripId
        self._editedModule = State(initialValue: module)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Module-specific detail view
                    moduleDetailContent
                }
                .padding()
                .padding(.bottom, 40) // Extra bottom padding to ensure content is accessible
            }
            .scrollIndicators(.visible)
            .navigationTitle(dynamicTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if hasChanges {
                            showingCancelAlert = true
                        } else {
                            unlockAndDismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!hasChanges)
                }
            }
        }
        .alert("Save Changes?", isPresented: $showingSaveAlert) {
            Button("Save") {
                saveChanges()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to save your changes?")
        }
        .alert("Discard Changes?", isPresented: $showingCancelAlert) {
            Button("Discard", role: .destructive) {
                unlockAndDismiss()
            }
            Button("Keep Editing", role: .cancel) { }
        } message: {
            Text("Your changes will be lost.")
        }
        .onDisappear {
            // Ensure module is unlocked when view disappears
            unlockAndDismiss()
        }
    }
    
    private var hasChanges: Bool {
        // Compare edited module with original module
        return editedModule.data != module.data
    }
    
    private var dynamicTitle: String {
        switch editedModule.data {
        case .hotel(let hotelData):
            // Use the hotel name if available, otherwise fall back to "Hotel"
            return hotelData.hotelName.isEmpty ? "Hotel" : hotelData.hotelName
        case .transportation(let transportData):
            // Use the transportation type if available, otherwise fall back to "Transportation"
            return transportData.type.isEmpty ? "Transportation" : transportData.type
        case .activity(let activityData):
            // Use the activity name if available, otherwise fall back to "Activity"
            return activityData.name.isEmpty ? "Activity" : activityData.name
        case .toBring(let toBringData):
            // Use the list title if available, otherwise fall back to "To Bring"
            return toBringData.title.isEmpty ? "To Bring" : toBringData.title
        default:
            // For other module types, use the default display name
            return editedModule.type.displayName
        }
    }
    
    @ViewBuilder
    private var moduleDetailContent: some View {
        switch editedModule.data {
        case .flight(let flightData):
            FlightDetailView(data: Binding(
                get: { 
                    if case .flight(let data) = editedModule.data {
                        return data
                    }
                    return flightData
                },
                set: { newValue in
                    editedModule.data = .flight(newValue)
                }
            ))
        case .hotel(let hotelData):
            HotelDetailView(data: Binding(
                get: { 
                    if case .hotel(let data) = editedModule.data {
                        return data
                    }
                    return hotelData
                },
                set: { newValue in
                    editedModule.data = .hotel(newValue)
                }
            ))
        case .transportation(let transportData):
            TransportationDetailView(data: Binding(
                get: { 
                    if case .transportation(let data) = editedModule.data {
                        return data
                    }
                    return transportData
                },
                set: { newValue in
                    editedModule.data = .transportation(newValue)
                }
            ))
        case .restaurant(let restaurantData):
            RestaurantDetailView(data: Binding(
                get: { 
                    if case .restaurant(let data) = editedModule.data {
                        return data
                    }
                    return restaurantData
                },
                set: { newValue in
                    editedModule.data = .restaurant(newValue)
                }
            ))
        case .activity(let activityData):
            ActivityDetailView(data: Binding(
                get: { 
                    if case .activity(let data) = editedModule.data {
                        return data
                    }
                    return activityData
                },
                set: { newValue in
                    editedModule.data = .activity(newValue)
                }
            ))
        case .cost(let costData):
            CostDetailView(data: Binding(
                get: { 
                    if case .cost(let data) = editedModule.data {
                        return data
                    }
                    return costData
                },
                set: { newValue in
                    editedModule.data = .cost(newValue)
                }
            ))
        case .toBring(let toBringData):
            ToBringDetailView(data: Binding(
                get: { 
                    if case .toBring(let data) = editedModule.data {
                        return data
                    }
                    return toBringData
                },
                set: { newValue in
                    editedModule.data = .toBring(newValue)
                }
            ))
        }
    }
    
    private func saveChanges() {
        print("💾 Saving changes for module: \(editedModule.id)")
        print("💾 Original module data: \(module.data)")
        print("💾 Edited module data: \(editedModule.data)")
        print("💾 Has changes: \(hasChanges)")
        
        // Update the module in the sync service
        syncService.updateModule(tripId: tripId, module: editedModule)
        
        // Unlock the module
        if let userId = authManager.currentUser?.id {
            syncService.unlockSection(tripId: tripId, moduleId: editedModule.id, userId: userId)
        }
        
        dismiss()
    }
    
    private func unlockAndDismiss() {
        print("🔓 Unlocking module: \(editedModule.id)")
        
        // Unlock the module without saving changes
        if let userId = authManager.currentUser?.id {
            syncService.unlockSection(tripId: tripId, moduleId: editedModule.id, userId: userId)
        }
        
        dismiss()
    }
}
