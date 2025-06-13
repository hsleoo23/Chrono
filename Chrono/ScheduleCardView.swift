import SwiftUI

struct ScheduleCardView: View {
    let item: ScheduleItem
    var isDoneStyle: Bool = false // 新增参数，Done页传true
    var onCircleTap: (() -> Void)? = nil // 新增参数
    
    // 计算主标签颜色
    var tagColor: Color {
        globalCategoryColors[item.tag] ?? Color.gray
    }
    // 解析时间段
    var startTime: String? {
        guard let time = item.time else { return nil }
        return time.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces)
    }
    var endTime: String? {
        guard let time = item.time, time.contains("-") else { return nil }
        return time.components(separatedBy: "-").last?.trimmingCharacters(in: .whitespaces)
    }
    // 总用时（如40分钟、5秒等）
    var durationText: String? {
        if let subTag = item.subTag, isDoneStyle {
            return subTag
        }
        return nil
    }
    // 其他标签（done页：不含总用时）
    var otherTags: [String] {
        item.otherTags ?? []
    }
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if isDoneStyle {
                // 左侧竖线
                Rectangle()
                    .fill(tagColor)
                    .frame(width: 4, height: 48)
                    .cornerRadius(2)
                    .padding(.leading, 2)
            } else {
                // Todo页左侧圆圈
                Button(action: { onCircleTap?() }) {
                    Circle()
                        .stroke(Color(red: 0.8, green: 0.78, blue: 0.77), lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    // 主标签
                    Text(item.tag)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(tagColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tagColor.opacity(0.15))
                        .cornerRadius(16)
                    // Done页标题紧跟主标签
                    if isDoneStyle {
                        Text(item.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.308, green: 0.202, blue: 0.132))
                    }
                    Spacer()
                    if isDoneStyle {
                        // 右上角：开始时间
                        if let start = startTime {
                            Text(start)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
                        }
                    } else {
                        // Todo页标题
                        Text(item.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.308, green: 0.202, blue: 0.132))
                    }
                }
                // 第二行：Done页所有标签靠左，结束时间靠右
                if isDoneStyle {
                    if let duration = durationText {
                        Text(duration)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(4)
                    }
                    // 横向流式布局展示所有标签，超出自动换行
                    FlexibleTagRow(tags: otherTags)
                    Spacer()
                    if let end = endTime {
                        Text(end)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
                    }
                } else {
                    // todo页也展示otherTags（只展示一个，其他用省略号）
                    HStack(spacing: 6) {
                        if let firstTag = otherTags.first {
                            Text("#" + firstTag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background((globalCategoryColors[firstTag] ?? Color.gray).opacity(0.15))
                                .cornerRadius(4)
                            if otherTags.count > 1 {
                                Text("…(共\(otherTags.count)个)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Color.gray)
                            }
                        }
                        Spacer()
                        if let time = item.time {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
                                    .font(.system(size: 13))
                                Text(time)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
                            }
                        }
                        if let subTag = item.subTag {
                            Text("#" + subTag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background((globalCategoryColors[subTag] ?? Color.gray).opacity(0.15))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            if !isDoneStyle {
                // Todo页右侧时钟
                Image(systemName: "clock")
                    .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
            }
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 8)
        .frame(maxWidth: 320, alignment: .trailing)
    }
}

// 新增：流式标签行组件
struct FlexibleTagRow: View {
    let tags: [String]
    var body: some View {
        FlexibleView(data: tags, spacing: 6, alignment: .leading) { tag in
            Text("#" + tag)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background((globalCategoryColors[tag] ?? Color.gray).opacity(0.15))
                .cornerRadius(4)
        }
    }
}

// 通用流式布局
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var totalHeight: CGFloat = .zero
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        let items = Array(data)
        return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
            ForEach(items, id: \.self) { item in
                let view = content(item)
                view
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewHeightKey.self, value: geometry.size.height)
        }
        .onPreferenceChange(ViewHeightKey.self) { value in
            binding.wrappedValue = value
        }
    }
}

// 修复：通用高度PreferenceKey
private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
} 