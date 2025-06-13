import SwiftUI

// 颜色常量
let mainBg = Color(red: 0.96, green: 0.96, blue: 0.96)
let cardBg = Color.white
let mainBrown = Color(red: 0.45, green: 0.32, blue: 0.20)
let lightBrown = Color(red: 0.85, green: 0.8, blue: 0.75)
let tagDotColor = Color(red: 0.98, green: 0.45, blue: 0.55)

// 标签分组数据结构
struct TagGroup {
    let name: String
    let color: Color
    let tags: [String]
}

// 标签分组示例，和截图一致
let tagGroups: [TagGroup] = [
    TagGroup(name: "日历标签", color: Color.pink, tags: ["有氧", "健身", "户外"]),
    TagGroup(name: "时间利用", color: Color.purple, tags: ["必需日常", "自我投资", "及时享受"]),
    TagGroup(name: "时间性质", color: Color.blue, tags: ["重要紧急", "重要不紧急", "不重要紧急", "不重要不紧急"])
]

// 只保留tagColors中的8个日历类别为默认
let defaultCategories: [String: Color] = [
    "健康": Color.green,
    "能量": Color.yellow,
    "补充": Color.purple,
    "有氧": Color.cyan,
    "户外": Color.brown,
    "打工": Color.blue,
    "专注": Color.indigo,
    "运动": Color.pink
]

// UserDefaults持久化相关
let categoryColorsKey = "categoryColorsKey"

func saveCategoryColors(_ dict: [String: Color]) {
    let codableDict = dict.mapValues { ColorCodable(color: $0) }
    if let data = try? JSONEncoder().encode(codableDict) {
        UserDefaults.standard.set(data, forKey: categoryColorsKey)
    }
}

func loadCategoryColors() -> [String: Color] {
    if let data = UserDefaults.standard.data(forKey: categoryColorsKey),
       let codableDict = try? JSONDecoder().decode([String: ColorCodable].self, from: data) {
        return codableDict.mapValues { $0.color }
    }
    return defaultCategories // 默认初始
}

var globalCategoryColors: [String: Color] = loadCategoryColors()

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
    @State private var showStartPicker: Bool = false
    @State private var showEndPicker: Bool = false
    // 类别颜色直接用全局映射
    @State private var categoryColors: [String: Color] = globalCategoryColors
    @EnvironmentObject var store: ScheduleStore
    // 只保留tagColors中的8个日历类别
    let availableCategories = ["健康", "能量", "补充", "有氧", "户外", "打工", "专注", "运动"]
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
                                .fill(categoryColors[selectedCategory] ?? tagDotColor)
                                .frame(width: 10, height: 10)
                            Text(selectedCategory)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(mainBrown)
                                .padding(.leading, 2)
                        }
                        .frame(height: 36)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                            showCategorySheet = true
                        }
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            hideKeyboard()
                            showTagSheet = true
                        }
                        if !selectedTags.isEmpty {
                            TagChipsGrid(tags: selectedTags, selectedTags: selectedTags, onTap: { tag in
                                if let idx = selectedTags.firstIndex(of: tag) {
                                    selectedTags.remove(at: idx)
                                }
                            })
                            .padding(.top, 8)
                        }
                    }
                }
                .sheet(isPresented: $showCategorySheet) {
                    CategoryPickerSheet(
                        categories: Array(categoryColors.keys),
                        selected: selectedCategory,
                        categoryColors: $categoryColors,
                        onSelect: { cat in
                            selectedCategory = cat
                            showCategorySheet = false
                        },
                        onAddCategory: { name, color in
                            // 新增类别时，所有地方同步更新
                            categoryColors[name] = color
                            globalCategoryColors[name] = color
                            saveCategoryColors(globalCategoryColors)
                        }
                    )
                    .presentationDetents([.fraction(0.45)])
                    .presentationDragIndicator(.visible)
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
                        if !isAllDay {
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
                            .contentShape(Rectangle())
                            .onTapGesture { showStartPicker = true }
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
                            .contentShape(Rectangle())
                            .onTapGesture { showEndPicker = true }
                        }
                    }
                }
                .sheet(isPresented: $showStartPicker) {
                    VStack {
                        DatePicker("选择开始时间", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                        Button("完成") { showStartPicker = false }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showEndPicker) {
                    VStack {
                        DatePicker("选择结束时间", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                        Button("完成") { showEndPicker = false }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
                }
                // 备注
                Card {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $note)
                            .frame(height: 80)
                            .foregroundColor(mainBrown.opacity(0.5))
                            .background(Color.clear)
                        if note.isEmpty {
                            Text("备注")
                                .foregroundColor(mainBrown.opacity(0.3))
                                .padding(.top, 12)
                                .padding(.leading, 6)
                        }
                    }
                }
                Spacer()
                // 新建按钮
                Button(action: {
                    print("新建前数量：", store.todoItems.count)
                    let timeStr: String? = isAllDay ? nil : "\(timeString(startTime)) - \(timeString(endTime))"
                    let newItem = ScheduleItem(
                        type: selectedType,
                        title: title,
                        tag: selectedCategory,
                        time: timeStr,
                        subTag: nil,
                        subTagColor: nil,
                        otherTags: selectedTags,
                        note: note.isEmpty ? nil : note
                    )
                    store.todoItems.insert(newItem, at: 0)
                    print("新建后数量：", store.todoItems.count)
                    showAddTodo = false
                }) {
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
        .sheet(isPresented: $showTagSheet) {
            TagPickerSheet(
                selectedTags: $selectedTags,
                tagGroups: tagGroups
            )
            .presentationDetents([.fraction(0.8)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            categoryColors = globalCategoryColors
        }
        .onChange(of: startTime) {
            // 只要startTime变化，endTime自动变为startTime后60分钟
            endTime = Calendar.current.date(byAdding: .minute, value: 60, to: startTime) ?? startTime
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

// 辅助函数：收起键盘
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// 新增类别选择弹窗组件
struct CategoryPickerSheet: View {
    @State private var showAddCategory: Bool = false
    @State private var newCategory: String = ""
    @State private var newColor: Color? = nil
    @State private var showAlert: Bool = false
    @State private var alertMsg: String = ""
    @State private var categoriesState: [String]
    @Binding var categoryColors: [String: Color]
    let selected: String
    let onSelect: (String) -> Void
    var onAddCategory: ((String, Color) -> Void)? = nil
    init(categories: [String], selected: String, categoryColors: Binding<[String: Color]>, onSelect: @escaping (String) -> Void, onAddCategory: ((String, Color) -> Void)? = nil) {
        self.selected = selected
        self.onSelect = onSelect
        self.onAddCategory = onAddCategory
        _categoriesState = State(initialValue: categories)
        _categoryColors = categoryColors
    }
    // 32种主流色
    let colorPalette: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown,
        Color(red:1,green:0.5,blue:0.5), Color(red:1,green:0.7,blue:0.2), Color(red:0.9,green:0.9,blue:0.2), Color(red:0.5,green:1,blue:0.5),
        Color(red:0.2,green:0.8,blue:0.7), Color(red:0.2,green:0.7,blue:1), Color(red:0.4,green:0.4,blue:1), Color(red:0.7,green:0.4,blue:1),
        Color(red:1,green:0.4,blue:1), Color(red:1,green:0.4,blue:0.7), Color(red:0.7,green:0.7,blue:0.7), Color(red:0.5,green:0.5,blue:0.5),
        Color(red:0.8,green:0.6,blue:0.4), Color(red:0.6,green:0.8,blue:0.4), Color(red:0.4,green:0.8,blue:0.6), Color(red:0.4,green:0.6,blue:0.8),
        Color(red:0.6,green:0.4,blue:0.8), Color(red:0.8,green:0.4,blue:0.6), Color(red:0.9,green:0.7,blue:0.5), Color(red:0.7,green:0.9,blue:0.5)
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("选择日历")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(mainBrown)
                Spacer()
                Button(action: {
                    hideKeyboard()
                    showAddCategory = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(mainBrown.opacity(0.5))
                        .padding(.trailing, 8)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 8)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(categoriesState, id: \.self) { cat in
                        Button(action: { onSelect(cat) }) {
                            HStack {
                                Circle()
                                    .fill(categoryColors[cat] ?? Color.gray)
                                    .frame(width: 16, height: 16)
                                Text(cat)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(mainBrown)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                    }
                }
            }
            Spacer()
        }
        .background(mainBg)
        .sheet(isPresented: $showAddCategory) {
            VStack(spacing: 20) {
                Text("新建日历类别")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 24)
                TextField("请输入类别名称", text: $newCategory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 24)
                    .onTapGesture { }
                HStack {
                    Text("选择颜色：")
                        .font(.system(size: 16))
                    // 32色块选择器
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(28), spacing: 8), count: 8), spacing: 8) {
                        ForEach(colorPalette, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(newColor == color ? 0.5 : 0), lineWidth: 2)
                                )
                                .onTapGesture {
                                    hideKeyboard()
                                    newColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal, 24)
                Button(action: {
                    hideKeyboard()
                    let name = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else {
                        alertMsg = "类别名不能为空"
                        showAlert = true
                        return
                    }
                    guard let color = newColor else {
                        alertMsg = "请选择颜色"
                        showAlert = true
                        return
                    }
                    guard !categoriesState.contains(name) else {
                        alertMsg = "该类别已存在"
                        showAlert = true
                        return
                    }
                    categoriesState.append(name)
                    categoryColors[name] = color
                    onSelect(name)
                    showAddCategory = false
                    newCategory = ""
                    newColor = nil
                    onAddCategory?(name, color)
                }) {
                    Text("添加")
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mainBrown)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                Button("取消") {
                    showAddCategory = false
                    newCategory = ""
                    newColor = nil
                }
                .foregroundColor(.gray)
                .padding(.bottom, 24)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMsg), dismissButton: .default(Text("确定")))
            }
            .presentationDetents([.fraction(0.38)])
            .presentationDragIndicator(.visible)
        }
    }
}

// 标签Chip自动换行Grid
struct TagChipsGrid: View {
    let tags: [String]
    let selectedTags: [String]
    let onTap: (String) -> Void
    var body: some View {
        FlowLayout(tags: tags) { tag in
            TagChip(
                text: tag,
                color: selectedTags.contains(tag) ? (tagColors[tag] ?? Color.orange) : Color.gray.opacity(0.25),
                selected: selectedTags.contains(tag),
                onTap: { onTap(tag) }
            )
        }
    }
}

// 通用流式布局组件，保证每个标签整体在一行，自动换行
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let tags: Data
    let content: (Data.Element) -> Content
    @State private var totalHeight: CGFloat = .zero
    
    init(tags: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.tags = tags
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(Array(tags), id: \ .self) { tag in
                content(tag)
                    .padding(.trailing, 8)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > geometry.size.width {
                            width = 0
                            height -= d.height + 8
                        }
                        let result = width
                        if tag == tags.last {
                            width = 0 // 最后一个重置
                        } else {
                            width -= d.width + 8
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if tag == tags.last {
                            height = 0 // 最后一个重置
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

private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// 标签选择弹窗组件
struct TagPickerSheet: View {
    @Binding var selectedTags: [String]
    let tagGroups: [TagGroup]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 标题
                Text("标签")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(mainBrown)
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                // 已选标签
                if !selectedTags.isEmpty {
                    Card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("已选标签")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(mainBrown)
                            TagChipsGrid(tags: selectedTags, selectedTags: selectedTags, onTap: { tag in
                                if let idx = selectedTags.firstIndex(of: tag) {
                                    selectedTags.remove(at: idx)
                                }
                            })
                        }
                    }
                }
                // 标签分组
                ForEach(tagGroups, id: \.name) { group in
                    Card {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if group.name == "日历标签" {
                                    Circle().fill(Color.pink).frame(width: 14, height: 14)
                                    Text("运动")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(mainBrown)
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundColor(lightBrown)
                                } else {
                                    Text(group.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(mainBrown)
                                    Spacer()
                                    Image(systemName: "plus")
                                        .foregroundColor(lightBrown)
                                }
                            }
                            TagChipsGrid(tags: group.tags, selectedTags: selectedTags, onTap: toggleTag)
                        }
                    }
                }
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 8)
        }
        .background(mainBg)
    }
    func toggleTag(_ tag: String) {
        if let idx = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: idx)
        } else {
            selectedTags.append(tag)
        }
    }
}

// 标签Chip组件
struct TagChip: View {
    let text: String
    let color: Color
    let selected: Bool
    let onTap: () -> Void
    var body: some View {
        Text("#" + text)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(selected ? color : Color.gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(selected ? color.opacity(0.15) : Color.gray.opacity(0.10))
            .cornerRadius(10)
            .onTapGesture { onTap() }
    }
} 