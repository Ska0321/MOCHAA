import SwiftUI

struct CreateTripView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var syncService: RealtimeSyncService
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7) // Default 1 week
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: geometry.size.width > 768 ? 40 : 30) {
                        // Header
                        VStack(spacing: geometry.size.width > 768 ? 24 : 16) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: geometry.size.width > 768 ? 80 : 60))
                                .foregroundColor(.blue)
                            
                            Text("Create New Trip")
                                .font(geometry.size.width > 768 ? .system(size: 34, weight: .bold) : .largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Set up your trip details to get started")
                                .font(geometry.size.width > 768 ? .title3 : .body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                        }
                        .padding(.top, geometry.size.width > 768 ? 40 : 20)
                        
                        // Form Fields
                        VStack(spacing: geometry.size.width > 768 ? 28 : 20) {
                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 12 : 8) {
                                Text("Trip Title")
                                    .font(geometry.size.width > 768 ? .title3 : .headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter trip title", text: $title)
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .padding(geometry.size.width > 768 ? 20 : 16)
                                    .background(Color.white)
                                    .cornerRadius(geometry.size.width > 768 ? 16 : 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                            
                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 12 : 8) {
                                Text("Description (Optional)")
                                    .font(geometry.size.width > 768 ? .title3 : .headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter trip description", text: $description, axis: .vertical)
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .padding(geometry.size.width > 768 ? 20 : 16)
                                    .background(Color.white)
                                    .cornerRadius(geometry.size.width > 768 ? 16 : 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                                    .lineLimit(3...6)
                            }
                            .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                            
                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 12 : 8) {
                                Text("Start Date")
                                    .font(geometry.size.width > 768 ? .title3 : .headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .padding(geometry.size.width > 768 ? 20 : 16)
                                    .background(Color.white)
                                    .cornerRadius(geometry.size.width > 768 ? 16 : 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                            
                            VStack(alignment: .leading, spacing: geometry.size.width > 768 ? 12 : 8) {
                                Text("End Date")
                                    .font(geometry.size.width > 768 ? .title3 : .headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .padding(geometry.size.width > 768 ? 20 : 16)
                                    .background(Color.white)
                                    .cornerRadius(geometry.size.width > 768 ? 16 : 12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                        }
                        
                        // Create Button - Fixed at bottom
                        Button(action: {
                            createTrip()
                        }) {
                            HStack(spacing: geometry.size.width > 768 ? 16 : 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: geometry.size.width > 768 ? 20 : 16))
                                Text("Create Trip")
                                    .font(geometry.size.width > 768 ? .title3 : .body)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(geometry.size.width > 768 ? 20 : 16)
                            .background(
                                RoundedRectangle(cornerRadius: geometry.size.width > 768 ? 16 : 12)
                                    .fill(title.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(title.isEmpty)
                        .padding(.horizontal, geometry.size.width > 768 ? 40 : 20)
                        .padding(.top, geometry.size.width > 768 ? 30 : 20)
                        .padding(.bottom, max(geometry.size.width > 768 ? 60 : 40, geometry.safeAreaInsets.bottom + 20))
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollIndicators(.visible)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func createTrip() {
        guard let userId = authManager.currentUser?.id else { 
            print("Error: No current user ID available")
            return 
        }
        
        print("Creating trip with user ID: \(userId)")
        
        let trip = Trip(
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            createdBy: userId
        )
        
        print("Trip created with ID: \(trip.id)")
        syncService.createTrip(trip)
        dismiss()
    }
}
