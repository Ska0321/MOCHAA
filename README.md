# Travel Planner App

A collaborative real-time travel planning app built with SwiftUI and Firebase.

## Features

### ✅ Implemented
- **User Authentication**: Email/password and Google Sign-In
- **Invitation System**: 6-digit codes for temporary access without accounts
- **Real-time Collaboration**: Live syncing of changes across all users
- **Section Locking**: Prevents conflicts when multiple users edit simultaneously
- **Module System**: Flights, Hotels, Transportation, Restaurants, and Cost tracking
- **Minimalistic UI**: Clean, easy-to-scan interface design

### 🏗️ Architecture
- **SwiftUI** for modern iOS UI
- **Firebase Firestore** for real-time database
- **Firebase Auth** for user management
- **Google Sign-In** for OAuth authentication

## Setup Instructions

### 1. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project called "travel-planner-app"
3. Enable Authentication with Email/Password and Google providers
4. Enable Firestore Database
5. Download `GoogleService-Info.plist` and replace the placeholder file

### 2. Google Sign-In Setup
1. In Firebase Console, go to Authentication > Sign-in method
2. Enable Google sign-in
3. Note the iOS URL scheme from the downloaded `GoogleService-Info.plist`
4. Update the URL scheme in `Info.plist` if needed

### 3. Xcode Setup
1. Open `TravelPlannerApp.xcodeproj` in Xcode
2. Select your development team in project settings
3. Update bundle identifier if needed
4. Add Firebase SDK dependencies via Swift Package Manager:
   - Firebase iOS SDK: `https://github.com/firebase/firebase-ios-sdk`
   - Google Sign-In: `https://github.com/google/GoogleSignIn-iOS`

### 4. Firebase Security Rules
Add these Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Trip access for participants
    match /trips/{tripId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
    
    // Invite codes are readable by authenticated users
    match /inviteCodes/{code} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Trip locks for real-time collaboration
    match /tripLocks/{tripId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## App Flow

1. **Authentication**: Users can sign in with email/password, Google, or use an invite code
2. **Trip List**: View all trips the user is participating in
3. **Trip Detail**: See modules in a clean, scannable list format
4. **Module Editing**: Lock sections while editing to prevent conflicts
5. **Real-time Updates**: All changes sync immediately across devices

## Module Types

- 🟢 **Flights**: Flight number, airports, times, cost
- 🟠 **Hotels**: Name, dates, room type, address, cost  
- 🔵 **Transportation**: Type, route, timing, cost
- 🔴 **Restaurants**: Name, time, reservations, cuisine, cost
- 🔵 **Cost Summary**: Always at bottom, shows total and breakdown

## Development Notes

- Minimum iOS version: 16.0
- Uses modern SwiftUI patterns with `@StateObject` and `@EnvironmentObject`
- Real-time listeners automatically clean up on view disappear
- Section locking prevents editing conflicts in collaborative sessions
- Temporary users (invite code) have limited persistence but full editing access

## Next Steps

1. Test Firebase integration
2. Add more transportation types
3. Implement cost auto-calculation from modules
4. Add photo attachment support
5. Export trip summaries
6. Push notifications for updates
