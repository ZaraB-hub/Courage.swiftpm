
//
//  HomeViewModel.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

public struct ActiveTaskSnapshot: Identifiable {
    public let id: UUID
    public let title: String
    public let completedSteps: Int
    public let totalSteps: Int
    public let dateCreated: Date

    public var shownStep: Int {
        min(completedSteps + 1, max(totalSteps, 1))
    }
}

@Observable
@MainActor
public final class HomeViewModel {
    
    let taskService: TaskServices
    let stepService: StepService
    
    var activeTasks: [Task] = []
    var activeTaskSnapshots: [ActiveTaskSnapshot] = []
    var completedTasks: [Task] = []

    private let tasksPerGrowthStage = 3

    var completedCount: Int {
        completedTasks.count
    }

    var plantStageIndex: Int {
        min(completedCount / tasksPerGrowthStage, 4)
    }

    var plantEmoji: String {
        switch plantStageIndex {
        case 0: return "🌱"
        case 1: return "🌿"
        case 2: return "🪴"
        case 3: return "🌳"
        default: return "🌸"
        }
    }

    var plantStageTitle: String {
        switch plantStageIndex {
        case 0: return "Seedling"
        case 1: return "Sprout"
        case 2: return "Growing"
        case 3: return "Thriving"
        default: return "Blooming"
        }
    }

    var progressToNextPlantStage: Double {
        if plantStageIndex >= 4 { return 1 }
        let remainder = completedCount % tasksPerGrowthStage
        return Double(remainder) / Double(tasksPerGrowthStage)
    }

    var tasksToNextPlantStage: Int {
        if plantStageIndex >= 4 { return 0 }
        let remainder = completedCount % tasksPerGrowthStage
        return tasksPerGrowthStage - remainder
    }
    
    public init(taskService: TaskServices, stepService:StepService) {
        self.taskService = taskService
        self.stepService=stepService
    }
    
    func loadTasks() {
        let all = taskService.getTasks()
        activeTasks = all.filter { $0.status == .inProgress }
        completedTasks = all.filter { $0.status == .completed }

        activeTaskSnapshots = activeTasks.map { task in
            ActiveTaskSnapshot(
                id: task.id,
                title: task.title,
                completedSteps: task.steps.filter { $0.isCompleted }.count,
                totalSteps: task.steps.count,
                dateCreated: task.dateCreated
            )
        }
    }
    
    func deleteTask(id: UUID) {
        taskService.deleteTask(id: id)
        loadTasks()
    }

    func activeStepViewModel(for taskID: UUID) -> ActiveStepViewModel? {
        guard let task = try? taskService.getTask(id: taskID) else { return nil }
        return ActiveStepViewModel(task: task, stepService: stepService, taskService: taskService)
    }
}
extension HomeViewModel {

    static var preview: HomeViewModel {

        let repo = SwiftDataTaskRepository(inMemoryOnly: true)

        let stepService = StepService(repository: repo)

        let taskService = TaskServices(
            repository: repo,
            stepGenerator: StepGeneratorService()
        )

        return HomeViewModel(
            taskService: taskService,
            stepService: stepService
        )
    }
}
