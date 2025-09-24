import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if hasError {
                ErrorView(message: errorMessage) {
                    hasError = false
                    errorMessage = ""
                }
            } else if authManager.isAuthenticated {
                TripListView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            print("📱 ContentView appeared on device: \(UIDevice.current.model)")
            print("📱 System version: \(UIDevice.current.systemVersion)")
            print("🔍 Authentication state: \(authManager.isAuthenticated)")
            print("👤 Current user: \(authManager.currentUser?.username ?? "None")")
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            print("🔄 Authentication state changed: \(isAuthenticated)")
            if isAuthenticated {
                print("✅ User is now authenticated!")
                print("👤 User: \(authManager.currentUser?.username ?? "Unknown")")
            } else {
                print("❌ User is not authenticated")
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
