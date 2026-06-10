import SwiftUI

struct RadarChart: View {
    let values: [Double]   // 0–100 per area
    let labels: [String]

    private let gridLevels: [Double] = [0.25, 0.5, 0.75, 1.0]
    private let gridLabels = ["25", "50", "75", "100"]

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size / 2 - 44   // leave room for labels

            ZStack {
                // Grid rings
                ForEach(gridLevels.indices, id: \.self) { i in
                    polygon(count: values.count, center: center, radius: radius * gridLevels[i])
                        .stroke(Color(.systemGray4), lineWidth: i == gridLevels.count - 1 ? 1 : 0.5)
                }

                // Axis spokes
                ForEach(0..<values.count, id: \.self) { i in
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: point(i: i, n: values.count, center: center, r: radius))
                    }
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
                }

                // Data fill
                dataPath(center: center, radius: radius)
                    .fill(Color.accentColor.opacity(0.15))

                // Data outline
                dataPath(center: center, radius: radius)
                    .stroke(Color.accentColor, lineWidth: 2)

                // Data dots
                ForEach(0..<values.count, id: \.self) { i in
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 7, height: 7)
                        .position(dataPoint(i: i, n: values.count, center: center, radius: radius))
                }

                // Axis labels
                ForEach(0..<values.count, id: \.self) { i in
                    let labelPt = point(i: i, n: values.count, center: center, r: radius + 28)
                    let rate = Int(i < values.count ? values[i] : 0)
                    VStack(spacing: 1) {
                        Text(i < labels.count ? labels[i] : "")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                        Text("\(rate)%")
                            .font(.system(size: 9, weight: .regular).monospacedDigit())
                            .foregroundColor(.accentColor)
                    }
                    .multilineTextAlignment(.center)
                    .frame(width: 68)
                    .position(labelPt)
                }
            }
        }
    }

    // MARK: - Geometry helpers

    private func angle(i: Int, n: Int) -> Double {
        (Double(i) * 2 * .pi / Double(n)) - (.pi / 2)
    }

    private func point(i: Int, n: Int, center: CGPoint, r: CGFloat) -> CGPoint {
        let a = angle(i: i, n: n)
        return CGPoint(x: center.x + r * CGFloat(cos(a)),
                       y: center.y + r * CGFloat(sin(a)))
    }

    private func dataPoint(i: Int, n: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let fraction = CGFloat((i < values.count ? values[i] : 0) / 100.0)
        return point(i: i, n: n, center: center, r: radius * fraction)
    }

    private func polygon(count: Int, center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for i in 0..<count {
            let pt = point(i: i, n: count, center: center, r: radius)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }

    private func dataPath(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for i in 0..<values.count {
            let pt = dataPoint(i: i, n: values.count, center: center, radius: radius)
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}
