import SwiftUI

class ScheduleStore: ObservableObject {
    @Published var todoItems: [ScheduleItem] = [
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
    @Published var doneItems: [ScheduleItem] = [
        ScheduleItem(type: "MEALS", title: "早饭", tag: "MEALS", time: nil, subTag: nil, subTagColor: nil, otherTags: ["健康", "能量"]),
        ScheduleItem(type: "MEALS", title: "午饭", tag: "MEALS", time: nil, subTag: nil, subTagColor: nil, otherTags: ["补充"]),
        ScheduleItem(type: "SPORT", title: "爬坡", tag: "SPORT", time: "08:00 - 08:40", subTag: "40分钟", subTagColor: Color(red: 0.976, green: 0.96, blue: 0.785), otherTags: ["有氧", "户外"]),
        ScheduleItem(type: "MEALS", title: "早饭", tag: "MEALS", time: "08:51 - 08:51", subTag: "5秒", subTagColor: nil, otherTags: []),
        ScheduleItem(type: "WORK", title: "打工打工", tag: "WORK", time: "09:00 - 12:00", subTag: "3小时", subTagColor: Color(red: 0.949, green: 0.949, blue: 0.8), otherTags: ["打工", "专注"]),
        ScheduleItem(type: "MEALS", title: "午饭", tag: "MEALS", time: "12:16 - 12:39", subTag: "23分钟", subTagColor: nil, otherTags: ["补充", "能量"])
    ]
    
    func markAsDone(_ item: ScheduleItem) {
        if let idx = todoItems.firstIndex(where: { $0.id == item.id }) {
            let done = todoItems.remove(at: idx)
            doneItems.append(done)
        }
    }
} 