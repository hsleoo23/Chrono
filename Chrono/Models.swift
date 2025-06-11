import SwiftUI

// 标签颜色映射
let tagColors: [String: Color] = [
    "NOTICE": Color.orange,
    "MEALS": Color(red: 0.949, green: 0.718, blue: 0.0),
    "SPORT": Color.pink,
    "WORK": Color.blue
]

struct ScheduleItem: Identifiable {
    let id = UUID()
    let type: String // 如 "NOTICE", "SPORT", "MEALS", "WORK"
    let title: String
    let tag: String
    let time: String? // 具体时间段
    let subTag: String?
    let subTagColor: Color?
}

// 用于动态获取分组高度
struct GroupHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 44
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 