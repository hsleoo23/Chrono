//
//  ContentView.swift
//  Chrono
//
//  Created by 韩澍 on 2025/6/11.
//

import SwiftUI

struct Schedule: Identifiable {
    let id = UUID()
    let timeLabel: String // 如 "All Day", "08:00", "09:00"
    let items: [ScheduleItem]
}

struct ScheduleItem: Identifiable {
    let id = UUID()
    let type: String // 如 "NOTICE", "SPORT", "MEALS", "WORK"
    let title: String
    let tag: String
    let tagColor: Color
    let time: String? // 具体时间段
    let subTag: String?
    let subTagColor: Color?
}

struct HomeView: View {
    // 示例数据
    let schedules: [ScheduleItem] = [
        ScheduleItem(type: "NOTICE", title: "完成报告", tag: "NOTICE", tagColor: Color(red: 0.942, green: 0.444, blue: 0.098), time: nil, subTag: nil, subTagColor: nil),
        ScheduleItem(type: "NOTICE", title: "买车票", tag: "NOTICE", tagColor: Color(red: 0.942, green: 0.444, blue: 0.098), time: nil, subTag: nil, subTagColor: nil),
        ScheduleItem(type: "SPORT", title: "爬坡", tag: "SPORT", tagColor: Color(red: 0.957, green: 0.247, blue: 0.369), time: "08:00 - 08:40", subTag: "有氧", subTagColor: Color(red: 0.976, green: 0.96, blue: 0.785)),
        ScheduleItem(type: "MEALS", title: "吃早饭", tag: "MEALS", tagColor: Color(red: 0.949, green: 0.718, blue: 0.0), time: "08:50", subTag: nil, subTagColor: nil),
        ScheduleItem(type: "WORK", title: "打工打工", tag: "WORK", tagColor: Color(red: 0.4, green: 0.6, blue: 1.0), time: "09:00 - 12:00", subTag: "打工", subTagColor: Color(red: 0.949, green: 0.949, blue: 0.8)),
        ScheduleItem(type: "MEALS", title: "吃午饭", tag: "MEALS", tagColor: Color(red: 0.949, green: 0.718, blue: 0.0), time: "12:10", subTag: nil, subTagColor: nil)
    ]
    
    // 时间字符串转Date
    func timeStringToDate(_ str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: str)
    }
    // 获取所有有time字段的卡片的开始时间（Date）
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
    // 获取所有有日程的整点时间（去重、排序）
    var timelineHours: [Date] {
        let calendar = Calendar.current
        let hours = timedItems.map { calendar.date(bySetting: .minute, value: 0, of: $0.start)! }
        let unique = Array(Set(hours)).sorted()
        return unique
    }
    // 整点分组：每个整点下显示该整点~下一个整点之间的所有卡片
    var timelineGroups: [(hour: Date, items: [ScheduleItem])] {
        let calendar = Calendar.current
        var result: [(Date, [ScheduleItem])] = []
        for (idx, hour) in timelineHours.enumerated() {
            // 只分组到倒数第二个整点，最后一个整点只显示本身的卡片
            let nextHour = idx + 1 < timelineHours.count ? timelineHours[idx + 1] : nil
            let items: [ScheduleItem]
            if let next = nextHour {
                items = timedItems.filter { $0.start >= hour && $0.start < next }.map { $0.item }
            } else {
                items = timedItems.filter { $0.start >= hour }.map { $0.item }
            }
            result.append((hour, items))
        }
        return result
    }
    // 无时间段的卡片
    var allDayItems: [ScheduleItem] {
        schedules.filter { $0.time == nil }
    }
    // 时间格式化
    let hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // All Day 卡片
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
                                ScheduleCardView(item: item)
                            }
                        }
                        .padding(.leading, 0)
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 24)
                }
                // 整点时间轴分组
                ForEach(Array(timelineGroups.enumerated()).filter { !$0.element.1.isEmpty }, id: \.element.0) { idx, group in
                    let (hour, items) = group
                    HStack(alignment: .top, spacing: 0) {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.4, green: 0.32, blue: 0.24))
                                    .frame(width: 32, height: 32)
                                // 动态时钟icon，兼容性处理
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
                                Rectangle()
                                    .fill(Color(red: 0.85, green: 0.8, blue: 0.75))
                                    .frame(width: 4, height: CGFloat(items.count) * 72)
                                    .offset(y: 8)
                            }
                        }
                        .frame(width: 60)
                        VStack(spacing: 16) {
                            ForEach(items) { item in
                                ScheduleCardView(item: item)
                            }
                        }
                        .padding(.leading, 0)
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 24)
                }
            }
            .padding(.vertical, 24)
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.96).ignoresSafeArea())
    }
}

struct TimeSectionView: View {
    let timeLabel: String
    let isFirst: Bool
    let isLast: Bool
    let items: [ScheduleItem]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack {
                // 时间点
                ZStack {
                    Circle()
                        .fill(Color(red: 0.4, green: 0.32, blue: 0.24))
                        .frame(width: 32, height: 32)
                    Image(systemName: "clock.fill")
                        .foregroundColor(.white)
                }
                .overlay(
                    Text(timeLabel)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.32, blue: 0.24))
                        .offset(y: 40)
                        .opacity(timeLabel != "All Day" ? 1 : 0)
                )
                .padding(.top, isFirst ? 0 : -8)
                // 竖线
                if !isLast {
                    Rectangle()
                        .fill(Color(red: 0.85, green: 0.8, blue: 0.75))
                        .frame(width: 4, height: 60 * CGFloat(items.count))
                        .offset(y: -8)
                }
            }
            .frame(width: 60)
            VStack(spacing: 16) {
                ForEach(items) { item in
                    ScheduleCardView(item: item)
                }
            }
            .padding(.leading, 0)
            .padding(.trailing, 16)
        }
        .padding(.bottom, 24)
    }
}

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
                    Text(item.tag)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(item.tagColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.tagColor.opacity(0.15))
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

#Preview {
    HomeView()
}
