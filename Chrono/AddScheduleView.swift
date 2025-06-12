import SwiftUI

// 颜色常量
let mainBg = Color(red: 0.96, green: 0.96, blue: 0.96)
let cardBg = Color.white
let mainBrown = Color(red: 0.45, green: 0.32, blue: 0.20)
let lightBrown = Color(red: 0.85, green: 0.8, blue: 0.75)
let tagDotColor = Color(red: 0.98, green: 0.45, blue: 0.55)

struct AddScheduleView: View {
    @Binding var showAddTodo: Bool
    @State private var selectedType: String = "日程"
    @State private var title: String = ""
    @State private var selectedCategory: String = "运动"
    @State private var showCategorySheet: Bool = false
    @State private var selectedTags: [String] = []
    @State private var showTagSheet: Bool = false
    @State private var isAllDay: Bool = false
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Calendar.current.date(byAdding: .minute, value: 60, to: Date()) ?? Date()
    @State private var note: String = ""
    // 示例类别和标签
    let categories = ["运动", "工作", "学习", "娱乐", "饮食", "其他"]
    let tags = ["健康", "能量", "补充", "有氧", "户外", "打工", "专注"]
    var body: some View {
        ZStack {
            mainBg.ignoresSafeArea()
            VStack(spacing: 20) {
                // 顶部Tab
                HStack(spacing: 12) {
                    ForEach(["日程", "待办"], id: \.self) { type in
                        Text(type)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(selectedType == type ? .white : mainBrown)
                            .frame(width: 64, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedType == type ? mainBrown : .white)
                                    .shadow(color: selectedType == type ? mainBrown.opacity(0.10) : .clear, radius: 4, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(mainBrown.opacity(selectedType == type ? 0 : 0.15), lineWidth: 1)
                            )
                            .onTapGesture { selectedType = type }
                    }
                }
                .padding(.top, 16)
                // 标题
                Card {
                    TextField("标题", text: $title)
                        .font(.system(size: 16))
                        .padding(.horizontal, 8)
                        .frame(height: 44)
                        .background(cardBg)
                        .cornerRadius(12)
                        .foregroundColor(mainBrown.opacity(0.5))
                }
                // 日历/标签
                Card {
                    VStack(spacing: 0) {
                        HStack {
                            Text("日历")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                            Spacer()
                            Circle()
                                .fill(tagDotColor)
                                .frame(width: 10, height: 10)
                            Text(selectedCategory)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                                .padding(.leading, 2)
                        }
                        .frame(height: 36)
                        Divider().padding(.vertical, 2)
                        HStack {
                            Text("标签")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                            Spacer()
                            HStack(spacing: 4) {
                                Text("#")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(mainBrown)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(lightBrown)
                            }
                        }
                        .frame(height: 36)
                    }
                }
                // 时间
                Card {
                    VStack(spacing: 0) {
                        HStack {
                            Text("全天")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                            Spacer()
                            Toggle("", isOn: $isAllDay)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: lightBrown))
                        }
                        .frame(height: 36)
                        Divider().padding(.vertical, 2)
                        HStack {
                            Text("开始")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                            Spacer()
                            Group {
                                Text(dateString(startTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(lightBrown)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(lightBrown.opacity(0.08))
                                    .cornerRadius(8)
                                Text(timeString(startTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(mainBrown)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(lightBrown.opacity(0.08))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(height: 36)
                        Divider().padding(.vertical, 2)
                        HStack {
                            Text("结束")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                            Spacer()
                            Group {
                                Text(dateString(endTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(lightBrown)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(lightBrown.opacity(0.08))
                                    .cornerRadius(8)
                                Text(timeString(endTime))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(mainBrown)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(lightBrown.opacity(0.08))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(height: 36)
                    }
                }
                // 备注
                Card {
                    TextEditor(text: $note)
                        .frame(height: 80)
                        .padding(8)
                        .background(cardBg)
                        .cornerRadius(12)
                        .foregroundColor(mainBrown.opacity(0.5))
                }
                Spacer()
                // 新建按钮
                Button(action: { /* 保存逻辑 */ }) {
                    Text("新建")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(mainBrown)
                        .cornerRadius(24)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 12)
        }
    }
    // 日期格式化
    func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        return f.string(from: date)
    }
    func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}

// 卡片封装
struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
} 