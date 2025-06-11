import SwiftUI

struct DoneView: View {
    @EnvironmentObject var store: ScheduleStore
    @Binding var navIndex: Int
    @Binding var showAddTodo: Bool
    @Binding var selectedTab: Int
    let tabs: [String]
    var allDayItems: [ScheduleItem] {
        store.doneItems.filter { $0.time == nil }
    }
    func timeStringToDate(_ str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: str)
    }
    var timedItems: [(item: ScheduleItem, start: Date)] {
        store.doneItems.compactMap { item in
            guard let time = item.time else { return nil }
            let startStr = time.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespaces) ?? time
            if let date = timeStringToDate(startStr) {
                return (item, date)
            }
            return nil
        }.sorted { $0.start < $1.start }
    }
    var timelineHours: [Date] {
        let calendar = Calendar.current
        let hoursSet = Set(timedItems.map { calendar.component(.hour, from: $0.start) })
        let today = Date()
        let hourDates = hoursSet.map { hour -> Date in
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: today)!
        }
        return hourDates.sorted()
    }
    var timelineGroups: [(hour: Date, items: [ScheduleItem])] {
        let calendar = Calendar.current
        return timelineHours.map { hour in
            let hourInt = calendar.component(.hour, from: hour)
            let items = timedItems.filter {
                calendar.component(.hour, from: $0.start) == hourInt
            }.map { $0.item }
            return (hour, items)
        }
    }
    let hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 顶部标题
                Text("Today")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(Color(red: 0.4, green: 0.32, blue: 0.24))
                    .padding(.top, 24)
                    .padding(.leading, 24)
                // Tab选择器
                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { idx in
                        Button(action: { selectedTab = idx }) {
                            ZStack {
                                if selectedTab == idx {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color.white)
                                        .shadow(color: Color(red: 0.85, green: 0.8, blue: 0.75), radius: 0, x: 0, y: 0)
                                } else {
                                    Color.clear
                                }
                                Text(tabs[idx])
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(selectedTab == idx ? Color(red: 0.4, green: 0.32, blue: 0.24) : Color(red: 0.6, green: 0.48, blue: 0.4))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                        }
                        .frame(height: 48)
                    }
                }
                .background(Color(red: 0.92, green: 0.89, blue: 0.86))
                .cornerRadius(28)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 16)
                // done内容区
                if !allDayItems.isEmpty {
                    HStack(alignment: .top, spacing: 0) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.4, green: 0.32, blue: 0.24))
                                    .frame(width: 32, height: 32)
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.white)
                            }
                            Text("All Day")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.32, blue: 0.24))
                                .offset(y: 8)
                        }
                        .frame(width: 60)
                        VStack(spacing: 16) {
                            ForEach(allDayItems) { item in
                                ScheduleCardView(item: item, isDoneStyle: true, onCircleTap: nil)
                            }
                        }
                        .padding(.leading, 0)
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 40)
                }
                ForEach(Array(timelineGroups.enumerated()).filter { !$0.element.1.isEmpty }, id: \.element.0) { idx, group in
                    let (hour, items) = group
                    HStack(alignment: .top, spacing: 0) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.4, green: 0.32, blue: 0.24))
                                    .frame(width: 32, height: 32)
                                let hourStr = hourFormatter.string(from: hour)
                                let hourInt = Int(hourStr.prefix(2)) ?? 0
                                let validHour = (1...12).contains(hourInt) ? hourInt : ((hourInt - 1) % 12 + 1)
                                let symbolName = "clock.\(validHour).fill"
                                if UIImage(systemName: symbolName) != nil {
                                    Image(systemName: symbolName)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            Text(hourFormatter.string(from: hour))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.32, blue: 0.24))
                                .offset(y: 8)
                            if idx != timelineGroups.count - 1 {
                                GeometryReader { geo in
                                    Rectangle()
                                        .fill(Color(red: 0.85, green: 0.8, blue: 0.75))
                                        .frame(width: 4, height: max(geo.size.height, 44))
                                        .offset(y: 8)
                                }
                                .frame(width: 4)
                            }
                        }
                        .frame(width: 60)
                        VStack(spacing: 12) {
                            ForEach(items) { item in
                                ScheduleCardView(item: item, isDoneStyle: true, onCircleTap: nil)
                            }
                        }
                        .padding(.leading, 0)
                        .padding(.trailing, 16)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(key: GroupHeightKey.self, value: geo.size.height)
                            }
                        )
                    }
                    .padding(.top, idx == 0 ? 0 : 32)
                }
            }
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.96).ignoresSafeArea())
    }
} 