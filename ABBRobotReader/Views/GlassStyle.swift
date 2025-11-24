import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.09, green: 0.15, blue: 0.28),
                Color(red: 0.03, green: 0.05, blue: 0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            ZStack {
                angularGlassBlob(color: Color(red: 0.34, green: 0.66, blue: 0.98), blur: 130, size: 280)
                    .offset(x: -160, y: -200)

                angularGlassBlob(color: Color(red: 0.99, green: 0.54, blue: 0.43), blur: 150, size: 320)
                    .offset(x: 220, y: 240)

                angularGlassBlob(color: Color.white.opacity(0.35), blur: 200, size: 360)
                    .blendMode(.screen)
                    .offset(x: -40, y: 160)
            }
        )
    }

    @ViewBuilder
    private func angularGlassBlob(color: Color, blur: CGFloat, size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: size / 2, style: .continuous)
            .fill(color.opacity(0.32))
            .frame(width: size, height: size * 1.1)
            .rotationEffect(.degrees(-18))
            .blur(radius: blur)
            .shadow(color: color.opacity(0.3), radius: blur / 2)
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
        self
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
    }

    @ViewBuilder
    func glassListBackground() -> some View {
        self.scrollContentBackground(.hidden)
    }
}
