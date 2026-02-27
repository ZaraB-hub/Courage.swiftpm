
import SwiftUI

struct CourageLogView: View {

    @State var viewModel: CourageLogViewModel

    var body: some View {
        ZStack {
            AppBackground()

            VStack(alignment: .leading, spacing: 16) {
                Text("Courage Log")
                    .font(.system(size: 34, weight: .bold))

                Text("\(viewModel.entryCount) entries")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Avg reduction")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", viewModel.averageReduction))
                                .font(.title2.weight(.bold))
                                .foregroundColor(.purple)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .cornerRadius(16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total tasks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.totalCompletedTasks)")
                                .font(.title2.weight(.bold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white.opacity(0.92))
                        .cornerRadius(16)
                    }

                    NavigationLink {
                        AnalyticsView(taskService: viewModel.taskService)
                    } label: {
                        SecondaryActionButtonLabel(title: "View Full Analytics")
                    }
                }

                if viewModel.tasks.isEmpty {
                    Text("No completed tasks yet.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.tasks) { task in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top) {
                                    Text(task.title)
                                        .font(.headline)

                                    Spacer()

                                    if let anxietyAfter = task.anxietyAfter {
                                        anxietyTrendBadge(before: task.anxietyBefore, after: anxietyAfter)
                                    }
                                }

                                Text((task.dateCompleted ?? task.dateCreated).formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 16) {
                                    HStack(spacing: 4) {
                                        Text("Before:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(task.anxietyBefore)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.purple)
                                    }

                                    HStack(spacing: 4) {
                                        Text("After:")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(task.anxietyAfter.map(String.init) ?? "—")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.purple)
                                    }
                                }

                                if let reflection = task.reflection, !reflection.isEmpty {
                                    Divider()

                                    Text("\"\(reflection)\"")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.92))
                            .cornerRadius(18)
                            .padding(.vertical, 6)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.delete(id: task.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.load()
        }
    }

    @ViewBuilder
    private func anxietyTrendBadge(before: Int, after: Int) -> some View {
        let wentUp = after > before
        let wentDown = after < before

        Image(systemName: wentUp ? "chart.line.uptrend.xyaxis" : wentDown ? "chart.line.downtrend.xyaxis" : "minus")
            .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background((wentUp ? Color.red : wentDown ? Color.green : Color.secondary).opacity(0.16))
        .foregroundColor(wentUp ? .red : wentDown ? .green : .secondary)
        .clipShape(Capsule())
    }
}
