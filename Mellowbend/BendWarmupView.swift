import SwiftUI

struct BendWarmupView: View {
    @State private var breathing = false

    var body: some View {
        ZStack {
            SoftTheme.cream.ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(SoftTheme.coral.opacity(0.12))
                        .frame(width: 108, height: 108)
                        .scaleEffect(breathing ? 1.12 : 0.88)

                    Circle()
                        .fill(SoftTheme.buddyBody)
                        .frame(width: 62, height: 62)
                        .scaleEffect(breathing ? 1.06 : 0.94)
                        .shadow(color: SoftTheme.cardShadow, radius: 10, x: 0, y: 5)
                }
                .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                           value: breathing)

                VStack(spacing: 5) {
                    Text("Mellowbend")
                        .font(SoftTheme.display(21))
                        .foregroundColor(SoftTheme.ink)
                    Text("Rolling out the mat…")
                        .font(SoftTheme.body(13))
                        .foregroundColor(SoftTheme.inkSoft)
                }
            }
        }
        .onAppear { breathing = true }
    }
}
