//
//  TaskError.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

public enum TaskError: Error, LocalizedError {

    case notFound
    case invalidAnxiety

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Task not found."
        case .invalidAnxiety:
            return "Anxiety must be between 0 and 10."
        }
    }
}
