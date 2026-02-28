//
//  InsightService.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

@MainActor
public final class InsightService {
    
    private let repository: TaskRepository
    
    public init(repository: TaskRepository) {
        self.repository = repository
    }
    
    public func averageAnxietyReduction() -> Double? {
        let completed = repository.fetchCompleted()
        let reductions = completed.compactMap { $0.anxietyReduction }
        guard !reductions.isEmpty else { return nil }
        return Double(reductions.reduce(0, +)) / Double(reductions.count)
    }
    
    public func totalStepsCompleted() -> Int {
        repository.fetchCompleted()
            .flatMap { $0.steps }
            .filter { $0.isCompleted }
            .count
    }
    
    public func totalTasksCompleted() -> Int {
        repository.fetchCompleted().count
    }
    
    public func hardestTaskCompleted() -> Task? {
        repository.fetchCompleted()
            .max(by: { $0.anxietyBefore < $1.anxietyBefore })
    }
    
    public func bestTask() -> Task? {
        repository.fetchCompleted()
            .compactMap { task -> (Task, Int)? in
                guard let reduction = task.anxietyReduction else { return nil }
                return (task, reduction)
            }
            .max(by: { $0.1 < $1.1 })?.0
    }
    
}
