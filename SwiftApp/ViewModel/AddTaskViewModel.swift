//
//  AddTaskViewModel.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

@Observable
@MainActor
public final class AddTaskViewModel {
    
    let taskService: TaskServices
    let stepService: StepService
    
    var title: String = ""
    var anxiety: Double = 5
    var createdTask: Task? = nil
    var isLoading: Bool = false
    
    init(taskService: TaskServices, stepService: StepService) {
        self.taskService = taskService
        self.stepService = stepService
    }
    
    func createTask() async {
        isLoading = true
        await taskService.createTask(title: title, anxietyBefore: Int(anxiety))
        createdTask = taskService.getTasks().last
        isLoading = false
    }
}

extension AddTaskViewModel {

    static var preview: AddTaskViewModel {

        let repo = SwiftDataTaskRepository(inMemoryOnly: true)

        let stepService = StepService(repository: repo)

        let taskService = TaskServices(
            repository: repo,
            stepGenerator: StepGeneratorService()
        )

        return AddTaskViewModel(
            taskService: taskService,
            stepService: stepService
        )
    }
}
