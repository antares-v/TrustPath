//
//  ProfileQuizView.swift
//  app-accelerator-2025
//

import SwiftUI

struct ProfileQuizView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestion = 0
    @State private var showingSuccess = false
    
    // 10 Questions matching MatchingEngine
    @State private var openingUpComfort: OpeningUpComfort?
    @State private var stayOnTrackStyle: StayOnTrackStyle?
    @State private var hardestChallenge: HardestChallenge?
    @State private var workingOnMost: WorkingOnMost?
    @State private var relatableMentor: RelatableMentor?
    @State private var mentorVibe: MentorVibe?
    @State private var stressResponse: StressResponse?
    @State private var checkInPreference: CheckInPreference?
    @State private var agePreference: AgePreference?
    @State private var changingSocialCircle: ChangingSocialCircle?
    
    private let questions = [
        "How do you feel most comfortable opening up to someone?",
        "What kind of person helps you stay on track the best?",
        "What challenge is hardest for you right now?",
        "What are you trying to work on most?",
        "What makes a mentor feel relatable to you?",
        "What type of vibe works for you?",
        "When you're stressed, what do you want someone to do?",
        "How do you want your mentor to check in with you?",
        "Do you want someone close to your age or older?",
        "Are you trying to change your social circle right now?"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                VStack(spacing: 8) {
                    ProgressView(value: Double(currentQuestion + 1), total: 10)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#284b63")))
                    
                    Text("Question \(currentQuestion + 1) of 10")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#353535"))
                }
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        Text(questions[currentQuestion])
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#353535"))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                        
                        questionView
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack {
                    if currentQuestion > 0 {
                        Button(action: {
                            withAnimation {
                                currentQuestion -= 1
                            }
                        }) {
                            Text("Back")
                                .foregroundColor(Color(hex: "#284b63"))
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if canProceed {
                            if currentQuestion < 9 {
                                withAnimation {
                                    currentQuestion += 1
                                }
                            } else {
                                submitQuiz()
                            }
                        }
                    }) {
                        Text(currentQuestion < 9 ? "Next" : "Submit")
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 100)
                            .background(canProceed ? Color(hex: "#284b63") : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!canProceed)
                }
                .padding()
            }
            .navigationTitle("Profile Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Quiz Submitted!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            }
            .onAppear {
                loadExistingQuiz()
            }
        }
    }
    
    @ViewBuilder
    private var questionView: some View {
        switch currentQuestion {
        case 0:
            QuestionView(
                selection: $openingUpComfort,
                options: OpeningUpComfort.allCases
            )
        case 1:
            QuestionView(
                selection: $stayOnTrackStyle,
                options: StayOnTrackStyle.allCases
            )
        case 2:
            QuestionView(
                selection: $hardestChallenge,
                options: HardestChallenge.allCases
            )
        case 3:
            QuestionView(
                selection: $workingOnMost,
                options: WorkingOnMost.allCases
            )
        case 4:
            QuestionView(
                selection: $relatableMentor,
                options: RelatableMentor.allCases
            )
        case 5:
            QuestionView(
                selection: $mentorVibe,
                options: MentorVibe.allCases
            )
        case 6:
            QuestionView(
                selection: $stressResponse,
                options: StressResponse.allCases
            )
        case 7:
            QuestionView(
                selection: $checkInPreference,
                options: CheckInPreference.allCases
            )
        case 8:
            QuestionView(
                selection: $agePreference,
                options: AgePreference.allCases
            )
        case 9:
            QuestionView(
                selection: $changingSocialCircle,
                options: ChangingSocialCircle.allCases
            )
        default:
            EmptyView()
        }
    }
    
    private var canProceed: Bool {
        switch currentQuestion {
        case 0: return openingUpComfort != nil
        case 1: return stayOnTrackStyle != nil
        case 2: return hardestChallenge != nil
        case 3: return workingOnMost != nil
        case 4: return relatableMentor != nil
        case 5: return mentorVibe != nil
        case 6: return stressResponse != nil
        case 7: return checkInPreference != nil
        case 8: return agePreference != nil
        case 9: return changingSocialCircle != nil
        default: return false
        }
    }
    
    private func loadExistingQuiz() {
        if let quiz = appState.currentUser?.profileQuiz {
            openingUpComfort = quiz.openingUpComfort
            stayOnTrackStyle = quiz.stayOnTrackStyle
            hardestChallenge = quiz.hardestChallenge
            workingOnMost = quiz.workingOnMost
            relatableMentor = quiz.relatableMentor
            mentorVibe = quiz.mentorVibe
            stressResponse = quiz.stressResponse
            checkInPreference = quiz.checkInPreference
            agePreference = quiz.agePreference
            changingSocialCircle = quiz.changingSocialCircle
        }
    }
    
    private func submitQuiz() {
        let quiz = ProfileQuiz(
            openingUpComfort: openingUpComfort,
            stayOnTrackStyle: stayOnTrackStyle,
            hardestChallenge: hardestChallenge,
            workingOnMost: workingOnMost,
            relatableMentor: relatableMentor,
            mentorVibe: mentorVibe,
            stressResponse: stressResponse,
            checkInPreference: checkInPreference,
            agePreference: agePreference,
            changingSocialCircle: changingSocialCircle
        )
        
        Task {
            await appState.submitProfileQuiz(quiz)
            showingSuccess = true
        }
    }
}

// MARK: - Reusable Question Component

struct QuestionView<T: CaseIterable & Hashable & RawRepresentable>: View where T.RawValue == String {
    @Binding var selection: T?
    let options: [T]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    HStack {
                        Text(option.rawValue)
                            .font(.body)
                            .foregroundColor(Color(hex: "#353535"))
                        Spacer()
                        if selection == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#284b63"))
                        }
                    }
                    .padding()
                    .background(selection == option ? Color(hex: "#284b63").opacity(0.1) : Color(hex: "#d9d9d9"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selection == option ? Color(hex: "#284b63") : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
    }
}

#Preview {
    ProfileQuizView()
        .environmentObject(AppState())
}
