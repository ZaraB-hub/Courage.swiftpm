import SwiftUI

struct BackCircleButton: View {

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
                .shadow(radius: 6)
        }
    }
}

struct PrimaryActionButtonLabel: View {

    let title: String
    var isLoading: Bool = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text(title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.purple.opacity(0.6)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(22)
    }
}

struct SecondaryActionButtonLabel: View {

    let title: String

    var body: some View {
        Text(title)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.9))
            .foregroundStyle(Color.black)
            .cornerRadius(22)
    }
}

struct PressableScaleButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
