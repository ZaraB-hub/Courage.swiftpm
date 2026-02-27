//
//  SwiftDataTaskRepository.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 23. 2. 26.
//

import Foundation
import SwiftData


@MainActor
public final class SwiftDataTaskRepository: TaskRepository {

    private let modelContext: ModelContext
    private var ownedContainer: ModelContainer?

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.ownedContainer = nil
    }

    public convenience init(inMemoryOnly: Bool) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemoryOnly)
        do {
            let container = try ModelContainer(for: Task.self, configurations: configuration)
            self.init(modelContext: container.mainContext)
            self.ownedContainer = container
        } catch {
            fatalError("Unable to initialize SwiftDataTaskRepository: \(error)")
        }
    }

    public func save(_ task: Task) {
        modelContext.insert(task)
        persist()
    }

    public func fetchAll() -> [Task] {
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\Task.dateCreated, order: .forward)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func fetch(id: UUID) -> Task? {
        let descriptor = FetchDescriptor<Task>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    public func fetchCompleted() -> [Task] {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate { $0.dateCompleted != nil },
            sortBy: [SortDescriptor(\Task.dateCompleted, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func update(_ task: Task) {
        if let existing = fetch(id: task.id), existing.persistentModelID != task.persistentModelID {
            existing.title = task.title
            existing.steps = task.steps
            existing.anxietyBefore = task.anxietyBefore
            existing.anxietyAfter = task.anxietyAfter
            existing.reflection = task.reflection
            existing.dateCompleted = task.dateCompleted
        }
        persist()
    }

    public func delete(id: UUID) {
        guard let task = fetch(id: id) else { return }
        modelContext.delete(task)
        persist()
    }

    private func persist() {
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save task changes: \(error)")
        }
    }
}

