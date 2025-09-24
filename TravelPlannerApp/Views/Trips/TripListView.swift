import SwiftUI

private let abbreviatedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()

struct TripListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var syncService = RealtimeSyncService()
    @State private var showingCreateTrip = false
    @State private var showingJoinTrip = false
    @State private var showingUserSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack {
                    if syncService.trips.isEmpty {
                        Spacer()
                            .frame(height: 30)
                            .padding(.top, 100)
                        VStack(spacing: 24) {
                            VStack(spacing: 12) {
                                Text("No trips yet")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("Create your first trip to start planning!")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            VStack(spacing: 16) {
                                Button(action: {
                                    showingCreateTrip = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Create Your First Trip")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: 200)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                }
                                
                                Button(action: {
                                    showingJoinTrip = true
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.badge.plus")
                                        Text("Join Existing Trip")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: 200)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(Array(syncService.trips.enumerated()), id: \.element.id) { index, trip in
                                NavigationLink(destination: TripDetailView(trip: trip)) {
                                    TripRowView(trip: trip, index: index)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                .padding(.bottom, 40) // Extra bottom padding to ensure content is accessible
            }
            .scrollIndicators(.visible)
            .navigationTitle("My Trips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button("Sign Out") {
                            authManager.signOut()
                        }
                        
                        Button(action: {
                            showingUserSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingJoinTrip = true
                        }) {
                            Image(systemName: "person.badge.plus")
                        }
                        
                        Button(action: {
                            showingCreateTrip = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateTrip) {
            CreateTripView()
                .environmentObject(syncService)
        }
        .sheet(isPresented: $showingJoinTrip) {
            JoinTripView()
                .environmentObject(syncService)
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showingUserSettings) {
            UserSettingsView()
                .environmentObject(authManager)
        }
        .onAppear {
            print("📱 TripListView appeared on device: \(UIDevice.current.model)")
            if let userId = authManager.currentUser?.id {
                print("👤 Loading trips for user: \(userId)")
                syncService.loadUserTrips(userId: userId)
            } else {
                print("⚠️ Warning: No current user ID available in TripListView")
                // Don't crash, just show empty state
            }
        }
    }
}

struct TripRowView: View {
    let trip: Trip
    let index: Int
    
    private var tripColor: Color {
        let colors: [Color] = [
            .blue, .green, .orange, .red, .purple, .indigo, .teal, .pink, .mint, .cyan
        ]
        return colors[index % colors.count]
    }
    
    // Generate a consistent emoji based on trip index to avoid repetition
    private var tripEmoji: String {
        let emojis = ["✈️", "🏖️", "🗺️", "🏔️", "🌊", "🏛️", "🎡", "🎢", "🏰", "🌅", "🌄", "🏕️", "🚢", "🚂", "🚁", "🎪"]
        return emojis[index % emojis.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(trip.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            HStack {
                Text(trip.startDate, formatter: abbreviatedDateFormatter)
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(trip.endDate, formatter: abbreviatedDateFormatter)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            if !trip.description.isEmpty {
                Text(trip.description)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.title3)
                        .foregroundColor(tripColor)
                    Text("\(trip.participants.count) participant\(trip.participants.count == 1 ? "" : "s")")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(tripEmoji)
                        .font(.title2)
                    Text("\(trip.modules.count) module\(trip.modules.count == 1 ? "" : "s")")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tripColor.opacity(0.1))
                .shadow(color: tripColor.opacity(0.3), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(tripColor.opacity(0.4), lineWidth: 1.5)
        )
    }
}
