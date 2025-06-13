import SwiftUI

// 标签颜色映射
let tagColors: [String: Color] = [
    "健康": Color.green,
    "能量": Color.yellow,
    "补充": Color.purple,
    "有氧": Color.cyan,
    "户外": Color.brown,
    "打工": Color.blue,
    "专注": Color.indigo,
    "运动": Color.pink
]

struct ScheduleItem: Identifiable, Codable {
    let id: UUID
    let type: String // 如 "NOTICE", "SPORT", "MEALS", "WORK"
    let title: String
    let tag: String
    let time: String? // 具体时间段
    let subTag: String?
    let subTagColor: ColorCodable?
    let otherTags: [String]? // 新增，支持多个标签
    let note: String? // 新增备注字段
    
    init(id: UUID = UUID(), type: String, title: String, tag: String, time: String?, subTag: String?, subTagColor: Color?, otherTags: [String]?, note: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.tag = tag
        self.time = time
        self.subTag = subTag
        self.subTagColor = subTagColor != nil ? ColorCodable(color: subTagColor!) : nil
        self.otherTags = otherTags
        self.note = note
    }
}

// 颜色的Codable包装
struct ColorCodable: Codable {
    let color: Color
    init(color: Color) { self.color = color }
    enum CodingKeys: String, CodingKey { case red, green, blue, alpha }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(a, forKey: .alpha)
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(CGFloat.self, forKey: .red)
        let g = try container.decode(CGFloat.self, forKey: .green)
        let b = try container.decode(CGFloat.self, forKey: .blue)
        let a = try container.decode(CGFloat.self, forKey: .alpha)
        self.color = Color(UIColor(red: r, green: g, blue: b, alpha: a))
    }
}

// 用于动态获取分组高度
struct GroupHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 44
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 
