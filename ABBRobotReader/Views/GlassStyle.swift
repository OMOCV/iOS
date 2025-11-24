import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.13, green: 0.2, blue: 0.35), Color(red: 0.05, green: 0.08, blue: 0.16)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            ZStack {
                Circle()
                    .fill(Color(red: 0.29, green: 0.6, blue: 0.98).opacity(0.35))
                    .blur(radius: 120)
                    .frame(width: 240, height: 240)
                    .offset(x: -120, y: -160)

                Circle()
                    .fill(Color(red: 0.99, green: 0.65, blue: 0.45).opacity(0.25))
                    .blur(radius: 140)
                    .frame(width: 260, height: 260)
                    .offset(x: 160, y: 200)

                RoundedRectangle(cornerRadius: 120)
                    .fill(Color.white.opacity(0.08))
                    .blur(radius: 90)
                    .rotationEffect(.degrees(12))
                    .frame(width: 320, height: 520)
                    .offset(x: 80, y: -40)
            }
        )
    }
}

struct FrostedGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 12)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(FrostedGlassCard())
    }

    @ViewBuilder
    func glassToolbarStyle() -> some View {
        if #available(iOS 16.0, *) {
            self
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
        } else {
            self
        }
    }

    @ViewBuilder
    func glassListBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}
