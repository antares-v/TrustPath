# How to Test the Matching System

## Overview
The matching system pairs clients (people on parole/probation) with volunteers based on their profile quiz answers. It calculates a match score based on:
- **Hobbies** (30% weight)
- **Interests** (20% weight)
- **Language Preference** (20% weight)
- **Neighborhood** (15% weight)
- **Communication Style** (15% weight)

## Prerequisites for Testing

### 1. Switch to the Main Branch (if needed)
If you're on a different branch, switch to main where the matching system exists:
```bash
git checkout main
```

### 2. Set Up Test Data

You need to create:
- **At least 1 Client** with a completed profile quiz
- **At least 1 Volunteer** with a completed profile quiz

## Step-by-Step Testing Guide

### Option 1: Manual Testing Through the App UI

1. **Create a Client Account:**
   - Run the app
   - Sign up as a new user (this creates a client)
   - Complete the onboarding process
   - Fill out the profile quiz with:
     - Hobbies (e.g., ["reading", "cooking", "sports"])
     - Interests (e.g., ["music", "art", "technology"])
     - Language Preference (e.g., "English")
     - Neighborhood (e.g., "Downtown")
     - Communication Style (e.g., .text, .call, .inPerson, or .mixed)

2. **Create Volunteer Accounts:**
   - Sign out or use a different device/simulator
   - Create volunteer accounts (you may need to modify the signup to allow volunteer creation, or create them programmatically)
   - Complete onboarding for each volunteer
   - Fill out profile quizzes with varying interests to test matching

3. **Test Matching:**
   - Log in as the client
   - Navigate to the Matching View
   - The app will automatically find matches
   - You should see match results with scores

### Option 2: Programmatic Testing (Recommended for Development)

Create a test script or add test code to verify the matching system works:

```swift
// Example test code you can add temporarily to test matching

func testMatchingSystem() async {
    let userService = UserService()
    let matchingService = MatchingService()
    
    // Create a test client
    let client = try await userService.createClient(
        name: "Test Client",
        email: "client@test.com"
    )
    
    // Create test volunteers
    let volunteer1 = try await userService.createVolunteer(
        name: "Volunteer 1",
        email: "volunteer1@test.com"
    )
    
    let volunteer2 = try await userService.createVolunteer(
        name: "Volunteer 2",
        email: "volunteer2@test.com"
    )
    
    // Set up client profile quiz
    let clientQuiz = ProfileQuiz(
        hobbies: ["reading", "cooking", "sports"],
        languagePreference: "English",
        neighborhood: "Downtown",
        genderPreference: nil,
        communicationStyle: .mixed,
        interests: ["music", "art", "technology"],
        background: nil
    )
    try await userService.submitProfileQuiz(userId: client.id, quiz: clientQuiz)
    
    // Set up volunteer 1 profile quiz (high match)
    let volunteer1Quiz = ProfileQuiz(
        hobbies: ["reading", "cooking", "sports"], // Same hobbies
        languagePreference: "English", // Same language
        neighborhood: "Downtown", // Same neighborhood
        genderPreference: nil,
        communicationStyle: .mixed, // Same style
        interests: ["music", "art", "technology"], // Same interests
        background: nil
    )
    try await userService.submitProfileQuiz(userId: volunteer1.id, quiz: volunteer1Quiz)
    
    // Set up volunteer 2 profile quiz (lower match)
    let volunteer2Quiz = ProfileQuiz(
        hobbies: ["gaming", "hiking"], // Different hobbies
        languagePreference: "Spanish", // Different language
        neighborhood: "Uptown", // Different neighborhood
        genderPreference: nil,
        communicationStyle: .text, // Different style
        interests: ["gaming", "outdoors"], // Different interests
        background: nil
    )
    try await userService.submitProfileQuiz(userId: volunteer2.id, quiz: volunteer2Quiz)
    
    // Test matching
    let matches = try await matchingService.findMatches(for: client.id)
    
    print("Found \(matches.count) matches:")
    for match in matches {
        print("Volunteer: \(match.volunteer.name), Score: \(match.matchScore)")
    }
    
    // Volunteer 1 should have a higher score than Volunteer 2
    assert(matches[0].matchScore > matches[1].matchScore, "Matching not working correctly")
}
```

## Testing Scenarios

### Scenario 1: Perfect Match
- Client and Volunteer have identical hobbies, interests, language, neighborhood, and communication style
- **Expected**: Match score close to 1.0 (100%)

### Scenario 2: Partial Match
- Client and Volunteer share some hobbies/interests but differ in other areas
- **Expected**: Match score between 0.3-0.7 (30-70%)

### Scenario 3: No Match
- Client and Volunteer have completely different preferences
- **Expected**: Low match score (0.0-0.3)

### Scenario 4: Mixed Communication Style
- One has `.mixed` communication style
- **Expected**: Partial score (0.5 weight) for communication style match

### Scenario 5: Multiple Volunteers
- Client with profile quiz, multiple volunteers with varying matches
- **Expected**: Matches sorted by score (highest first)

## What to Check

1. ✅ **Match Scores**: Should be between 0.0 and 1.0
2. ✅ **Sorting**: Matches should be sorted highest to lowest
3. ✅ **Filtering**: Only volunteers with completed quizzes should appear
4. ✅ **Assignment**: When a match is selected, it should update both client and volunteer records
5. ✅ **Empty State**: If no matches found, show appropriate message

## Common Issues

### "Profile Quiz Not Completed" Error
- **Cause**: Client or volunteer hasn't completed their profile quiz
- **Fix**: Complete the onboarding/profile quiz for all test users

### "Insufficient Candidates" Error
- **Cause**: No volunteers with completed profile quizzes exist
- **Fix**: Create at least one volunteer and complete their profile quiz

### No Matches Found
- **Cause**: No volunteers match the criteria or all are already matched
- **Fix**: Create more volunteers with varying profile data

## Quick Test Checklist

- [ ] Created at least 1 client with completed profile quiz
- [ ] Created at least 1 volunteer with completed profile quiz
- [ ] Navigated to Matching View
- [ ] Verified matches are displayed
- [ ] Verified match scores are reasonable (0.0-1.0)
- [ ] Verified matches are sorted correctly
- [ ] Tested assigning a match
- [ ] Verified both client and volunteer records update after assignment

## Debugging Tips

1. **Check User Data**: Verify users have `profileQuiz` set
2. **Check Match Scores**: Print match scores to console to verify calculations
3. **Check Filtering**: Verify volunteers aren't already matched
4. **Check Async Operations**: Ensure all async operations complete before checking results

