import SwiftUI

struct ScheduleCardView: View {
    let item: ScheduleItem
    var isDoneStyle: Bool = false // 新增参数，Done页传true
    
    // 计算主标签颜色
    var tagColor: Color {
        tagColors[item.tag] ?? Color.gray
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
                Button(action: { /* 选中/删除逻辑 */ }) {
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
                    HStack(spacing: 6) {
                        if let duration = durationText {
                            Text(duration)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(4)
                        }
                        ForEach(otherTags, id: \.self) { tag in
                            Text("#" + tag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background((tagColors[tag] ?? Color.gray).opacity(0.15))
                                .cornerRadius(4)
                        }
                        Spacer()
                        if let end = endTime {
                            Text(end)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
                        }
                    }
                } else if item.time != nil || (item.subTag != nil && item.subTagColor != nil) {
                    HStack {
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
                        Spacer()
                        if let subTag = item.subTag {
                            Text("#" + subTag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background((tagColors[subTag] ?? Color.gray).opacity(0.15))
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