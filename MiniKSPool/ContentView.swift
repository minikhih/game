import SwiftUI

private enum PoolTheme {
    static let background = Color(red: 0.035, green: 0.025, blue: 0.065)
    static let panel = Color(red: 0.085, green: 0.060, blue: 0.130)
    static let violet = Color(red: 0.68, green: 0.36, blue: 1.0)
    static let muted = Color(red: 0.66, green: 0.61, blue: 0.75)
    static let felt = Color(red: 0.035, green: 0.31, blue: 0.23)
}

struct ContentView: View {
    @State private var aimAngle = 28.0
    @State private var power = 62.0
    @State private var cuePosition = CGPoint(x: 0.25, y: 0.55)
    @State private var targetPosition = CGPoint(x: 0.72, y: 0.38)
    @State private var selectedTab = 0

    private var radians: CGFloat { aimAngle * .pi / 180 }

    var body: some View {
        ZStack {
            PoolTheme.background.ignoresSafeArea()
            VStack(spacing: 18) {
                header
                if selectedTab == 0 {
                    practiceView
                } else if selectedTab == 1 {
                    statsView
                } else {
                    settingsView
                }
                Spacer(minLength: 4)
                tabBar
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .tint(PoolTheme.violet)
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(PoolTheme.violet.opacity(0.18))
                    .frame(width: 46, height: 46)
                Image(systemName: "circle.grid.cross.fill")
                    .font(.system(size: 21, weight: .bold))
                    .foregroundStyle(PoolTheme.violet)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("MINIKS POOL")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .tracking(1.4)
                Text("VIP  •  PRACTICE COMPANION")
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1.1)
                    .foregroundStyle(PoolTheme.muted)
            }
            Spacer()
            Circle().fill(Color.green).frame(width: 7, height: 7)
            Text("READY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.green)
        }
        .padding(14)
        .background(PoolTheme.panel, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.07)))
    }

    private var practiceView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AIM PRACTICE")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(PoolTheme.muted)
                    Text("Bàn tập ngắm")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                }
                Spacer()
                Text("DEMO TABLE")
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(PoolTheme.violet.opacity(0.16), in: Capsule())
                    .foregroundStyle(PoolTheme.violet)
            }
            tableView.frame(height: 245)
            HStack(spacing: 10) {
                metricCard(title: "GÓC NGẮM", value: String(format: "%.0f°", aimAngle), icon: "scope")
                metricCard(title: "LỰC ĐÁNH", value: "\(Int(power))%", icon: "gauge")
                metricCard(title: "HƯỚNG", value: directionLabel, icon: "arrow.up.right")
            }
            controlCard
            Text("Bảng tập độc lập · Không đọc dữ liệu từ game")
                .font(.system(size: 10))
                .foregroundStyle(PoolTheme.muted)
                .frame(maxWidth: .infinity)
        }
    }

    private var tableView: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(Color(red: 0.20, green: 0.10, blue: 0.07))
                RoundedRectangle(cornerRadius: 16).fill(PoolTheme.felt).padding(12)
                RoundedRectangle(cornerRadius: 13).stroke(Color.white.opacity(0.22), lineWidth: 1).padding(18)
                ForEach(0..<6, id: \.self) { index in
                    pocket(at: pocketPoint(index, in: size))
                }
                Path { path in
                    let start = CGPoint(x: cuePosition.x * size.width, y: cuePosition.y * size.height)
                    let end = CGPoint(
                        x: start.x + cos(radians) * size.width * 0.55,
                        y: start.y - sin(radians) * size.height * 0.55
                    )
                    path.move(to: start)
                    path.addLine(to: end)
                }
                .stroke(PoolTheme.violet, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 5]))

                ball(color: .white, label: "C")
                    .position(x: cuePosition.x * size.width, y: cuePosition.y * size.height)
                    .gesture(DragGesture().onChanged { cuePosition = normalized($0.location, in: size) })

                ball(color: .yellow, label: "8")
                    .position(x: targetPosition.x * size.width, y: targetPosition.y * size.height)
                    .gesture(DragGesture().onChanged { targetPosition = normalized($0.location, in: size) })

                Image(systemName: "scope")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .position(
                        x: min(max(cuePosition.x * size.width + cos(radians) * 72, 25), size.width - 25),
                        y: min(max(cuePosition.y * size.height - sin(radians) * 72, 25), size.height - 25)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(PoolTheme.violet.opacity(0.35), lineWidth: 1))
        }
    }

    private func normalized(_ point: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(
            x: min(max(point.x / max(size.width, 1), 0.08), 0.92),
            y: min(max(point.y / max(size.height, 1), 0.10), 0.90)
        )
    }

    private func pocketPoint(_ index: Int, in size: CGSize) -> CGPoint {
        let points = [
            CGPoint(x: 15, y: 15), CGPoint(x: size.width / 2, y: 15),
            CGPoint(x: size.width - 15, y: 15), CGPoint(x: 15, y: size.height - 15),
            CGPoint(x: size.width / 2, y: size.height - 15),
            CGPoint(x: size.width - 15, y: size.height - 15)
        ]
        return points[index]
    }

    private func pocket(at point: CGPoint) -> some View {
        Circle().fill(Color.black.opacity(0.85)).frame(width: 17, height: 17).position(point)
    }

    private func ball(color: Color, label: String) -> some View {
        ZStack {
            Circle().fill(color).frame(width: 23, height: 23)
                .shadow(color: .black.opacity(0.35), radius: 3, y: 2)
            Text(label).font(.system(size: 9, weight: .black)).foregroundStyle(.black)
        }
    }

    private var directionLabel: String {
        let value = (Int(aimAngle.rounded()) % 360 + 360) % 360
        return value < 90 ? "NE" : value < 180 ? "NW" : value < 270 ? "SW" : "SE"
    }

    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon).foregroundStyle(PoolTheme.violet)
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 8, weight: .bold)).foregroundStyle(PoolTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(PoolTheme.panel, in: RoundedRectangle(cornerRadius: 14))
    }

    private var controlCard: some View {
        VStack(spacing: 14) {
            VStack(spacing: 7) {
                HStack {
                    Text("Góc ngắm")
                    Spacer()
                    Text("\(Int(aimAngle))°").foregroundStyle(PoolTheme.violet).monospacedDigit()
                }
                .font(.system(size: 12, weight: .semibold))
                Slider(value: $aimAngle, in: 0...359, step: 1)
            }
            VStack(spacing: 7) {
                HStack {
                    Text("Lực đánh")
                    Spacer()
                    Text("\(Int(power))%").foregroundStyle(PoolTheme.violet).monospacedDigit()
                }
                .font(.system(size: 12, weight: .semibold))
                Slider(value: $power, in: 1...100, step: 1)
            }
            HStack {
                Button {
                    cuePosition = CGPoint(x: 0.25, y: 0.55)
                    targetPosition = CGPoint(x: 0.72, y: 0.38)
                    aimAngle = 28
                    power = 62
                } label: {
                    Label("Đặt lại", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 11, weight: .bold))
                }
                .buttonStyle(.bordered)
                Spacer()
                Text("Kéo bi để đổi vị trí").font(.system(size: 10)).foregroundStyle(PoolTheme.muted)
            }
        }
        .padding(14)
        .background(PoolTheme.panel, in: RoundedRectangle(cornerRadius: 16))
    }

    private var statsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PRACTICE HUD").font(.system(size: 12, weight: .bold)).tracking(1.4).foregroundStyle(PoolTheme.muted)
            Text("Thông số luyện tập").font(.system(size: 23, weight: .bold, design: .rounded))
            metricCard(title: "GÓC HIỆN TẠI", value: "\(Int(aimAngle))°", icon: "scope")
            metricCard(title: "LỰC ĐÁNH", value: "\(Int(power))%", icon: "gauge")
            metricCard(title: "VỊ TRÍ BI CƠ", value: "\(Int(cuePosition.x * 100))%, \(Int(cuePosition.y * 100))%", icon: "circle")
            Text("Các chỉ số được tính từ thao tác trong bàn tập của ứng dụng.")
                .font(.system(size: 11)).foregroundStyle(PoolTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var settingsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("SETTINGS").font(.system(size: 12, weight: .bold)).tracking(1.4).foregroundStyle(PoolTheme.muted)
            Text("Cài đặt").font(.system(size: 23, weight: .bold, design: .rounded))
            Label("Giao diện tím neon", systemImage: "paintpalette")
            Label("Bàn tập kéo thả", systemImage: "hand.draw")
            Label("Hiển thị góc và lực", systemImage: "scope")
            Divider().overlay(.white.opacity(0.1))
            Text("MINIKS POOL VIP · v1.0.0").font(.system(size: 10, weight: .bold)).foregroundStyle(PoolTheme.muted)
            Text("Ứng dụng companion độc lập. iOS không cho phép ứng dụng này vẽ đè hoặc điều khiển game khác.")
                .font(.system(size: 11)).foregroundStyle(PoolTheme.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(PoolTheme.panel, in: RoundedRectangle(cornerRadius: 18))
    }

    private var tabBar: some View {
        HStack(spacing: 8) {
            tabButton("Practice", icon: "scope", index: 0)
            tabButton("HUD", icon: "chart.bar", index: 1)
            tabButton("Settings", icon: "gearshape", index: 2)
        }
        .padding(8)
        .background(PoolTheme.panel, in: RoundedRectangle(cornerRadius: 17))
    }

    private func tabButton(_ title: String, icon: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 16, weight: .semibold))
                Text(title).font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(selectedTab == index ? PoolTheme.violet : PoolTheme.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .background(selectedTab == index ? PoolTheme.violet.opacity(0.12) : .clear,
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
