import Foundation
import Firebase
//import FirebaseFirestoreSwift
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthenticationManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // For Sign in with Apple
    private var currentNonce: String?
    
    override init() {
        super.init()
        // Delay authentication check to ensure Firebase is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.checkAuthenticationState()
        }
    }
    
    func checkAuthenticationState() {
        print("🔍 Checking authentication state...")
        if let firebaseUser = Auth.auth().currentUser {
            // User is signed in with Firebase
            print("✅ User authenticated: \(firebaseUser.uid)")
            print("✅ User email: \(firebaseUser.email ?? "No email")")
            loadUserData(firebaseUserId: firebaseUser.uid)
        } else {
            print("ℹ️ No authenticated user found")
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    // MARK: - Email/Password Authentication
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.getUserFriendlyErrorMessage(error)
                    return
                }
                
                guard let firebaseUser = result?.user else { 
                    self?.errorMessage = "Failed to create account. Please try again."
                    return 
                }
                
                let user = User(id: firebaseUser.uid, username: email.components(separatedBy: "@").first ?? email, email: email, isTemporary: false)
                self?.saveUserToFirestore(user: user)
                self?.currentUser = user
                self?.isAuthenticated = true
            }
        }
    }
    
    func signUpWithInviteCode(email: String, password: String, username: String, inviteCode: String, tripId: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.getUserFriendlyErrorMessage(error)
                    return
                }
                
                guard let firebaseUser = result?.user else { 
                    self?.errorMessage = "Failed to create account. Please try again."
                    return 
                }
                
                let user = User(id: firebaseUser.uid, username: username, email: email, isTemporary: false)
                self?.saveUserToFirestore(user: user)
                self?.currentUser = user
                self?.isAuthenticated = true
                
                // Add user to the trip
                self?.addUserToTrip(tripId: tripId, user: user)
            }
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = self?.getUserFriendlyErrorMessage(error)
                    return
                }
                
                guard let firebaseUser = result?.user else { 
                    self?.errorMessage = "Failed to sign in. Please try again."
                    return 
                }
                
                // Load user data from Firestore
                self?.loadUserData(firebaseUserId: firebaseUser.uid)
            }
        }
    }
    
    // MARK: - Sign in with Apple
    func signInWithApple() {
        print("🍎 Starting Apple Sign-In process...")
        isLoading = true
        errorMessage = nil
        
        // Apple Sign-In is always available on iOS 13+
        
        let nonce = randomNonceString()
        currentNonce = nonce
        print("🍎 Generated nonce: \(nonce)")
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() {
        // Check if Google Sign-In is properly configured
        guard GIDSignIn.sharedInstance.configuration != nil else {
            self.errorMessage = "Google Sign-In is not properly configured. Please try email sign-in instead."
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            self.errorMessage = "Could not find root view controller"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Check if user is already signed in
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.isLoading = false
                        self?.errorMessage = "Failed to restore previous sign-in: \(error.localizedDescription)"
                        return
                    }
                    
                    if let user = user {
                        self?.handleGoogleSignInResult(user: user)
                    }
                }
            }
        } else {
            // Perform new sign-in
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let user = result?.user else {
                        self?.errorMessage = "No user data received from Google"
                        return
                    }
                    
                    self?.handleGoogleSignInResult(user: user)
                }
            }
        }
    }
    
    private func handleGoogleSignInResult(user: GIDGoogleUser) {
        guard let idToken = user.idToken?.tokenString else {
            self.errorMessage = "Failed to get Google ID token"
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Firebase authentication failed: \(error.localizedDescription)"
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    self?.errorMessage = "No Firebase user data received"
                    return
                }
                
                let appUser = User(
                    id: firebaseUser.uid,
                    username: firebaseUser.displayName ?? "User",
                    email: firebaseUser.email,
                    isTemporary: false
                )
                
                self?.saveUserToFirestore(user: appUser)
                self?.currentUser = appUser
                self?.isAuthenticated = true
            }
        }
    }
    
    // MARK: - Invitation Code System
    func signInWithInviteCode(code: String, username: String) {
        isLoading = true
        errorMessage = nil
        
        // Check if invite code is valid
        let db = Firestore.firestore()
        db.collection("inviteCodes").document(code).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data(),
                      let tripId = data["tripId"] as? String,
                      let isActive = data["isActive"] as? Bool,
                      isActive else {
                    self?.errorMessage = "Invalid or expired invite code"
                    return
                }
                
                // Create temporary user
                let tempUser = User(username: username, isTemporary: true)
                self?.currentUser = tempUser
                self?.isAuthenticated = true
                
                // Add user to the trip
                self?.addUserToTrip(tripId: tripId, user: tempUser)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            // Also sign out from Google if user was signed in with Google
            if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                GIDSignIn.sharedInstance.signOut()
            }
            
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Account Deletion
    func deleteAccount() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No account found. Please sign in first."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // First, delete user data from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).delete { [weak self] error in
            if let error = error {
                print("❌ Error deleting user data from Firestore: \(error.localizedDescription)")
                // Continue with account deletion even if Firestore deletion fails
            } else {
                print("✅ User data deleted from Firestore")
            }
            
            // Delete user's trips from Firestore
            db.collection("trips")
                .whereField("createdBy", isEqualTo: currentUser.uid)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("❌ Error fetching user trips: \(error.localizedDescription)")
                    } else {
                        let batch = db.batch()
                        querySnapshot?.documents.forEach { document in
                            batch.deleteDocument(document.reference)
                        }
                        batch.commit { error in
                            if let error = error {
                                print("❌ Error deleting user trips: \(error.localizedDescription)")
                            } else {
                                print("✅ User trips deleted from Firestore")
                            }
                        }
                    }
                }
            
            // Delete the Firebase Auth account
            currentUser.delete { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Error deleting Firebase account: \(error.localizedDescription)")
                        let nsError = error as NSError
                        if nsError.code == 17025 { // ERROR_USER_NOT_FOUND
                            self?.errorMessage = "Account not found. It may have already been deleted."
                        } else {
                            self?.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                        }
                    } else {
                        print("✅ Account successfully deleted")
                        
                        // Sign out from Google if user was signed in with Google
                        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                            GIDSignIn.sharedInstance.signOut()
                        }
                        
                        // Clear local state
                        self?.isAuthenticated = false
                        self?.currentUser = nil
                        self?.errorMessage = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadUserData(firebaseUserId: String) {
        print("📊 Loading user data for Firebase user: \(firebaseUserId)")
        let db = Firestore.firestore()
        db.collection("users").document(firebaseUserId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error loading user data: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists {
                    print("✅ Found existing user document in Firestore")
                    if let data = document.data() {
                        let user = User(
                            id: data["id"] as? String ?? "",
                            username: data["username"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            isTemporary: data["isTemporary"] as? Bool ?? false
                        )
                        print("✅ Loaded user: \(user.username) (\(user.email ?? "No email"))")
                        self?.currentUser = user
                        self?.isAuthenticated = true
                    }
                } else {
                    print("ℹ️ No user document found in Firestore, creating new user")
                    // User document doesn't exist in Firestore, but Firebase Auth succeeded
                    // Create a basic user object and authenticate
                    let user = User(
                        id: firebaseUserId,
                        username: Auth.auth().currentUser?.email?.components(separatedBy: "@").first ?? "User",
                        email: Auth.auth().currentUser?.email ?? "",
                        isTemporary: false
                    )
                    print("✅ Created new user: \(user.username) (\(user.email ?? "No email"))")
                    self?.currentUser = user
                    self?.isAuthenticated = true
                    
                    // Try to save the user data to Firestore for future use
                    self?.saveUserToFirestore(user: user)
                }
            }
        }
    }
    
    private func saveUserToFirestore(user: User) {
        let db = Firestore.firestore()
        var userData: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "isTemporary": user.isTemporary
        ]
        
        // Only add email if it exists
        if let email = user.email {
            userData["email"] = email
        }
        
        db.collection("users").document(user.id).setData(userData) { error in
            if let error = error {
                print("Error saving user: \(error)")
            }
        }
    }
    
    private func addUserToTrip(tripId: String, user: User) {
        let db = Firestore.firestore()
        db.collection("trips").document(tripId).updateData([
            "participants": FieldValue.arrayUnion([user.id])
        ])
    }
    
    func joinTripWithoutAccount(inviteCode: String, tripId: String) {
        isLoading = true
        errorMessage = nil
        
        // Create a temporary user with a unique ID
        let temporaryUserId = "temp_\(UUID().uuidString)"
        let temporaryUser = User(
            id: temporaryUserId,
            username: "Guest User",
            email: nil,
            isTemporary: true
        )
        
        // Set the current user to the temporary user
        self.currentUser = temporaryUser
        self.isAuthenticated = true
        
        // Don't add to participants array - this is one-time access
        // Just navigate to the trip view
        
        // Save temporary user to Firestore for session tracking
        saveUserToFirestore(user: temporaryUser)
        
        // Mark as not loading
        self.isLoading = false
        
        // The user will now be authenticated and can access the trip
        // but won't be added to the participants list
    }
    
    // MARK: - Error Handling
    private func getUserFriendlyErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered. Please try signing in instead."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password is too weak. Please choose a stronger password."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email. Please check your email or create a new account."
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled. Please contact support."
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many failed attempts. Please try again later."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your internet connection and try again."
        case AuthErrorCode.operationNotAllowed.rawValue:
            return "Email/password sign-in is not enabled. Please contact support."
        default:
            return "An error occurred. Please try again."
        }
    }
    
    // MARK: - Sign in with Apple Helper Functions
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthenticationManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("🍎 Apple Sign-In authorization completed successfully")
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("🍎 Received Apple ID credential")
            print("🍎 User ID: \(appleIDCredential.user)")
            print("🍎 Email: \(appleIDCredential.email ?? "No email provided")")
            print("🍎 Full Name: \(appleIDCredential.fullName?.givenName ?? "No given name") \(appleIDCredential.fullName?.familyName ?? "No family name")")
            
            guard let nonce = currentNonce else {
                print("❌ Invalid state: A login callback was received, but no login request was sent.")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Invalid state: No nonce found"
                }
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("❌ Unable to fetch identity token")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Unable to fetch identity token"
                }
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("❌ Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Unable to serialize token string"
                }
                return
            }
            
            print("🍎 Successfully obtained Apple ID token")
            
            // Initialize a Firebase credential
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            print("🍎 Created Firebase credential, attempting to sign in...")
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("❌ Firebase authentication failed: \(error.localizedDescription)")
                        
                        // Check for specific Apple Sign-In configuration errors
                        let nsError = error as NSError
                        if nsError.domain == "FIRAuthErrorDomain" {
                            switch nsError.code {
                            case 17007: // ERROR_INVALID_CREDENTIAL
                                self?.errorMessage = "Apple Sign-In is not configured in Firebase. Please contact support or use email sign-in instead."
                            case 17020: // ERROR_OPERATION_NOT_ALLOWED
                                self?.errorMessage = "Apple Sign-In is not enabled. Please contact support or use email sign-in instead."
                            default:
                                self?.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                            }
                        } else {
                            self?.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                        }
                        return
                    }
                    
                    guard let firebaseUser = authResult?.user else {
                        print("❌ No Firebase user data received")
                        self?.errorMessage = "No Firebase user data received"
                        return
                    }
                    
                    print("✅ Firebase authentication successful!")
                    print("✅ Firebase User ID: \(firebaseUser.uid)")
                    print("✅ Firebase Email: \(firebaseUser.email ?? "No email")")
                    
                    // Get user's name from Apple ID credential
                    let fullName = appleIDCredential.fullName
                    let displayName = [fullName?.givenName, fullName?.familyName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    let appUser = User(
                        id: firebaseUser.uid,
                        username: displayName.isEmpty ? "Apple User" : displayName,
                        email: firebaseUser.email,
                        isTemporary: false
                    )
                    
                    print("✅ Created app user: \(appUser.username)")
                    
                    self?.saveUserToFirestore(user: appUser)
                    self?.currentUser = appUser
                    self?.isAuthenticated = true
                    
                    print("✅ Apple Sign-In completed successfully! User is now authenticated.")
                }
            }
        } else {
            print("❌ Authorization credential is not Apple ID credential")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid authorization credential"
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Apple Sign-In failed with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
