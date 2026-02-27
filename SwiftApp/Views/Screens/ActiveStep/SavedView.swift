
import SwiftUI

struct SavedView: View {

    var viewModel: ActiveStepViewModel
    var onBackToHome: () -> Void

    var body: some View {
        ZStack {
            
            
            VStack(spacing: 24) {
                Spacer()

                Text("✨")
                    .font(.system(size: 80))

            Text("Saved to your Courage Log.")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            if let reduction = viewModel.task.anxietyReduction {
                Text("Your anxiety dropped \(reduction) points.")
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                AppHaptics.light()
                onBackToHome()
            } label: {
                PrimaryActionButtonLabel(title: "Back to Home")

            }
            .buttonStyle(PressableScaleButtonStyle())
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        }
    }
}
