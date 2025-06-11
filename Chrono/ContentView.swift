//
//  ContentView.swift
//  Chrono
//
//  Created by 韩澍 on 2025/6/11.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0 // 0: todo, 1: done
    @State private var navIndex: Int = 0
    @State private var showAddTodo: Bool = false
    let tabs = ["todo", "done"]
    // 数据准备
    let schedules: [ScheduleItem] = [
        ScheduleItem(type: "NOTICE", title: "完成报告", tag: "NOTICE", time: nil, subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "NOTICE", title: "买车票", tag: "NOTICE", time: nil, subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "SPORT", title: "晨跑", tag: "SPORT", time: "07:00 - 07:30", subTag: "锻炼", subTagColor: Color(red: 0.9, green: 0.95, blue: 0.8), otherTags: []),
        ScheduleItem(type: "SPORT", title: "爬坡", tag: "SPORT", time: "08:00 - 08:40", subTag: "有氧", subTagColor: Color(red: 0.976, green: 0.96, blue: 0.785), otherTags: []),
        ScheduleItem(type: "MEALS", title: "吃早饭", tag: "MEALS", time: "08:50", subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "WORK", title: "打工打工", tag: "WORK", time: "09:00 - 12:00", subTag: "打工", subTagColor: Color(red: 0.949, green: 0.949, blue: 0.8), otherTags: []),
        ScheduleItem(type: "WORK", title: "开会", tag: "WORK", time: "10:00 - 11:00", subTag: "项目", subTagColor: Color(red: 0.8, green: 0.9, blue: 1.0), otherTags: []),
        ScheduleItem(type: "MEALS", title: "吃午饭", tag: "MEALS", time: "12:10", subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "MEALS", title: "下午水果", tag: "MEALS", time: "14:59", subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "MEALS", title: "下午茶", tag: "MEALS", time: "15:00", subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "NOTICE", title: "提交代码", tag: "NOTICE", time: "16:00", subTag: "开发", subTagColor: Color(red: 1.0, green: 0.95, blue: 0.8), otherTags: []),
        ScheduleItem(type: "SPORT", title: "健身房", tag: "SPORT", time: "18:00 - 19:00", subTag: "力量", subTagColor: Color(red: 0.95, green: 0.8, blue: 0.9), otherTags: []),
        ScheduleItem(type: "MEALS", title: "晚饭", tag: "MEALS", time: "19:30", subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "WORK", title: "复盘总结", tag: "WORK", time: "21:00", subTag: "复盘", subTagColor: Color(red: 0.8, green: 0.9, blue: 1.0), otherTags: []),
        ScheduleItem(type: "NOTICE", title: "阅读", tag: "NOTICE", time: "22:00", subTag: nil, subTagColor: nil, otherTags: []),
        ScheduleItem(type: "NOTICE", title: "夜间备忘", tag: "NOTICE", time: "03:46", subTag: "提醒", subTagColor: Color(red: 1.0, green: 0.95, blue: 0.8), otherTags: [])
    ]
    var allDayItems: [ScheduleItem] {
        schedules.filter { $0.time == nil }
    }
    // timelineHours、timelineGroups、hourFormatter
    func timeStringToDate(_ str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: str)
    }
    var timedItems: [(item: ScheduleItem, start: Date)] {
        schedules.compactMap { item in
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
        ZStack(alignment: .bottom) {
            Group {
                if navIndex == 0 {
                    if selectedTab == 0 {
                        HomeView(navIndex: $navIndex, showAddTodo: $showAddTodo, selectedTab: $selectedTab, tabs: tabs)
                    } else {
                        DoneView(navIndex: $navIndex, showAddTodo: $showAddTodo, selectedTab: $selectedTab, tabs: tabs)
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("空白页面")
                            .foregroundColor(.gray)
                            .font(.system(size: 20, weight: .medium))
                        Spacer()
                    }
                }
            }
            CustomTabBar(navIndex: $navIndex, showAddTodo: $showAddTodo)
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.96).ignoresSafeArea())
        .fullScreenCover(isPresented: $showAddTodo) {
            VStack {
                Spacer()
                Text("新建TODO页面（空白）")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button("关闭") { showAddTodo = false }
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScheduleStore())
}
