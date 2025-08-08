import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct YaamavaLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        YaamavaProgressBar(value: progress)
                            .frame(width: 80, height: 80)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct YaamavaBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct YaamavaProgressBar: View {
    let value: Double
    @State private var rotationAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            circularProgressContainer(in: geometry)
        }
    }

    private func circularProgressContainer(in geometry: GeometryProxy) -> some View {
        let size = min(geometry.size.width, geometry.size.height)
        return ZStack {
            backgroundCircle(size: size)
            progressCircle(size: size)
            centerGlow(size: size)
        }
        .frame(width: size, height: size)
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }

    private func backgroundCircle(size: CGFloat) -> some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#23272F").opacity(0.7), Color(hex: "#3B3F4A").opacity(0.7),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 8
            )
            .frame(width: size * 0.8, height: size * 0.8)
            .shadow(color: Color.black.opacity(0.15), radius: 3, y: 2)
    }

    private func progressCircle(size: CGFloat) -> some View {
        Circle()
            .trim(from: 0, to: CGFloat(value))
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FFE259"), Color(hex: "#F3D614"), Color(hex: "#FFD700"),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .frame(width: size * 0.8, height: size * 0.8)
            .rotationEffect(.degrees(-90))
            .shadow(color: Color.yellow.opacity(0.4), radius: 8, y: 0)
            .animation(.easeInOut(duration: 0.3), value: value)
    }

    private func centerGlow(size: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FFD700").opacity(0.3),
                        Color.clear,
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size * 0.2
                )
            )
            .frame(width: size * 0.4, height: size * 0.4)
            .scaleEffect(value > 0 ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.3), value: value)
    }
}

// MARK: - Превью

#Preview("Vertical") {
    YaamavaLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    YaamavaLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
