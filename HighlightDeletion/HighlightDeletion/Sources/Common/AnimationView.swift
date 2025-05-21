import DotLottie
import SwiftUI

struct AnimationView: View {

    @Binding private var isAnimating: Bool
    @State private var animation: DotLottieAnimation

    init(isAnimating: Binding<Bool>) {
        self._isAnimating = isAnimating
        self.animation = DotLottieAnimation(
            fileName: "sparkles",
            config: AnimationConfig(autoplay: false, loop: true)
        )
    }

    var body: some View {
        animation.view()
            .onChange(of: isAnimating) { _, shouldAnimate in
                if shouldAnimate {
                    animation.play()
                } else {
                    animation.pause()
                }
            }
    }
}
