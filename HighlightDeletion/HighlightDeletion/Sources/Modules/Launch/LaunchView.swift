import SwiftUI

struct LaunchView: View {

    @State private var isAnimating = false
    @Binding private var isLaunching: Bool

    init(isLaunching: Binding<Bool>) {
        self._isLaunching = isLaunching
    }

    var body: some View {
        AnimationView(isAnimating: $isAnimating)
            .frame(height: 180, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primaryBackground)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.isAnimating = false
                        self.isLaunching = false
                    }
                }
            }
    }
}
