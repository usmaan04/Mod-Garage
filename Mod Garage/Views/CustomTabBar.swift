//
//  CustomTabBar.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 11/11/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @ObservedObject var viewModel: HomeViewModel

    private func tabTitle(_ tab: Tab) -> String {
        switch tab {
        case .home: return "Home"
        case .vehicle: return "Vehicle"
        case .fuel: return "Fuel"
        case .settings: return "Settings"
        case .add: return "Add"
        }
    }

    var body: some View {
        HStack() {
            ForEach(Array(Tab.allCases.prefix(5)), id: \.self) { tab in
                Spacer()

                // If the specified tab is the add enum
                if tab == .add {
                    Button {
                        withAnimation(.spring()) {
                            viewModel.isShowingQuickAddMenu.toggle()
                        }
                    } label: {
                        ZStack {
                            // Outer circle
                            Circle()
                                .fill(Color.container)
                                .frame(width: 62, height: 62)
                                .overlay(
                                    Circle()
                                        .trim(from: 0.56, to: 0.94)
                                        .stroke(Color.containerBorder, lineWidth: 1)
                                )

                            // Inner circle
                            Circle()
                                .fill(Color.redTheme)
                                .frame(width: 46, height: 46)
                                .shadow(radius: 4)

                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(tabTitle(tab))
                                .font(.system(size: 12))
                                .tracking(-0.2)
                                .foregroundStyle(viewModel.selectedTab == tab ? .redTheme : Color.containerText)
                                .offset(y:40)
                        }
                    }
                    .offset(y: -26)
                    .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: viewModel.isShowingQuickAddMenu)

                // Or otherwise display an icon and text
                } else {
                    Button {
                        withAnimation(.easeInOut) {
                            viewModel.isShowingQuickAddMenu = false
                            viewModel.selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: tab.rawValue)
                                .font(.system(size: 22).weight(.light))
                                .foregroundStyle(viewModel.selectedTab == tab ? .redTheme : Color.containerText)

                            Text(tabTitle(tab))
                                .font(.system(size: 12))
                                .tracking(-0.2)
                                .foregroundStyle(viewModel.selectedTab == tab ? .redTheme : Color.containerText)
                        }
                    }
                    .sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: viewModel.selectedTab)
                }

                Spacer()
            }
        }
        .padding(.horizontal,12)
        .padding(.bottom, 9)
        .frame(height: 84)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.containerBorder, lineWidth: 1)
                .shadow(radius: 12)
        )
        .background(Color.container)
    }
}

// Preview
#Preview {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = HomeViewModel()
        var body: some View {
            CustomTabBar(viewModel: viewModel)
        }
    }
    return PreviewWrapper()
}
