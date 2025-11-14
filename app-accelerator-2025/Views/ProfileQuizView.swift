//
//  ProfileQuizView.swift
//  app-accelerator-2025
//

import SwiftUI

struct ProfileQuizView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @State private var currentCategory = 0
    @State private var showingSuccess = false
    
    // Category 1: Trust & Communication Style
    @State private var comfortableTalkingStyle: ComfortableTalkingStyle?
    @State private var checkInPreference: CheckInPreference?
    @State private var openingUpStyle: OpeningUpStyle?
    @State private var adviceStyle: AdviceStyle?
    
    // Category 2: Environment & Stability Needs
    @State private var currentChallenges: Set<CurrentChallenge> = []
    @State private var supportType: SupportType?
    @State private var changingSocialCircle: ChangingSocialCircle?
    
    // Category 3: Values & Motivation
    @State private var priorityValue: PriorityValue?
    @State private var mentorType: MentorType?
    @State private var trustValue: TrustValue?
    
    // Category 4: Lived Experience Matching
    @State private var relatableExperiences: Set<RelatableExperience> = []
    @State private var comfortableTalkingAbout: Set<ComfortableTalkingAbout> = []
    @State private var mentorAgePreference: MentorAgePreference?
    
    // Category 5: Practical Support Needs
    @State private var opportunityTypes: Set<OpportunityType> = []
    @State private var barriers: Set<BarrierType> = []
    
    // Category 6: Personality Fit
    @State private var mentorEnergy: MentorEnergy?
    @State private var stressResponsePreference: StressResponsePreference?
    
    // Category 7: Commitment & Meeting Style
    @State private var meetingFrequency: MeetingFrequency?
    @State private var preferredTimeOfDay: PreferredTimeOfDay?
    @State private var sessionPreference: SessionPreference?
    
    private let categories = [
        "Trust & Communication",
        "Environment & Stability",
        "Values & Motivation",
        "Lived Experience",
        "Practical Support",
        "Personality Fit",
        "Commitment & Meetings"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                VStack(spacing: 8) {
                    ProgressView(value: Double(currentCategory + 1), total: 7)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#284b63")))
                    
                    Text("Category \(currentCategory + 1) of 7: \(categories[currentCategory])")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#353535"))
                }
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentCategory {
                        case 0:
                            Category1View(
                                comfortableTalkingStyle: $comfortableTalkingStyle,
                                checkInPreference: $checkInPreference,
                                openingUpStyle: $openingUpStyle,
                                adviceStyle: $adviceStyle
                            )
                        case 1:
                            Category2View(
                                currentChallenges: $currentChallenges,
                                supportType: $supportType,
                                changingSocialCircle: $changingSocialCircle
                            )
                        case 2:
                            Category3View(
                                priorityValue: $priorityValue,
                                mentorType: $mentorType,
                                trustValue: $trustValue
                            )
                        case 3:
                            Category4View(
                                relatableExperiences: $relatableExperiences,
                                comfortableTalkingAbout: $comfortableTalkingAbout,
                                mentorAgePreference: $mentorAgePreference
                            )
                        case 4:
                            Category5View(
                                opportunityTypes: $opportunityTypes,
                                barriers: $barriers
                            )
                        case 5:
                            Category6View(
                                mentorEnergy: $mentorEnergy,
                                stressResponsePreference: $stressResponsePreference
                            )
                        case 6:
                            Category7View(
                                meetingFrequency: $meetingFrequency,
                                preferredTimeOfDay: $preferredTimeOfDay,
                                sessionPreference: $sessionPreference
                            )
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack {
                    if currentCategory > 0 {
                        Button(action: {
                            withAnimation {
                                currentCategory -= 1
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
                            if currentCategory < 6 {
                                withAnimation {
                                    currentCategory += 1
                                }
                            } else {
                                submitQuiz()
                            }
                        }
                    }) {
                        Text(currentCategory < 6 ? "Next" : "Submit")
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
    
    private var canProceed: Bool {
        switch currentCategory {
        case 0: return comfortableTalkingStyle != nil && checkInPreference != nil && openingUpStyle != nil && adviceStyle != nil
        case 1: return !currentChallenges.isEmpty && supportType != nil && changingSocialCircle != nil
        case 2: return priorityValue != nil && mentorType != nil && trustValue != nil
        case 3: return !relatableExperiences.isEmpty && !comfortableTalkingAbout.isEmpty && mentorAgePreference != nil
        case 4: return !opportunityTypes.isEmpty && !barriers.isEmpty
        case 5: return mentorEnergy != nil && stressResponsePreference != nil
        case 6: return meetingFrequency != nil && preferredTimeOfDay != nil && sessionPreference != nil
        default: return false
        }
    }
    
    private func loadExistingQuiz() {
        if let quiz = appState.currentUser?.profileQuiz {
            comfortableTalkingStyle = quiz.comfortableTalkingStyle
            checkInPreference = quiz.checkInPreference
            openingUpStyle = quiz.openingUpStyle
            adviceStyle = quiz.adviceStyle
            currentChallenges = Set(quiz.currentChallenges)
            supportType = quiz.supportType
            changingSocialCircle = quiz.changingSocialCircle
            priorityValue = quiz.priorityValue
            mentorType = quiz.mentorType
            trustValue = quiz.trustValue
            relatableExperiences = Set(quiz.relatableExperiences)
            comfortableTalkingAbout = Set(quiz.comfortableTalkingAbout)
            mentorAgePreference = quiz.mentorAgePreference
            opportunityTypes = Set(quiz.opportunityTypes)
            barriers = Set(quiz.barriers)
            mentorEnergy = quiz.mentorEnergy
            stressResponsePreference = quiz.stressResponsePreference
            meetingFrequency = quiz.meetingFrequency
            preferredTimeOfDay = quiz.preferredTimeOfDay
            sessionPreference = quiz.sessionPreference
        }
    }
    
    private func submitQuiz() {
        let quiz = ProfileQuiz(
            comfortableTalkingStyle: comfortableTalkingStyle,
            checkInPreference: checkInPreference,
            openingUpStyle: openingUpStyle,
            adviceStyle: adviceStyle,
            currentChallenges: Array(currentChallenges),
            supportType: supportType,
            changingSocialCircle: changingSocialCircle,
            priorityValue: priorityValue,
            mentorType: mentorType,
            trustValue: trustValue,
            relatableExperiences: Array(relatableExperiences),
            comfortableTalkingAbout: Array(comfortableTalkingAbout),
            mentorAgePreference: mentorAgePreference,
            opportunityTypes: Array(opportunityTypes),
            barriers: Array(barriers),
            mentorEnergy: mentorEnergy,
            stressResponsePreference: stressResponsePreference,
            meetingFrequency: meetingFrequency,
            preferredTimeOfDay: preferredTimeOfDay,
            sessionPreference: sessionPreference
        )
        
        Task {
            await appState.submitProfileQuiz(quiz)
            showingSuccess = true
        }
    }
}

// MARK: - Category Views

struct Category1View: View {
    @Binding var comfortableTalkingStyle: ComfortableTalkingStyle?
    @Binding var checkInPreference: CheckInPreference?
    @Binding var openingUpStyle: OpeningUpStyle?
    @Binding var adviceStyle: AdviceStyle?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Trust & Communication Style")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            QuestionView(
                title: "What style of person are you most comfortable talking with?",
                selection: $comfortableTalkingStyle,
                options: ComfortableTalkingStyle.allCases
            )
            
            QuestionView(
                title: "How do you prefer to check in?",
                selection: $checkInPreference,
                options: CheckInPreference.allCases
            )
            
            QuestionView(
                title: "What helps you open up?",
                selection: $openingUpStyle,
                options: OpeningUpStyle.allCases
            )
            
            QuestionView(
                title: "What style of advice do you prefer?",
                selection: $adviceStyle,
                options: AdviceStyle.allCases
            )
        }
    }
}

struct Category2View: View {
    @Binding var currentChallenges: Set<CurrentChallenge>
    @Binding var supportType: SupportType?
    @Binding var changingSocialCircle: ChangingSocialCircle?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Environment & Stability Needs")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            MultiSelectQuestionView(
                title: "What are your current challenges? (Select all that apply)",
                selections: $currentChallenges,
                options: CurrentChallenge.allCases
            )
            
            QuestionView(
                title: "What type of support do you need most?",
                selection: $supportType,
                options: SupportType.allCases
            )
            
            QuestionView(
                title: "Are you trying to change your social circle?",
                selection: $changingSocialCircle,
                options: ChangingSocialCircle.allCases
            )
        }
    }
}

struct Category3View: View {
    @Binding var priorityValue: PriorityValue?
    @Binding var mentorType: MentorType?
    @Binding var trustValue: TrustValue?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Values & Motivation")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            QuestionView(
                title: "What's your top priority right now?",
                selection: $priorityValue,
                options: PriorityValue.allCases
            )
            
            QuestionView(
                title: "What type of mentor are you looking for?",
                selection: $mentorType,
                options: MentorType.allCases
            )
            
            QuestionView(
                title: "What do you value most in a relationship?",
                selection: $trustValue,
                options: TrustValue.allCases
            )
        }
    }
}

struct Category4View: View {
    @Binding var relatableExperiences: Set<RelatableExperience>
    @Binding var comfortableTalkingAbout: Set<ComfortableTalkingAbout>
    @Binding var mentorAgePreference: MentorAgePreference?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Lived Experience Matching")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            MultiSelectQuestionView(
                title: "What experiences would you find relatable? (Select all that apply)",
                selections: $relatableExperiences,
                options: RelatableExperience.allCases
            )
            
            MultiSelectQuestionView(
                title: "What are you comfortable talking about? (Select all that apply)",
                selections: $comfortableTalkingAbout,
                options: ComfortableTalkingAbout.allCases
            )
            
            QuestionView(
                title: "What age preference do you have for a mentor?",
                selection: $mentorAgePreference,
                options: MentorAgePreference.allCases
            )
        }
    }
}

struct Category5View: View {
    @Binding var opportunityTypes: Set<OpportunityType>
    @Binding var barriers: Set<BarrierType>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Practical Support Needs")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            MultiSelectQuestionView(
                title: "What opportunities are you interested in? (Select all that apply)",
                selections: $opportunityTypes,
                options: OpportunityType.allCases
            )
            
            MultiSelectQuestionView(
                title: "What barriers are you facing? (Select all that apply)",
                selections: $barriers,
                options: BarrierType.allCases
            )
        }
    }
}

struct Category6View: View {
    @Binding var mentorEnergy: MentorEnergy?
    @Binding var stressResponsePreference: StressResponsePreference?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Personality Fit")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            QuestionView(
                title: "What energy level do you prefer in a mentor?",
                selection: $mentorEnergy,
                options: MentorEnergy.allCases
            )
            
            QuestionView(
                title: "How do you want someone to respond when you're stressed?",
                selection: $stressResponsePreference,
                options: StressResponsePreference.allCases
            )
        }
    }
}

struct Category7View: View {
    @Binding var meetingFrequency: MeetingFrequency?
    @Binding var preferredTimeOfDay: PreferredTimeOfDay?
    @Binding var sessionPreference: SessionPreference?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Commitment & Meeting Style")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#353535"))
            
            QuestionView(
                title: "How often would you like to meet?",
                selection: $meetingFrequency,
                options: MeetingFrequency.allCases
            )
            
            QuestionView(
                title: "What time of day works best for you?",
                selection: $preferredTimeOfDay,
                options: PreferredTimeOfDay.allCases
            )
            
            QuestionView(
                title: "What type of sessions do you prefer?",
                selection: $sessionPreference,
                options: SessionPreference.allCases
            )
        }
    }
}

// MARK: - Reusable Question Components

struct QuestionView<T: CaseIterable & Hashable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T?
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#353535"))
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    HStack {
                        Text(option.rawValue)
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

struct MultiSelectQuestionView<T: CaseIterable & Hashable & RawRepresentable>: View where T.RawValue == String {
    let title: String
    @Binding var selections: Set<T>
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#353535"))
            
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selections.contains(option) {
                        selections.remove(option)
                    } else {
                        selections.insert(option)
                    }
                }) {
                    HStack {
                        Text(option.rawValue)
                            .foregroundColor(Color(hex: "#353535"))
                        Spacer()
                        if selections.contains(option) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "#284b63"))
                        }
                    }
                    .padding()
                    .background(selections.contains(option) ? Color(hex: "#284b63").opacity(0.1) : Color(hex: "#d9d9d9"))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selections.contains(option) ? Color(hex: "#284b63") : Color.clear, lineWidth: 2)
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

