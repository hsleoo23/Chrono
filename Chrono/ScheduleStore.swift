import SwiftUI

class ScheduleStore: ObservableObject {
    @Published var todoItems: [ScheduleItem] = [] {
        didSet { saveTodos() }
    }
    @Published var doneItems: [ScheduleItem] = [] {
        didSet { saveDoneItems() }
    }
    
    init() {
        loadTodos()
        loadDoneItems()
    }
    
    private let todoKey = "todoItemsKey"
    private let doneKey = "doneItemsKey"
    
    func saveTodos() {
        if let data = try? JSONEncoder().encode(todoItems) {
            UserDefaults.standard.set(data, forKey: todoKey)
            print("已保存todo数量：", todoItems.count)
        }
    }
    func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: todoKey),
           let items = try? JSONDecoder().decode([ScheduleItem].self, from: data) {
            todoItems = items
        } else {
            // 首次启动为空
            todoItems = []
        }
    }
    
    func saveDoneItems() {
        if let data = try? JSONEncoder().encode(doneItems) {
            UserDefaults.standard.set(data, forKey: doneKey)
            print("已保存done数量：", doneItems.count)
        }
    }
    func loadDoneItems() {
        if let data = UserDefaults.standard.data(forKey: doneKey),
           let items = try? JSONDecoder().decode([ScheduleItem].self, from: data) {
            doneItems = items
        } else {
            doneItems = []
        }
    }
    
    func markAsDone(_ item: ScheduleItem) {
        if let idx = todoItems.firstIndex(where: { $0.id == item.id }) {
            let done = todoItems.remove(at: idx)
            doneItems.append(done)
            saveDoneItems()
        }
    }
} 