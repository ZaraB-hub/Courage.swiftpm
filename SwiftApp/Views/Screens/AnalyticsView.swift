//
//  AnalyticsView.swift
//  SwiftApp
//
//  Created by Zara Bahtanović on 25. 2. 26.
//

import SwiftUI

struct AnalyticsView: View {
    let taskService: TaskServices
    @State private var completedTasks: [Task] = []
    private let calendar = Calendar.current

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let calendarColumns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    private var averageReduction: Double {
        let reductions = completedTasks.compactMap { $0.anxietyReduction }
        guard !reductions.isEmpty else { return 0 }
        let total = reductions.reduce(0, +)
        return Double(total) / Double(reductions.count)
    }

    private var totalImpact: Int {
        completedTasks.compactMap(\.anxietyReduction).reduce(0, +)
    }

    private var completionDays: [Date] {
        let calendar = Calendar.current
        let normalized = completedTasks.map { calendar.startOfDay(for: $0.dateCompleted ?? $0.dateCreated) }
        let unique = Set(normalized)
        return unique.sorted(by: >)
    }

    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDay = calendar.startOfDay(for: .now)

        let daySet = Set(completionDays)
        while daySet.contains(currentDay) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDay) else { break }
            currentDay = previous
        }

        return streak
    }

    private var longestStreak: Int {
        let ascending = completionDays.sorted()
        guard !ascending.isEmpty else { return 0 }

        var best = 1
        var current = 1

        for index in 1..<ascending.count {
            let previous = ascending[index - 1]
            let day = ascending[index]

            if let expected = calendar.date(byAdding: .day, value: 1, to: previous),
               calendar.isDate(expected, inSameDayAs: day) {
                current += 1
            } else {
                best = max(best, current)
                current = 1
            }
        }

        return max(best, current)
    }

    private var monthStart: Date {
        let components = calendar.dateComponents([.year, .month], from: .now)
        return calendar.date(from: components) ?? .now
    }

    private var monthTitle: String {
        monthStart.formatted(.dateTime.month(.wide).year())
    }

    private var numberOfDaysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
    }

    private var leadingEmptyDays: Int {
        let weekday = calendar.component(.weekday, from: monthStart)
        return max(0, weekday - calendar.firstWeekday)
    }

    private var monthCompletionsByDay: [Int: Int] {
        var counts: [Int: Int] = [:]

        for task in completedTasks {
            let date = task.dateCompleted ?? task.dateCreated
            guard calendar.isDate(date, equalTo: monthStart, toGranularity: .month),
                  calendar.isDate(date, equalTo: monthStart, toGranularity: .year) else { continue }

            let day = calendar.component(.day, from: date)
            counts[day, default: 0] += 1
        }

        return counts
    }

    private var maxCompletionsInMonth: Int {
        max(1, monthCompletionsByDay.values.max() ?? 1)
    }

    private var dayCells: [Int?] {
        Array(repeating: nil, count: leadingEmptyDays) + Array(1...numberOfDaysInMonth).map { Optional($0) }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Analytics")
                        .font(.system(size: 34, weight: .bold))

                    LazyVGrid(columns: columns, spacing: 12) {
                        metricCard(
                            title: "Current Streak",
                            value: "\(currentStreak)",
                            icon: "flame.fill",
                            tint: .orange
                        )

                        metricCard(
                            title: "Tasks Completed",
                            value: "\(completedTasks.count)",
                            icon: "checkmark.seal.fill",
                            tint: .purple
                        )

                        metricCard(
                            title: "Avg Reduction",
                            value: String(format: "%.1f", averageReduction),
                            icon: "arrow.down.circle.fill",
                            tint: .purple
                        )

                        metricCard(
                            title: "Longest Streak",
                            value: "\(longestStreak)",
                            icon: "bolt.fill",
                            tint: .yellow
                        )

                        metricCard(
                            title: "Total Impact",
                            value: "\(totalImpact)",
                            icon: "chart.bar.fill",
                            tint: .green
                        )
                    }

                    calendarHeatmapCard

                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            completedTasks = taskService.getTasks().filter { $0.status == .completed }
        }
    }

    private func metricCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(tint)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
    }

    private var calendarHeatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text(monthTitle)
                    .font(.headline)
                Spacer()
            }

            LazyVGrid(columns: calendarColumns, spacing: 6) {
                ForEach(Array(calendar.veryShortWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let count = monthCompletionsByDay[day, default: 0]

                        Text("\(day)")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(count > 0 ? .purple : .secondary)
                            .frame(height: 28)
                            .frame(maxWidth: .infinity)
                            .background(dayColor(for: count))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    } else {
                        Color.clear
                            .frame(height: 28)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
    }

    private func dayColor(for count: Int) -> Color {
        guard count > 0 else { return Color.white.opacity(0.45) }
        let intensity = Double(count) / Double(maxCompletionsInMonth)
        return Color.purple.opacity(0.2 + (0.55 * intensity))
    }
}

#Preview {
    let repo = SwiftDataTaskRepository(inMemoryOnly: true)

    let service = TaskServices(
        repository: repo,
        stepGenerator: StepGeneratorService()
    )

    return NavigationStack {
        AnalyticsView(taskService: service)
    }
}
