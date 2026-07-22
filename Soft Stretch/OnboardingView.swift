import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: StretchStore
    @State private var page = 0

    private let pages: [(art: String, title: String, text: String)] = [
        ("onb_meet", "Meet your stretch buddy",
         "A little companion who moves with you in real time — every stretch, every breath, side by side."),
        ("onb_glow", "See what's working",
         "Buddy's body glows warm exactly where the stretch works, so you always know what you should feel."),
        ("onb_daily", "Grow a friendship",
         "Every session earns friendship xp — Buddy unlocks new looks, and the nook you share fills with keepsakes. Five soft minutes a day is plenty.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(0..<pages.count, id: \.self) { i in
                    VStack(spacing: 26) {
                        Spacer(minLength: 10)
                        ArtImage(name: pages[i].art, corner: 30)
                            .frame(maxWidth: 420, maxHeight: 380)
                            .aspectRatio(0.86, contentMode: .fit)
                            .padding(.horizontal, 30)
                        VStack(spacing: 12) {
                            Text(pages[i].title)
                                .font(SoftTheme.display(26))
                                .foregroundColor(SoftTheme.ink)
                                .multilineTextAlignment(.center)
                            Text(pages[i].text)
                                .font(SoftTheme.body(16))
                                .foregroundColor(SoftTheme.inkSoft)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                                .padding(.horizontal, 36)
                        }
                        Spacer(minLength: 10)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? SoftTheme.coral : SoftTheme.ink.opacity(0.15))
                        .frame(width: i == page ? 22 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: page)
                }
            }
            .padding(.bottom, 26)

            VStack(spacing: 12) {
                SoftPrimaryButton(title: page == pages.count - 1 ? "Let's stretch" : "Continue") {
                    if page < pages.count - 1 {
                        withAnimation(.easeInOut(duration: 0.3)) { page += 1 }
                    } else {
                        SoftHaptics.success(store)
                        store.updateSettings { $0.onboarded = true }
                    }
                }
                Button(action: { store.updateSettings { $0.onboarded = true } }) {
                    Text("Skip for now")
                        .font(SoftTheme.body(14, .medium))
                        .foregroundColor(SoftTheme.inkSoft)
                }
                .buttonStyle(SoftPressStyle())
                .opacity(page == pages.count - 1 ? 0 : 1)
            }
            .padding(.horizontal, 34)
            .padding(.bottom, 26)
        }
        .frame(maxWidth: SoftTheme.contentMaxWidth)
        .frame(maxWidth: .infinity)
        .background(SoftTheme.cream.ignoresSafeArea())
    }
}
