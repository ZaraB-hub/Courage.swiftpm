//
//  InMemoryTaskRepository.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation
@MainActor
public final class InMemoryTaskRepository: TaskRepository {

    private var tasks: [Task] = []

    public init() {}

    public func save(_ task: Task) {
        tasks.append(task)
    }

    public func fetchAll() -> [Task] {
        tasks
    }

    public func fetch(id: UUID) -> Task? {
        tasks.first { $0.id == id }
    }

    public func fetchCompleted() -> [Task] {
        tasks.filter({ $0.dateCompleted != nil })
    }

    public func update(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
    }

    public func delete(id: UUID) {
        tasks.removeAll { $0.id == id }
    }
}
