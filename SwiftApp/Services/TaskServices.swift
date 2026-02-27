
//
//  TaskServices.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation


@MainActor
public final class TaskServices {
    
    private let repository: TaskRepository
    private let stepGenerator:StepGeneratorService
    
    public init(repository: TaskRepository,stepGenerator:StepGeneratorService) {
        self.repository = repository
        self.stepGenerator=stepGenerator
    }

    
    public func createTask(title: String, anxietyBefore: Int) async {
        let steps = await stepGenerator.generateSteps(for: title)
        let task = Task(title: title, steps: steps, anxietyBefore: anxietyBefore)
        repository.save(task)
    }
    
    public func completeTask(id: UUID, anxietyAfter: Int, reflection: String?) throws {
        guard var task = repository.fetch(id: id) else { return }
        
        guard (0...10).contains(anxietyAfter) else {
            throw TaskError.invalidAnxiety
        }
        
        task.anxietyAfter = anxietyAfter
        task.reflection = reflection
        task.dateCompleted = .now
        
        repository.update(task)
    }
    
    public func getTasks() -> [Task] {
        repository.fetchAll()
    }
    
    public func deleteTask(id:UUID){
        repository.delete(id:id)
    }
    
    public func getTask(id: UUID) throws -> Task {
        guard var task = repository.fetch(id: id) else {
            throw TaskError.notFound
        }
        return task
    }
}
