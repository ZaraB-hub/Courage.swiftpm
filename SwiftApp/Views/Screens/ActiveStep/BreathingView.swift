
import SwiftUI

struct BreathingView: View {
    
    var viewModel: ActiveStepViewModel
    
    var body: some View {
        VStack(spacing: 48) {
            
            HStack(){
                Spacer()
                Button {
                    viewModel.isBreathing = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }.padding().padding(.horizontal)
            
            
            Text(viewModel.breathingPhase)
                .font(.system(size: 36, weight: .light))
            
            Text("Cycle \(viewModel.breathingCycle) of \(viewModel.totalBreathingCycles)")
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.15), lineWidth: 2)
                    .frame(width: 220, height: 220)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.3), Color.mint.opacity(0.2)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 110
                        )
                    )
                    .frame(
                        width: 80 + (viewModel.breathingProgress * 140),
                        height: 80 + (viewModel.breathingProgress * 140)
                    )
                    .animation(.easeInOut(duration: viewModel.breathingAnimationDuration), value: viewModel.breathingProgress)
            }
            
            Text("Breathe with me")
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    BreathingView(viewModel: .preview)
}
