import SwiftUI

struct AppScreen<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppBackground()
            content
        }
    }
}