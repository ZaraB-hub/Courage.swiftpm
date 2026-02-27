

import SwiftUI
import UIKit

struct ActiveStepView: View {

    @State var viewModel: ActiveStepViewModel
    var onFlowFinished: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    private enum ScreenState {
        case saved
        case reflection
        case completed
        case breathing
        case step
    }

    private var screenState: ScreenState {
        if viewModel.taskSaved { return .saved }
        if viewModel.showReflection { return .reflection }
        if viewModel.isCompleted { return .completed }
        if viewModel.isBreathing { return .breathing }
        return .step
    }

    private var shouldLockBackNavigation: Bool {
        true
    }

    private func finishFlow() {
        if let onFlowFinished {
            onFlowFinished()
        } else {
            dismiss()
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            switch screenState {
            case .saved:
                SavedView(viewModel: viewModel) {
                    finishFlow()
                }
            case .reflection:
                ReflectionView(viewModel: viewModel)
            case .completed:
                CompletedView(viewModel: viewModel)
            case .breathing:
                BreathingView(viewModel: viewModel)
            case .step:
                StepView(viewModel: viewModel) {
                    finishFlow()
                }
            }
        }
        .navigationBarBackButtonHidden(shouldLockBackNavigation)
        .background(
            BackNavigationControllerLock(isLocked: shouldLockBackNavigation)
        )
        .onDisappear {
            guard screenState == .step else { return }
            onFlowFinished?()
        }
    }
}

private struct BackNavigationControllerLock: UIViewControllerRepresentable {

    let isLocked: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let navigationController = uiViewController.navigationController else { return }
        navigationController.interactivePopGestureRecognizer?.isEnabled = !isLocked
    }
}
