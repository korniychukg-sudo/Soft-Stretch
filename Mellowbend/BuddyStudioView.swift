import SwiftUI

struct BuddyStudioView: View {
    @EnvironmentObject var store: StretchStore
    @EnvironmentObject var companion: CompanionStore
    @Environment(\.presentationMode) var presentationMode
    @State private var previewPulse = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                topBar
                preview
                friendshipCard
                skinsCard
                accessoriesCard
            }
            .padding(.horizontal, SoftTheme.screenPad)
            .padding(.bottom, 24)
            .frame(maxWidth: SoftTheme.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(SoftTheme.cream.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var topBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                ZStack {
                    Circle().fill(SoftTheme.card).frame(width: 36, height: 36)
                        .shadow(color: SoftTheme.cardShadow, radius: 5, x: 0, y: 2)
                    SoftIcon(kind: .chevronLeft, size: 18, color: SoftTheme.ink)
                }
            }
            .buttonStyle(SoftPressStyle())
            Spacer()
            Text("Buddy Studio")
                .font(SoftTheme.display(20))
                .foregroundColor(SoftTheme.ink)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.top, 8)
    }

    private var preview: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [BuddySkins.byID(companion.outfit.skinID).body.opacity(0.25),
                                              SoftTheme.cream],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 230, height: 230)
            BuddyCanvas(pose: .standing, facing: .front, groundLevel: 0,
                        muscles: [], glowPhase: 0.25, showMat: false,
                        outfit: companion.outfit, mood: .happy)
                .frame(width: 210, height: 235)
        }
        .scaleEffect(previewPulse ? 1.05 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: previewPulse)
    }

    private func pulse() {
        previewPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { previewPulse = false }
    }

    private var friendshipCard: some View {
        let prog = Friendship.progressToNext(companion.xp)
        return SoftCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LEVEL \(companion.level)")
                            .font(SoftTheme.body(11, .bold))
                            .foregroundColor(SoftTheme.coral)
                            .kerning(1.2)
                        Text(Friendship.levelName(companion.level))
                            .font(SoftTheme.display(20))
                            .foregroundColor(SoftTheme.ink)
                    }
                    Spacer()
                    Text(companion.level >= 12 ? "MAX" : "\(prog.need - prog.have) xp to next")
                        .font(SoftTheme.body(12, .semibold))
                        .foregroundColor(SoftTheme.inkSoft)
                }
                GeometryReader { g in
                    ZStack(alignment: .leading) {
                        Capsule().fill(SoftTheme.coral.opacity(0.12))
                        Capsule().fill(SoftTheme.coral)
                            .frame(width: max(g.size.width * prog.fraction, 8))
                    }
                }
                .frame(height: 10)
                if let next = RewardTable.reward(at: companion.level + 1) {
                    HStack(spacing: 6) {
                        SoftIcon(kind: .lock, size: 13, color: SoftTheme.inkSoft)
                        Text("Level \(next.level) unlocks: \(next.title)")
                            .font(SoftTheme.body(12, .medium))
                            .foregroundColor(SoftTheme.inkSoft)
                    }
                }
                Text("Earn friendship xp with every stretching session.")
                    .font(SoftTheme.body(12))
                    .foregroundColor(SoftTheme.inkSoft)
            }
        }
    }

    private var skinsCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Skins")
                    .font(SoftTheme.display(17))
                    .foregroundColor(SoftTheme.ink)
                HStack(spacing: 12) {
                    ForEach(BuddySkins.all, id: \.id) { skin in
                        skinSwatch(skin)
                    }
                }
            }
        }
    }

    private func skinSwatch(_ skin: BuddySkin) -> some View {
        let unlocked = companion.isSkinUnlocked(skin.id)
        let equipped = companion.outfit.skinID == skin.id
        return Button(action: {
            guard unlocked else { return }
            SoftHaptics.tap(store)
            companion.equipSkin(skin.id)
            pulse()
        }) {
            VStack(spacing: 5) {
                ZStack {
                    Circle().fill(skin.body).frame(width: 40, height: 40)
                        .overlay(Circle().stroke(equipped ? SoftTheme.coral : Color.clear, lineWidth: 3))
                    if !unlocked {
                        Circle().fill(Color.white.opacity(0.55)).frame(width: 40, height: 40)
                        SoftIcon(kind: .lock, size: 14, color: SoftTheme.ink.opacity(0.55))
                    }
                }
                Text(unlocked ? (skin.name.split(separator: " ").last.map(String.init) ?? skin.name)
                              : "Lv \(RewardTable.skinUnlockLevel(skin.id))")
                    .font(SoftTheme.body(10, .semibold))
                    .foregroundColor(unlocked ? SoftTheme.inkSoft : SoftTheme.ink.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SoftPressStyle())
    }

    private var accessoriesCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Accessories")
                    .font(SoftTheme.display(17))
                    .foregroundColor(SoftTheme.ink)
                let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 12) {
                    accessoryTile(nil, name: "None")
                    ForEach(BuddyAccessories.all) { acc in
                        accessoryTile(acc.id, name: acc.name)
                    }
                }
            }
        }
    }

    private func accessoryTile(_ id: String?, name: String) -> some View {
        let unlocked = id.map { companion.isAccessoryUnlocked($0) } ?? true
        let equipped = companion.outfit.accessoryID == id
        return Button(action: {
            guard unlocked else { return }
            SoftHaptics.tap(store)
            companion.equipAccessory(id)
            pulse()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(SoftTheme.cream)
                        .frame(height: 62)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(equipped ? SoftTheme.coral : SoftTheme.line, lineWidth: equipped ? 2.5 : 1))
                    if let id = id {
                        AccessoryMini(accessoryID: id, skinID: companion.outfit.skinID)
                            .frame(width: 54, height: 54)
                            .opacity(unlocked ? 1 : 0.35)
                    } else {
                        SoftIcon(kind: .close, size: 18, color: SoftTheme.inkSoft)
                    }
                    if !unlocked, let id = id {
                        VStack {
                            Spacer()
                            Text("Lv \(RewardTable.accessoryUnlockLevel(id))")
                                .font(SoftTheme.body(10, .bold))
                                .foregroundColor(SoftTheme.ink.opacity(0.5))
                                .padding(.bottom, 4)
                        }
                        .frame(height: 62)
                    }
                }
                Text(name)
                    .font(SoftTheme.body(11, .semibold))
                    .foregroundColor(SoftTheme.inkSoft)
                    .lineLimit(1)
            }
        }
        .buttonStyle(SoftPressStyle())
    }
}

struct AccessoryMini: View {
    let accessoryID: String
    let skinID: String

    var body: some View {
        Canvas { ctx, size in

            let scale = size.width / 320 * 2.4
            var zoomed = ctx
            zoomed.translateBy(x: size.width / 2, y: size.height / 2 + 6)
            zoomed.scaleBy(x: scale, y: scale)
            zoomed.translateBy(x: -160, y: -133)
            var pose = BuddyPose.standing
            pose.breathe = 0
            renderBuddy(zoomed, pose: pose, facing: .front, groundLevel: 0,
                        muscles: [], glowPhase: 0, showMat: false,
                        outfit: BuddyOutfit(skinID: skinID, accessoryID: accessoryID),
                        mood: .content)
        }
        .clipped()
    }
}
