import SwiftUI

struct ScheduleCardView: View {
    let item: ScheduleItem
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 左侧圆圈（用于选中/删除）
            Button(action: { /* 选中/删除逻辑 */ }) {
                Circle()
                    .stroke(Color(red: 0.8, green: 0.78, blue: 0.77), lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // 主标签
                    let tagColor = tagColors[item.tag] ?? Color.gray
                    Text(item.tag)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(tagColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tagColor.opacity(0.15))
                        .cornerRadius(16)
                    Spacer()
                    // 标题
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 0.308, green: 0.202, blue: 0.132))
                }
                // 第二行：时间段和其他标签（有则显示）
                if item.time != nil || (item.subTag != nil && item.subTagColor != nil) {
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
                        if let subTag = item.subTag, let subTagColor = item.subTagColor {
                            Text("#" + subTag)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(red: 0.451, green: 0.418, blue: 0.4))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(subTagColor)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            // 右侧时钟
            Image(systemName: "clock")
                .foregroundColor(Color(red: 0.7, green: 0.68, blue: 0.67))
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 8)
        .frame(maxWidth: 320, alignment: .trailing)
    }
} 