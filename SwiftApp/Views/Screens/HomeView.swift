
import SwiftUI

struct HomeView: View {

    @State var viewModel: HomeViewModel
    @State private var showCreateTask = false
    @State private var selectedInProgressTaskID: UUID? = nil
    @State private var navigateToActiveTask = false

    var body: some View {
        let snapshots: [ActiveTaskSnapshot] = viewModel.activeTaskSnapshots
        let recentActiveTasks = Array(
            snapshots
                .sorted { (lhs: ActiveTaskSnapshot, rhs: ActiveTaskSnapshot) in
                    lhs.dateCreated > rhs.dateCreated
                }
                .prefix(1)
        )

        ZStack {
            AppBackground()

            VStack(spacing: 28) {

                Spacer()

                VStack(spacing: 16) {

                
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 72, height: 72)
                            .shadow(radius: 8)

                        Image(systemName: "leaf")
                            .font(.system(size: 30))
                            .foregroundColor(.purple)
                    }

                    Text("Courage")
                        .font(.system(size: 36, weight: .bold))

                    Text("Breathe. Let's begin.")
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center) {
                        Text(viewModel.plantEmoji)
                            .font(.system(size: 34))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Your Courage Plant · \(viewModel.plantStageTitle)")
                                .font(.subheadline.weight(.semibold))
                            Text("\(viewModel.completedCount) completed tasks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    ProgressView(value: viewModel.progressToNextPlantStage)
                        .tint(.purple)

                    if viewModel.tasksToNextPlantStage > 0 {
                        Text("\(viewModel.tasksToNextPlantStage) more to grow to the next stage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Your plant is fully grown 🌸")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.84))
                .cornerRadius(16)

                NavigationLink(isActive: $showCreateTask) {
                    CreateTaskNameView(
                        viewModel: AddTaskViewModel(
                            taskService: viewModel.taskService,
                            stepService: viewModel.stepService
                        ),
                        onFlowFinished: {
                            showCreateTask = false
                        }
                    )
                } label: {
                    PrimaryActionButtonLabel(title: "Start something hard")
                }

                NavigationLink {
                    CourageLogView(
                        viewModel: CourageLogViewModel(
                            taskService: viewModel.taskService
                        )
                    )
                } label: {
                    SecondaryActionButtonLabel(title: "Courage Log")
                }

                NavigationLink(isActive: $navigateToActiveTask) {
                    if let taskID = selectedInProgressTaskID,
                       let activeVM = viewModel.activeStepViewModel(for: taskID) {
                        ActiveStepView(viewModel: activeVM)
                    }
                } label: {
                    EmptyView()
                }

                if !recentActiveTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("In Progress")
                            .font(.headline)

                        List {
                            ForEach(recentActiveTasks) { task in
                                VStack(spacing: 12) {
                                    Text(task.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)

                                    Text("Step \(task.shownStep) of \(task.totalSteps)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)

                                    Button {
                                        selectedInProgressTaskID = task.id
                                        navigateToActiveTask = true
                                    } label: {
                                        PrimaryActionButtonLabel(title: "Resume Task")
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.84))
                                .cornerRadius(16)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTask(id: task.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .frame(height: 180)
                        .listStyle(.plain)
                        .scrollDisabled(true)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear { viewModel.loadTasks() }
    }
}

#Preview {
    HomeView(viewModel: .preview)
}
