# Firebase Setup Instructions

## Overview
Your project has been integrated with Firebase Firestore. All user data will now be stored in Firebase instead of in-memory storage.

## Required Steps

### 1. Add Firebase SDK via Swift Package Manager

1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. Enter the Firebase iOS SDK URL: `https://github.com/firebase/firebase-ios-sdk`
4. Select the following products:
   - **FirebaseFirestore**
   - **FirebaseCore**
5. Click **Add Package**

### 2. Download and Add GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or select existing one)
3. Add an iOS app to your project
4. Download the `GoogleService-Info.plist` file
5. Drag and drop the `GoogleService-Info.plist` file into your Xcode project (make sure to add it to the target)

### 3. Enable Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create Database**
3. Start in **test mode** (for development) or **production mode** (for production)
4. Select a location for your database

### 4. Configure Firestore Security Rules (Optional but Recommended)

For development, you can use these rules in Firestore:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null;
    }
  }
}
```

For production, implement proper authentication and security rules.

## What Changed

### Files Created:
- `MainData.swift` - Firebase data manager that handles all Firestore operations

### Files Modified:
- `UserRepository.swift` - Now uses Firebase (MainData) instead of in-memory storage
- `UserService.swift` - Updated to use async/await for Firebase operations
- `UserModel.swift` - Made Codable for Firebase storage
- `AppState.swift` - Updated to use async/await
- `LoginView.swift` - Updated to use async/await
- `MatchingService.swift` - Updated to use async/await
- `OnboardingView.swift` - Updated to use async/await
- `app_accelerator_2025App.swift` - Added Firebase initialization

## Data Structure in Firestore

All user data is stored in a collection called `users` with the following structure:
- Document ID: User's UUID (string)
- Fields:
  - `id`: String (UUID)
  - `name`: String
  - `email`: String
  - `userType`: String ("client" or "volunteer")
  - `createdAt`: Timestamp
  - `matchedVolunteerId`: String? (UUID, optional)
  - `matchedClientIds`: Array of Strings (UUIDs)
  - `paroleEndDate`: Timestamp? (optional)
  - `profileQuiz`: Map (optional)
    - `hobbies`: Array of Strings
    - `languagePreference`: String
    - `neighborhood`: String
    - `genderPreference`: String? (optional)
    - `communicationStyle`: String
    - `interests`: Array of Strings
    - `background`: String? (optional)

## Testing

After completing the setup:
1. Build and run the app
2. Create a new account
3. Check Firebase Console → Firestore Database to see the data being stored

## Notes

- All data operations are now asynchronous (using async/await)
- The MainData class handles all Firebase operations
- User data persists across app restarts
- Make sure to configure proper Firestore security rules for production

