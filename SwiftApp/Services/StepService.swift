//
//  StepService.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

@MainActor
public final class StepService {
    
    private let repository: TaskRepository
    
    public init(repository: TaskRepository) {
        self.repository = repository
    }
    
    public func firstUncompletedStep(in task: Task) -> Step? {
        task.steps.first { !$0.isCompleted }
    }
    
    // public func completeStep(id: UUID, in task: Task) {
    //     guard let index = task.steps.firstIndex(where: { $0.id == id }) else { return }
    //     task.steps[index].isCompleted = true
    //     repository.update(task)
    // }

    public func completeStep(stepID: UUID, taskID: UUID) {
        guard let task = repository.fetch(id: taskID) else { return }

        guard let index = task.steps.firstIndex(where: { $0.id == stepID }) else { return }

        task.steps[index].isCompleted = true
        repository.update(task)
    }
}
