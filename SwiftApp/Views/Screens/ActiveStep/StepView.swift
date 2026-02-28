
import SwiftUI

struct StepView: View {

    var viewModel: ActiveStepViewModel
    var onCancelToHome: (() -> Void)? = nil
    @State private var isCancelHovered = false

    var body: some View {
        ZStack {

            AppBackground()

            VStack(spacing: 28) {

                VStack(spacing: 8) {

                    let completed = viewModel.task.steps.filter { $0.isCompleted }.count
                    let total = viewModel.task.steps.count
                    let shownStep = min(completed + 1, total)

                    Text("Step \(shownStep) of \(total)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ProgressView(value: Double(shownStep), total: Double(total))
                        .tint(.indigo)
                        .frame(maxWidth: .infinity)
                }

                Spacer()

                Text("One small step")
                    .font(.system(size: 30, weight: .bold))

                // Step card
                if let step = viewModel.currentStep {
                    Text(step.title)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(24)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                }

                Spacer()

                VStack(spacing: 16) {

                    
                    Button {
                        AppHaptics.medium()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            viewModel.completeCurrentStep()
                        }

                        if viewModel.isCompleted {
                            AppHaptics.success()
                        }
                    } label: {
                        PrimaryActionButtonLabel(title: "Done")
                    }
                    .buttonStyle(PressableScaleButtonStyle())

                    
                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            viewModel.tooHard()
                        }
                    } label: {
                        SecondaryActionButtonLabel(title: "Too hard right now")
                    }
                    .buttonStyle(PressableScaleButtonStyle())
                }
                .padding(.horizontal)
                .padding(.bottom, 32)

                Button {
                    onCancelToHome?()
                } label: {
                    Text("×  Can't do this now")
                        .font(.caption)
                }
                .buttonStyle(CancelActionButtonStyle(isHovered: isCancelHovered))
                .onHover { isHovering in
                    isCancelHovered = isHovering
                }
                .padding(.bottom)
            }
        }
    }
}

private struct CancelActionButtonStyle: ButtonStyle {

    let isHovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed || isHovered ? .red : .secondary)
    }
}
