
import SwiftUI

struct CreateTaskNameView: View {

    @Bindable var viewModel: AddTaskViewModel
    var onFlowFinished: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss //built in dismiss fj 

    var body: some View {
        ZStack {

            AppBackground()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 12) {

                    Text("What are you avoiding right now?")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("It's okay. We will do one step at a time.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                
                ZStack(alignment: .topLeading) {

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 2)
                        .frame(height:120)

                    TextEditor(text: $viewModel.title)
                        .padding(12)
                        .frame(height: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)

                    if viewModel.title.isEmpty {
                        Text("e.g. Sending that difficult email...")
                            .foregroundColor(.gray)
                            .padding(18)
                    }
                }

                
                NavigationLink {
                    AnxietyView(viewModel: viewModel, onFlowFinished: onFlowFinished)
                } label: {
                    if viewModel.title.isEmpty {
                        SecondaryActionButtonLabel(title: "Continue")
                            .foregroundColor(.gray)
                            
                    } else {
                        PrimaryActionButtonLabel(title: "Continue")
                    }
                }
                .disabled(viewModel.title.isEmpty)

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top)
        }
    }
}


#Preview {
    CreateTaskNameView(viewModel: .preview)
}
