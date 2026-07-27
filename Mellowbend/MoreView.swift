import SwiftUI

struct MoreView: View {
    @EnvironmentObject var store: StretchStore
    @State private var showPrivacy = false
    @State private var showResetConfirm = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                SectionHeader(title: "More", subtitle: "Make Mellowbend yours")
                    .padding(.top, 8)

                SoftCard {
                    VStack(spacing: 4) {
                        SoftToggleRow(
                            title: "Gentle haptics",
                            subtitle: "Little taps between stretches",
                            icon: .sparkle, tint: SoftTheme.coral,
                            isOn: Binding(
                                get: { store.settings.hapticsOn },
                                set: { v in store.updateSettings { $0.hapticsOn = v } }))
                        Divider().background(SoftTheme.line)
                        SoftToggleRow(
                            title: "Coaching cues",
                            subtitle: "Soft text prompts during sessions",
                            icon: .clock, tint: SoftTheme.lavender,
                            isOn: Binding(
                                get: { store.settings.cuesOn },
                                set: { v in store.updateSettings { $0.cuesOn = v } }))
                        Divider().background(SoftTheme.line)
                        SoftToggleRow(
                            title: "Calmer motion",
                            subtitle: "Slower animation frame rate",
                            icon: .moon, tint: SoftTheme.sage,
                            isOn: Binding(
                                get: { store.settings.reduceMotion },
                                set: { v in store.updateSettings { $0.reduceMotion = v } }))
                    }
                }

                SoftCard {
                    VStack(spacing: 0) {
                        NavigationLink(destination: BuddyStudioView()) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                                        .fill(SoftTheme.coral.opacity(0.14))
                                        .frame(width: 38, height: 38)
                                    SoftIcon(kind: .heart, size: 19, color: SoftTheme.coral)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Meet Buddy").font(SoftTheme.body(15, .semibold)).foregroundColor(SoftTheme.ink)
                                    Text("Friendship, skins and keepsakes").font(SoftTheme.body(12)).foregroundColor(SoftTheme.inkSoft)
                                }
                                Spacer()
                                SoftIcon(kind: .chevronRight, size: 15, color: SoftTheme.ink.opacity(0.3))
                            }
                        }
                        .buttonStyle(SoftPressStyle())
                        Divider().background(SoftTheme.line).padding(.vertical, 8)
                        rowButton(icon: .shield, tint: SoftTheme.sky,
                                  title: "Privacy Policy",
                                  subtitle: "How your data is handled") {
                            showPrivacy = true
                        }
                        Divider().background(SoftTheme.line).padding(.vertical, 8)
                        rowButton(icon: .reset, tint: SoftTheme.rose,
                                  title: "Start fresh",
                                  subtitle: "Erase all progress and badges") {
                            showResetConfirm = true
                        }
                    }
                }

                SoftCard {
                    VStack(spacing: 10) {
                        HStack(spacing: 14) {
                            BuddyCanvas(pose: aboutPose, facing: .front, groundLevel: 0,
                                        muscles: [], glowPhase: 0.3, showMat: false)
                                .frame(width: 84, height: 100)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mellowbend")
                                    .font(SoftTheme.display(18))
                                    .foregroundColor(SoftTheme.ink)
                                Text("Version 1.0")
                                    .font(SoftTheme.body(12))
                                    .foregroundColor(SoftTheme.inkSoft)
                                Text("Made with Buddy, who never skips stretch day.")
                                    .font(SoftTheme.body(12))
                                    .foregroundColor(SoftTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer(minLength: 0)
                        }
                        Text("Move gently. Stop if anything hurts. This app offers general wellness guidance, not medical advice.")
                            .font(SoftTheme.body(11))
                            .foregroundColor(SoftTheme.inkSoft.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, SoftTheme.screenPad)
            .padding(.bottom, 24)
            .frame(maxWidth: SoftTheme.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(SoftTheme.cream.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            StretchWebPanel(urlString: "https://example.com")
        }
        .alert(isPresented: $showResetConfirm) {
            Alert(title: Text("Start fresh?"),
                  message: Text("All sessions, streaks and badges will be erased. This cannot be undone."),
                  primaryButton: .destructive(Text("Erase")) {
                      store.resetEverything()
                  },
                  secondaryButton: .cancel())
        }
    }

    private var aboutPose: BuddyPose {
        var p = BuddyPose()
        p.armRaiseL = 20
        p.armRaiseR = 145
        p.headTilt = -5
        return p
    }

    private func rowButton(icon: SoftIconKind, tint: Color, title: String,
                           subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(tint.opacity(0.14))
                        .frame(width: 38, height: 38)
                    SoftIcon(kind: icon, size: 19, color: tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(SoftTheme.body(15, .semibold)).foregroundColor(SoftTheme.ink)
                    Text(subtitle).font(SoftTheme.body(12)).foregroundColor(SoftTheme.inkSoft)
                }
                Spacer()
                SoftIcon(kind: .chevronRight, size: 15, color: SoftTheme.ink.opacity(0.3))
            }
        }
        .buttonStyle(SoftPressStyle())
    }
}
