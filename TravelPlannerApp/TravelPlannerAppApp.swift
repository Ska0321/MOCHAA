import SwiftUI
import Firebase
import GoogleSignIn

@main
struct TravelPlannerAppApp: App {
    
    @StateObject private var authManager = AuthenticationManager()
    
    init() {
        // Configure Firebase with error handling
        do {
            FirebaseApp.configure()
            print("✅ Firebase configured successfully")
        } catch {
            print("❌ Firebase configuration failed: \(error)")
            // Don't crash the app, just log the error
        }
        
        // Configure Google Sign-In with error handling
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientId = plist["CLIENT_ID"] as? String {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
            print("✅ Google Sign-In configured successfully with client ID: \(clientId)")
        } else {
            print("⚠️ Warning: Could not load GoogleService-Info.plist or CLIENT_ID. Google Sign-In will not work.")
        }
        
        // Add device info logging
        print("📱 Device: \(UIDevice.current.model)")
        print("📱 System: \(UIDevice.current.systemVersion)")
        print("📱 App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
