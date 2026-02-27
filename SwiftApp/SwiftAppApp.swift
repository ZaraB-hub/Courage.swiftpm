//
//  SwiftAppApp.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 22. 2. 26.
//

import SwiftUI
import SwiftData


@main	
struct SwiftAppApp: App {
    private let sharedModelContainer: ModelContainer
    private let repository: SwiftDataTaskRepository
    private let stepGenerator:StepGeneratorService
    private let taskService:TaskServices
    private let stepService:StepService
    
    init(){
        do {
            let container = try ModelContainer(for: Task.self) // create db for my task model / Task.self - what do i want to store
            let repo = SwiftDataTaskRepository(modelContext: container.mainContext)
            let stepGenerator = StepGeneratorService()

            self.sharedModelContainer = container
            self.repository = repo
            self.stepGenerator = stepGenerator
            self.taskService = TaskServices(repository: repo, stepGenerator: stepGenerator)
            self.stepService = StepService(repository: repo)
        } catch {
            fatalError("Could not initialize container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(viewModel: HomeViewModel( taskService: taskService, stepService: stepService))
            }
        }
        .modelContainer(sharedModelContainer)
    }}
