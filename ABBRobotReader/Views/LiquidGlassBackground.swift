import SwiftUI

struct LiquidGlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.55),
                    Color(red: 0.22, green: 0.12, blue: 0.38),
                    Color(red: 0.05, green: 0.19, blue: 0.31)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 320)
                .blur(radius: 80)
                .offset(x: -140, y: -240)

            Circle()
                .fill(Color.blue.opacity(0.22))
                .frame(width: 420)
                .blur(radius: 120)
                .offset(x: 160, y: -60)

            Circle()
                .fill(Color.pink.opacity(0.18))
                .frame(width: 380)
                .blur(radius: 120)
                .offset(x: -120, y: 240)

            AngularGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.05),
                    Color.white.opacity(0.15)
                ]),
                center: .center
            )
            .blendMode(.screen)
            .opacity(0.6)
            .blur(radius: 140)
        }
    }
}

struct GlassContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 12)
    }
}
