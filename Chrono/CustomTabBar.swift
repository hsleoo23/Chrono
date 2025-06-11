import SwiftUI

struct CustomTabBar: View {
    @Binding var navIndex: Int
    @Binding var showAddTodo: Bool
    var body: some View {
        ZStack {
            // 底部导航栏背景，带中间凹槽
            BottomBarBackgroundShape()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 0)
                .frame(height: 80)
                .padding(.horizontal, 0)
            HStack {
                Spacer()
                ForEach(0..<2) { i in
                    TabBarItem(index: i, navIndex: $navIndex)
                    Spacer()
                }
                Spacer().frame(width: 56) // 中间加号预留
                ForEach(2..<4) { i in
                    Spacer()
                    TabBarItem(index: i, navIndex: $navIndex)
                }
                Spacer()
            }
            .frame(height: 80)
            .padding(.horizontal, 24)
            // 中间加号按钮
            Button(action: { showAddTodo = true }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.65, green: 0.8, blue: 0.45))
                        .frame(width: 68, height: 68)
                        .shadow(color: Color(red: 0.65, green: 0.8, blue: 0.45).opacity(0.25), radius: 18, x: 0, y: 8)
                        .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -28)
        }
        .padding(.bottom, 0)
    }
}

// 底部导航栏背景Shape（中间凹槽）
struct BottomBarBackgroundShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let curveWidth: CGFloat = 130
        let curveDepth: CGFloat = 55
        let center = width / 2
        return Path { path in
            path.move(to: CGPoint(x: 0, y: height/2))
            path.addArc(center: CGPoint(x: height/2, y: height/2), radius: height/2, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
            path.addLine(to: CGPoint(x: center - curveWidth/2, y: 0))
            // 凹槽
            path.addCurve(to: CGPoint(x: center, y: curveDepth),
                          control1: CGPoint(x: center - curveWidth/4, y: 0),
                          control2: CGPoint(x: center - curveWidth/4, y: curveDepth))
            path.addCurve(to: CGPoint(x: center + curveWidth/2, y: 0),
                          control1: CGPoint(x: center + curveWidth/4, y: curveDepth),
                          control2: CGPoint(x: center + curveWidth/4, y: 0))
            path.addLine(to: CGPoint(x: width - height/2, y: 0))
            path.addArc(center: CGPoint(x: width - height/2, y: height/2), radius: height/2, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
    }
}

struct TabBarItem: View {
    let index: Int
    @Binding var navIndex: Int
    var body: some View {
        Button(action: { navIndex = index }) {
            ZStack {
                if navIndex == index {
                    Circle()
                        .fill(Color(red: 0.96, green: 0.93, blue: 0.89))
                        .frame(width: 40, height: 40)
                }
                Image(systemName: tabIconName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(navIndex == index ? Color(red: 0.4, green: 0.32, blue: 0.24) : Color.gray.opacity(0.6))
            }
        }
    }
    var tabIconName: String {
        switch index {
        case 0: return "house.fill"
        case 1: return "chart.bar"
        case 2: return "lightbulb"
        case 3: return "person"
        default: return "circle"
        }
    }
} 