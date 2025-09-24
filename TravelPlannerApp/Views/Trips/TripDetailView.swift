import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var syncService = RealtimeSyncService()
    @StateObject private var invitationService = InvitationService()
    
    @State private var showingAddModule = false
    @State private var showingInvite = false
    @State private var inviteCode: String?
    @State private var modules: [TripModule] = []
    @State private var lastLocalUpdate: Date = Date()
    @State private var isPerformingLocalOperation: Bool = false
    
    var sortedModules: [TripModule] {
        modules.sorted { module1, module2 in
            // Cost modules always at bottom
            if module1.type == .cost && module2.type != .cost {
                return false
            }
            if module1.type != .cost && module2.type == .cost {
                return true
            }
            return module1.position < module2.position
        }
    }
    
    // Computed property for cost summary
    var costSummary: (totalCost: Double, itemsWithPrice: Int, totalItems: Int) {
        var totalCost: Double = 0.0
        var itemsWithPrice = 0
        var totalItems = 0
        
        for module in modules {
            totalItems += 1
            
            switch module.data {
            case .flight(let flightData):
                if let cost = flightData.cost, cost > 0 {
                    totalCost += cost
                    itemsWithPrice += 1
                }
            case .hotel(let hotelData):
                if let cost = hotelData.cost, cost > 0 {
                    totalCost += cost
                    itemsWithPrice += 1
                }
            case .transportation(let transportData):
                if let cost = transportData.cost, cost > 0 {
                    totalCost += cost
                    itemsWithPrice += 1
                }
            case .restaurant(let restaurantData):
                if let cost = restaurantData.cost, cost > 0 {
                    totalCost += cost
                    itemsWithPrice += 1
                }
            case .activity(let activityData):
                if let cost = activityData.cost, cost > 0 {
                    totalCost += cost
                    itemsWithPrice += 1
                }
            case .cost(_):
                // Skip cost modules in the summary calculation
                break
            case .toBring(_):
                // To Bring modules don't have cost information
                break
            }
        }
        
        return (totalCost, itemsWithPrice, totalItems)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(trip.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingInvite = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                if !trip.description.isEmpty {
                    Text(trip.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Modules List
            if sortedModules.isEmpty {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.blue.opacity(0.6))
                    
                    Text("No modules yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("Add your first module to start planning!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
            } else {
                List {
                    ForEach(sortedModules) { module in
                        ModuleCardView(module: module, tripId: trip.id, currentModules: sortedModules)
                            .environmentObject(syncService)
                            .environmentObject(authManager)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteModule(module)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onMove { from, to in
                        reorderModules(from: from, to: to)
                    }
                    
                    // Cost Summary Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trip Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Cost")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("$\(costSummary.totalCost, specifier: "%.2f")")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Items with prices")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(costSummary.itemsWithPrice) of \(costSummary.totalItems)")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // Dates and Participants below the price
                        HStack {
                            Text(trip.startDate, style: .date)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            if trip.endDate != trip.startDate {
                                Text(" - ")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text(trip.endDate, style: .date)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(trip.participants.count) participant\(trip.participants.count == 1 ? "" : "s")")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        
                        if costSummary.itemsWithPrice == 0 {
                            Text("No prices entered yet. Add costs to your modules to see the total.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.indigo.opacity(0.1))
                            .shadow(color: Color.indigo.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.indigo.opacity(0.4), lineWidth: 1.5)
                    )
                }
                .listStyle(PlainListStyle())
            }
            
            // Add Module Button - Always at bottom
            VStack(spacing: 0) {
                Divider()
                
                Button(action: {
                    showingAddModule = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Module")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete Trip") {
                    deleteTrip()
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingAddModule) {
            AddModuleView(tripId: trip.id, currentModules: modules, onModuleAdded: { newModule in
                // Set flag to prevent real-time updates during local operation
                isPerformingLocalOperation = true
                
                // Optimistically update local state immediately
                modules.append(newModule)
                lastLocalUpdate = Date()
                
                // Reset flag after a longer delay to allow Firestore operation to complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isPerformingLocalOperation = false
                }
            })
            .environmentObject(syncService)
        }
        .sheet(isPresented: $showingInvite) {
            InviteFriendsView(tripId: trip.id, inviteCode: $inviteCode)
                .environmentObject(invitationService)
        }
        .onAppear {
            print("🔄 TripDetailView onAppear - modules count: \(self.modules.count), isPerformingLocalOperation: \(self.isPerformingLocalOperation)")
            
            // Only initialize modules if they're empty (first time appearing)
            if self.modules.isEmpty {
                print("📝 Initializing modules from trip - count: \(trip.modules.count)")
                self.modules = trip.modules
            } else {
                print("✅ Keeping existing modules - count: \(self.modules.count)")
            }
            
            syncService.listenToTripUpdates(tripId: trip.id) { updatedTrip in
                print("📡 Real-time update received - modules count: \(updatedTrip.modules.count), isPerformingLocalOperation: \(self.isPerformingLocalOperation), lastLocalUpdate: \(self.lastLocalUpdate)")
                
                // Only update if we're not performing a local operation
                // AND if the update is newer than our last local update
                if !self.isPerformingLocalOperation && updatedTrip.updatedAt > self.lastLocalUpdate {
                    print("✅ Applying real-time update")
                    self.modules = updatedTrip.modules
                } else {
                    print("❌ Skipping real-time update - isPerformingLocalOperation: \(self.isPerformingLocalOperation), updatedAt: \(updatedTrip.updatedAt), lastLocalUpdate: \(self.lastLocalUpdate)")
                }
            }
        }
        .onDisappear {
            syncService.stopListening()
        }
    }
    
    private func deleteModule(_ module: TripModule) {
        // Set flag to prevent real-time updates during local operation
        isPerformingLocalOperation = true
        
        // Optimistically update local state immediately
        modules.removeAll { $0.id == module.id }
        lastLocalUpdate = Date()
        
        // Then update Firestore
        syncService.deleteModule(tripId: trip.id, moduleId: module.id)
        
        // Reset flag after a longer delay to allow Firestore operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPerformingLocalOperation = false
        }
    }
    
    private func reorderModules(from source: IndexSet, to destination: Int) {
        var updatedModules = sortedModules
        updatedModules.move(fromOffsets: source, toOffset: destination)
        
        // Update positions for all modules
        for (index, module) in updatedModules.enumerated() {
            var updatedModule = module
            updatedModule.position = index
            updatedModules[index] = updatedModule
        }
        
        // Set flag to prevent real-time updates during local operation
        isPerformingLocalOperation = true
        
        // Optimistically update local state immediately
        modules = updatedModules
        lastLocalUpdate = Date()
        
        // Then update Firestore
        syncService.updateModulesBatch(tripId: trip.id, modules: updatedModules)
        
        // Reset flag after a longer delay to allow Firestore operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPerformingLocalOperation = false
        }
    }
    
    private func deleteTrip() {
        // Delete the trip from Firestore
        syncService.deleteTrip(tripId: trip.id)
        
        // Navigate back to trip list
        dismiss()
    }
}
