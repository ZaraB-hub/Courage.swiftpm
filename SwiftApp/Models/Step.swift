//
//  Step.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//


import Foundation

public struct Step: Identifiable, Codable {
    public var id = UUID()
    public var title: String
    public var isCompleted: Bool

    public init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
    }
}
