
//
//  StepGeneratorService.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif
@MainActor
public final class StepGeneratorService {
    
    public init() {}
    
    public func generateSteps(for taskTitle: String) async -> [Step] {
        if #available(iOS 26.0, *),
           let aiSteps = await generateWithAI(for: taskTitle) {
            return aiSteps
        }
        return fallbackSteps(for: taskTitle)
    }
        
        private func generateWithAI(for taskTitle: String) async -> [Step]? {
#if canImport(FoundationModels)
            guard #available(iOS 26.0, *) else {
                return nil
            }
            do {
                let instructions = """
                You are a psychologist helping your client finish a task.
                Break tasks into 5-7 very small, concrete, anxiety-friendly steps.
                """
                let session = LanguageModelSession(instructions:instructions)
                let prompt = """
                Break this task into 5-7 very small, concrete steps for someone with anxiety or ADHD.
                Each step should and be extremely specific and broken down in a way that help someone wiith anxiety face the thing they are afraid to do.
                Prioritize the real intent from the task words.
                Task: \(taskTitle)
                
                Return ONLY a numbered list like this:
                1. Open the app
                2. Find the email
                Just the steps, nothing else.
                """
                
                let response = try await session.respond(to: prompt)
                let steps = parseSteps(from: response.content)
                
                return steps.isEmpty ? nil : steps
                
            } catch {
                return nil
            }
#else
            return nil
#endif
        }
        
        private func parseSteps(from text: String) -> [Step] {
            let lines = text.components(separatedBy: .newlines)
            return lines
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                .compactMap { line -> Step? in
                    let cleaned = line.trimmingCharacters(in: .whitespaces)
                    let withoutNumber = cleaned.replacingOccurrences(
                        of: #"^\d+[\.\)]\s*"#,
                        with: "",
                        options: .regularExpression
                    )
                    guard !withoutNumber.isEmpty else { return nil }
                    return Step(title: withoutNumber)
                }
        }

    private func fallbackSteps(for title: String) -> [Step] {
        let normalized = normalizedText(title)

        if containsAny(normalized, ["write", "send", "draft"]) && containsAny(normalized, ["email", "e mail", "mail", "emali", "emial", "inbox", "compose"]) {
            return emailSteps
        }

        if containsAny(normalized, ["email", "e mail", "mail", "emali", "emial", "inbox", "compose"]) {
            return emailSteps
        }

        if containsAny(normalized, ["text", "message", "reply", "dm"]) {
            return messageSteps
        }

        if containsAny(normalized, ["call", "phone", "dial"]) {
            return phoneCallSteps
        }

        let rules: [([String], [Step])] = [
            (["apologize", "sorry"], apologizeSteps),
            (["difficult conversation", "talk to"], difficultConversationSteps),

            (["essay", "paper", "thesis", "article", "draft"], essaySteps),
            (["study", "studying"], studySteps),
            (["read", "reading"], readingSteps),
            (["notes", "note"], notesSteps),
            (["assignment", "homework"], assignmentSteps),

            (["gym", "workout", "exercise"], gymSteps),
            (["run", "jog"], runSteps),
            (["shower", "hygiene", "brush"], showerSteps),
            (["sleep", "rest"], sleepSteps),
            (["eat", "meal", "food"], mealSteps),
            (["doctor", "appointment", "dentist"], appointmentSteps),

            (["bill", "pay", "payment"], billSteps),
            (["form", "fill"], formSteps),
            (["apply", "application"], applySteps),
            (["tax", "taxes"], taxSteps),
            (["schedule", "book", "reserve"], scheduleSteps),
            (["cancel"], cancelSteps),

            (["clean", "tidy"], cleanSteps),
            (["laundry", "clothes", "washing machine"], laundrySteps),
            (["dishes", "dishwasher"], dishesSteps),
            (["grocery", "groceries", "shopping"], grocerySteps),
            (["cook", "cooking", "dinner", "lunch", "breakfast"], cookSteps),

            (["meeting"], meetingSteps),
            (["presentation", "slides", "pitch"], presentationSteps),
            (["report"], reportSteps),
            (["deadline"], deadlineSteps),

            (["hang out", "plans with", "meet up"], socialSteps)
        ]

        if let matched = rules.first(where: { keywords, _ in
            containsAny(normalized, keywords)
        }) {
            return matched.1
        }

        return genericSteps
    }

    private func containsAny(_ text: String, _ keywords: [String]) -> Bool {
        keywords.contains(where: { containsWordOrPhrase(text, $0) })
    }

    private func containsWordOrPhrase(_ text: String, _ keyword: String) -> Bool {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        if trimmed.contains(" ") {
            return text.contains(trimmed)
        }

        let pattern = #"\b"# + NSRegularExpression.escapedPattern(for: trimmed) + #"\b"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private func normalizedText(_ text: String) -> String {
        let lowered = text.lowercased()
        let cleaned = lowered.replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
        return cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    // MARK: - Communication
    
    private var emailSteps: [Step] { [
        Step(title: "Open your email app"),
        Step(title: "Find the email or hit compose"),
        Step(title: "Read it once without doing anything"),
        Step(title: "Write one sentence — just the main point"),
        Step(title: "Fill in the rest, don't overthink it"),
        Step(title: "Read it back once"),
        Step(title: "Hit send")
    ]}
    
    private var messageSteps: [Step] { [
        Step(title: "Open the conversation"),
        Step(title: "Read the last message"),
        Step(title: "Type one sentence — anything"),
        Step(title: "Read it back"),
        Step(title: "Send it")
    ]}
    
    private var phoneCallSteps: [Step] { [
        Step(title: "Find the number"),
        Step(title: "Write down in one line what you need to say"),
        Step(title: "Take one breath"),
        Step(title: "Press call"),
        Step(title: "Say your opening line"),
        Step(title: "Finish the call")
    ]}
    
    private var apologizeSteps: [Step] { [
        Step(title: "Write down what you want to say first — just for you"),
        Step(title: "Keep it to two sentences: what happened, that you're sorry"),
        Step(title: "Choose how you'll reach out — text, call, in person"),
        Step(title: "Do it without editing too much"),
        Step(title: "Let it go after — you did your part")
    ]}
    
    private var difficultConversationSteps: [Step] { [
        Step(title: "Write down the one main thing you need to say"),
        Step(title: "Write down what you're worried they'll say"),
        Step(title: "Remind yourself you can handle their reaction"),
        Step(title: "Choose a time and place"),
        Step(title: "Start with 'I wanted to talk about something'"),
        Step(title: "Say your main point"),
        Step(title: "Listen")
    ]}
    
    // MARK: - Academic
    
    private var essaySteps: [Step] { [
        Step(title: "Open a blank document"),
        Step(title: "Write the topic at the top"),
        Step(title: "Write three points you want to make — just words, no sentences"),
        Step(title: "Write one sentence for each point"),
        Step(title: "Expand each sentence into a paragraph"),
        Step(title: "Write a one sentence intro and one sentence conclusion"),
        Step(title: "Read it through once and fix obvious things"),
        Step(title: "Save and submit")
    ]}
    
    private var studySteps: [Step] { [
        Step(title: "Put your phone face down"),
        Step(title: "Open just the material you need"),
        Step(title: "Read the first section once"),
        Step(title: "Write one thing you learned from it"),
        Step(title: "Keep going one section at a time"),
        Step(title: "Take a 5 minute break after 25 minutes"),
        Step(title: "Review your notes at the end")
    ]}
    
    private var readingSteps: [Step] { [
        Step(title: "Find the reading and open it"),
        Step(title: "Read just the first paragraph"),
        Step(title: "Keep reading one paragraph at a time"),
        Step(title: "Underline or note anything important"),
        Step(title: "Summarize in one sentence what you read")
    ]}
    
    private var notesSteps: [Step] { [
        Step(title: "Open your notes app or notebook"),
        Step(title: "Write the topic and date at the top"),
        Step(title: "Write the first point — just a few words"),
        Step(title: "Keep going point by point"),
        Step(title: "Review what you wrote")
    ]}
    
    private var assignmentSteps: [Step] { [
        Step(title: "Open the assignment and read what's required"),
        Step(title: "Break it into the smallest possible parts"),
        Step(title: "Start with the easiest part"),
        Step(title: "Work through each part one at a time"),
        Step(title: "Review before submitting"),
        Step(title: "Submit")
    ]}
    
    // MARK: - Health
    
    private var gymSteps: [Step] { [
        Step(title: "Put on your gym clothes"),
        Step(title: "Pack your bag or fill your water bottle"),
        Step(title: "Leave the house — that's the hardest part"),
        Step(title: "Do your warmup"),
        Step(title: "Do your first exercise"),
        Step(title: "Finish your session"),
        Step(title: "Go home — you did it")
    ]}
    
    private var runSteps: [Step] { [
        Step(title: "Put on your shoes"),
        Step(title: "Step outside"),
        Step(title: "Walk for two minutes to warm up"),
        Step(title: "Start running at a comfortable pace"),
        Step(title: "Finish your run"),
        Step(title: "Stretch for two minutes")
    ]}
    
    private var showerSteps: [Step] { [
        Step(title: "Go to the bathroom"),
        Step(title: "Turn the shower on"),
        Step(title: "Get in"),
        Step(title: "Wash your hair"),
        Step(title: "Wash your body"),
        Step(title: "Get out and dry off"),
        Step(title: "Get dressed")
    ]}
    
    private var sleepSteps: [Step] { [
        Step(title: "Put your phone on do not disturb"),
        Step(title: "Put the phone face down or in another room"),
        Step(title: "Lie down"),
        Step(title: "Take three slow breaths"),
        Step(title: "Close your eyes and let your body rest")
    ]}
    
    private var mealSteps: [Step] { [
        Step(title: "Decide what you're eating — keep it simple"),
        Step(title: "Get out what you need"),
        Step(title: "Prepare it step by step"),
        Step(title: "Sit down and eat without your phone if possible"),
        Step(title: "Clean up after")
    ]}
    
    private var appointmentSteps: [Step] { [
        Step(title: "Find the number or website"),
        Step(title: "Write down what you need to book and any relevant dates"),
        Step(title: "Call or go online"),
        Step(title: "Book the appointment"),
        Step(title: "Add it to your calendar")
    ]}
    
    // MARK: - Admin
    
    private var billSteps: [Step] { [
        Step(title: "Find the bill or open the app"),
        Step(title: "Check the amount and due date"),
        Step(title: "Open your banking app"),
        Step(title: "Make the payment"),
        Step(title: "Take a screenshot or note it's done")
    ]}
    
    private var formSteps: [Step] { [
        Step(title: "Open the form"),
        Step(title: "Read through it once without filling anything"),
        Step(title: "Gather anything you need — ID, dates, info"),
        Step(title: "Fill it in one field at a time"),
        Step(title: "Review before submitting"),
        Step(title: "Submit")
    ]}
    
    private var applySteps: [Step] { [
        Step(title: "Find the application"),
        Step(title: "Read the requirements"),
        Step(title: "Gather your documents"),
        Step(title: "Fill in each section one at a time"),
        Step(title: "Review everything"),
        Step(title: "Submit and note the confirmation")
    ]}
    
    private var taxSteps: [Step] { [
        Step(title: "Gather your documents — T4s, receipts, etc"),
        Step(title: "Open your tax software or website"),
        Step(title: "Enter your basic info"),
        Step(title: "Go through each section one at a time"),
        Step(title: "Review the summary"),
        Step(title: "File and save your confirmation")
    ]}
    
    private var scheduleSteps: [Step] { [
        Step(title: "Decide what you're scheduling"),
        Step(title: "Find the available times"),
        Step(title: "Pick one — don't overthink it"),
        Step(title: "Book it"),
        Step(title: "Add it to your calendar")
    ]}
    
    private var cancelSteps: [Step] { [
        Step(title: "Find the contact info or cancellation page"),
        Step(title: "Know your reason in one sentence"),
        Step(title: "Call, email, or cancel online"),
        Step(title: "Confirm the cancellation"),
        Step(title: "Note it's done")
    ]}
    
    // MARK: - Home
    
    private var cleanSteps: [Step] { [
        Step(title: "Pick one room or one area only"),
        Step(title: "Remove anything that doesn't belong"),
        Step(title: "Wipe surfaces"),
        Step(title: "Vacuum or sweep if needed"),
        Step(title: "Put everything back in its place"),
        Step(title: "Take one look — you're done")
    ]}
    
    private var laundrySteps: [Step] { [
        Step(title: "Gather your clothes"),
        Step(title: "Sort if needed"),
        Step(title: "Put them in the machine"),
        Step(title: "Add detergent and start"),
        Step(title: "Move to dryer when done"),
        Step(title: "Fold and put away")
    ]}
    
    private var dishesSteps: [Step] { [
        Step(title: "Stack the dishes by the sink"),
        Step(title: "Fill the sink with warm soapy water"),
        Step(title: "Wash one dish at a time"),
        Step(title: "Rinse and stack"),
        Step(title: "Wipe down the sink and counter")
    ]}
    
    private var grocerySteps: [Step] { [
        Step(title: "Write a list of what you need"),
        Step(title: "Grab your bag and keys"),
        Step(title: "Go to the store"),
        Step(title: "Work through the list section by section"),
        Step(title: "Pay and go home"),
        Step(title: "Put everything away")
    ]}
    
    private var cookSteps: [Step] { [
        Step(title: "Decide what you're making"),
        Step(title: "Get out all the ingredients first"),
        Step(title: "Prep everything before you start cooking"),
        Step(title: "Follow the recipe or cook step by step"),
        Step(title: "Plate and eat"),
        Step(title: "Clean up")
    ]}
    
    // MARK: - Work
    
    private var meetingSteps: [Step] { [
        Step(title: "Check what the meeting is about"),
        Step(title: "Write one thing you want to say or ask"),
        Step(title: "Join or show up on time"),
        Step(title: "Listen and take brief notes"),
        Step(title: "Say your point when there's space"),
        Step(title: "Note any follow ups after")
    ]}
    
    private var presentationSteps: [Step] { [
        Step(title: "Write down the three main points you want to make"),
        Step(title: "Open your slides or document"),
        Step(title: "Make one slide or section per point"),
        Step(title: "Add just enough detail — don't overload"),
        Step(title: "Practice saying it out loud once"),
        Step(title: "Present")
    ]}
    
    private var reportSteps: [Step] { [
        Step(title: "Open a document"),
        Step(title: "Write the title and date"),
        Step(title: "List the sections you need"),
        Step(title: "Fill in one section at a time"),
        Step(title: "Review for obvious errors"),
        Step(title: "Submit or send")
    ]}
    
    private var deadlineSteps: [Step] { [
        Step(title: "Write down exactly what needs to be done"),
        Step(title: "Break it into the smallest possible pieces"),
        Step(title: "Do the first piece right now"),
        Step(title: "Keep going one piece at a time"),
        Step(title: "Submit before the deadline"),
        Step(title: "Note it's done and breathe")
    ]}
    
    // MARK: - Social
    
    private var socialSteps: [Step] { [
        Step(title: "Confirm the plan in your head — where, when, who"),
        Step(title: "Get ready — just the basics"),
        Step(title: "Leave when you planned to"),
        Step(title: "When you arrive, take one breath before going in"),
        Step(title: "Enjoy it — you showed up")
    ]}
    
    // MARK: - Generic
    
    private var genericSteps: [Step] { [
        Step(title: "Write down exactly what needs to happen"),
        Step(title: "Open or gather what you need"),
        Step(title: "Do just the very first part"),
        Step(title: "Keep going one part at a time"),
        Step(title: "Review what you did"),
        Step(title: "Mark it done")
    ]}
}
