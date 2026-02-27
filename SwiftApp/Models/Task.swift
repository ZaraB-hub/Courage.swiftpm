//
//  Task.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//

import Foundation
import SwiftData

@Model
public final class Task: Identifiable {
    public var id: UUID
    public var title: String
    public var steps: [Step]
    public var anxietyBefore: Int
    public var anxietyAfter: Int?
    public var reflection: String?
    public var dateCreated: Date
	public var dateCompleted: Date?

    public init(title: String, steps: [Step], date: Date = .now, anxietyBefore: Int) {
        self.id = UUID()
        self.title = title
        self.steps = steps
        self.anxietyBefore = anxietyBefore
        self.dateCreated = date
    }

    public var isCompleted: Bool {
        steps.allSatisfy { $0.isCompleted }
    }

    public var anxietyReduction: Int? {
        guard let after = anxietyAfter else { return nil }
        return anxietyBefore - after
    }

    public var status: TaskStatus {
        isCompleted ? .completed : .inProgress
    }
}

public enum TaskStatus {
    case inProgress
    case completed
}
