import SwiftUI

// Splash shown while the launch check runs — Buddy breathing calmly.
struct SoftLaunchScreen: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            SoftTheme.cream.ignoresSafeArea()
            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(SoftTheme.buddyBody.opacity(0.16))
                        .frame(width: 210, height: 210)
                        .scaleEffect(pulse ? 1.06 : 0.94)
                    BuddyCanvas(pose: .standing, facing: .front, groundLevel: 0,
                                muscles: [], glowPhase: 0.3, showMat: false)
                        .frame(width: 190, height: 210)
                }
                Text("Soft Stretch")
                    .font(SoftTheme.display(30))
                    .foregroundColor(SoftTheme.ink)
                Text("warming up...")
                    .font(SoftTheme.body(15, .medium))
                    .foregroundColor(SoftTheme.inkSoft)
                    .opacity(pulse ? 1 : 0.45)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
