//
//  ContentView.swift
//  Chrono
//
//  Created by 韩澍 on 2025/6/11.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var selectedTab: Int = 0 // 0: todo, 1: done
    @State private var navIndex: Int = 0
    @State private var showAddTodo: Bool = false
    let tabs = ["todo", "done"]
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
        .sheet(isPresented: $showAddTodo) {
            AddScheduleView(showAddTodo: $showAddTodo)
                .presentationDetents([.fraction(0.95)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScheduleStore())
}
