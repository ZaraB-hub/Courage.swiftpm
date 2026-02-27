//
//  TaskRepository.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation
@MainActor
public protocol TaskRepository {
    func save(_ task: Task)
    func fetchAll() -> [Task]
    func fetchCompleted()->[Task]
    func update(_ task: Task)
    func delete(id: UUID)
    func fetch(id: UUID) -> Task?
}
