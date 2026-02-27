//
//  ActiveStepViewModel.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

@Observable
@MainActor
public final class ActiveStepViewModel {
    
     let stepService: StepService
     let taskService: TaskServices
    
    var task: Task
    var currentStep: Step? = nil
    var isBreathing: Bool = false
    var isCompleted: Bool = false
    var showReflection: Bool = false
    var anxietyAfter: Double = 5
    var reflection: String = ""
    var taskSaved: Bool = false
    let totalBreathingCycles: Int = 3
    
    init(task: Task, stepService: StepService, taskService: TaskServices) {
        self.task = task
        self.stepService = stepService
        self.taskService = taskService
        self.currentStep = stepService.firstUncompletedStep(in: task)
    }
    
    func completeCurrentStep() {
        guard let step = currentStep else { return }
        
        stepService.completeStep(stepID: step.id, taskID: task.id)
        
        task.steps = task.steps.map { s in
            var updated = s
            if s.id == step.id { updated.isCompleted = true }
            return updated
        }
        
        currentStep = stepService.firstUncompletedStep(in: task)
        
        if currentStep == nil {
            isCompleted = true
        }
    }
    
    func tooHard() {
        isBreathing = true
        runBreathing()
    }
    
    func saveAndFinish() {
        try? taskService.completeTask(
            id: task.id,
            anxietyAfter: Int(anxietyAfter),
            reflection: reflection.isEmpty ? nil : reflection
        )
        taskSaved = true
    }
    
    private func runBreathing() {
        let singleCycle: [(String, Double, TimeInterval)] = [
            ("Inhale", 1.0, 4),
            ("Hold", 1.0, 4),
            ("Exhale", 0.0, 4)
        ]

        var delay: TimeInterval = 0

        for cycle in 1...totalBreathingCycles {
            for (phase, progress, duration) in singleCycle {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.breathingCycle = cycle
                    self.breathingPhase = phase
                    self.breathingAnimationDuration = duration
                    self.breathingProgress = progress
                }
                delay += duration
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.isBreathing = false
            self.breathingPhase = "Inhale"
            self.breathingProgress = 0.0
            self.breathingAnimationDuration = 4
            self.breathingCycle = 1
        }
    }
    
    var breathingPhase: String = "Inhale"
    var breathingProgress: Double = 0.0
    var breathingAnimationDuration: TimeInterval = 4
    var breathingCycle: Int = 1
}

extension ActiveStepViewModel {

    static var preview: ActiveStepViewModel {

        let repo = SwiftDataTaskRepository(inMemoryOnly: true)

        let stepService = StepService(repository: repo)

        let taskService = TaskServices(
            repository: repo,
            stepGenerator: StepGeneratorService()
        )

        let sampleTask = Task(
            title: "Send the difficult email",
            steps: [
                Step(title: "Open your inbox", isCompleted: true),
                Step(title: "Write a short first draft"),
                Step(title: "Press send")
            ],
            anxietyBefore: 7
        )

        return ActiveStepViewModel(
            task: sampleTask,
            stepService: stepService,
            taskService: taskService
        )
    }
}
