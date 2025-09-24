import SwiftUI

struct AddModuleView: View {
    let tripId: String
    let currentModules: [TripModule]
    let onModuleAdded: (TripModule) -> Void
    @EnvironmentObject var syncService: RealtimeSyncService
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedModuleType: ModuleType = .flight
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add Module")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Choose what type of module to add to your trip")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(ModuleType.allCases.filter { $0 != .cost }, id: \.self) { moduleType in
                        ModuleTypeCard(
                            moduleType: moduleType,
                            isSelected: selectedModuleType == moduleType
                        ) {
                            selectedModuleType = moduleType
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    addModule()
                }) {
                    Text("Add \(selectedModuleType.displayName)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addModule() {
        let moduleData: ModuleData
        let position = currentModules.count
        
        switch selectedModuleType {
        case .flight:
            moduleData = .flight(FlightData())
        case .hotel:
            moduleData = .hotel(HotelData())
        case .transportation:
            moduleData = .transportation(TransportationData())
        case .restaurant:
            moduleData = .restaurant(RestaurantData())
        case .activity:
            moduleData = .activity(ActivityData())
        case .cost:
            moduleData = .cost(CostData())
        case .toBring:
            moduleData = .toBring(ToBringData())
        }
        
        let module = TripModule(type: selectedModuleType, data: moduleData, position: position)
        
        // Call the callback to optimistically update the parent view
        onModuleAdded(module)
        
        // Then update Firestore
        syncService.addModule(to: tripId, module: module)
        dismiss()
    }
}

struct ModuleTypeCard: View {
    let moduleType: ModuleType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: moduleIcon)
                    .font(.system(size: 40))
                    .foregroundColor(moduleColor)
                
                Text(moduleType.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(isSelected ? moduleColor.opacity(0.2) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? moduleColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var moduleIcon: String {
        switch moduleType {
        case .flight: return "airplane.departure"
        case .hotel: return "bed.double"
        case .transportation: return "car"
        case .restaurant: return "fork.knife"
        case .activity: return "figure.hiking"
        case .cost: return "dollarsign.circle"
        case .toBring: return "checkmark.circle"
        }
    }
    
    private var moduleColor: Color {
        switch moduleType {
        case .flight: return .green
        case .hotel: return .orange
        case .transportation: return .blue
        case .restaurant: return .red
        case .activity: return .purple
        case .cost: return .blue
        case .toBring: return .teal
        }
    }
}
