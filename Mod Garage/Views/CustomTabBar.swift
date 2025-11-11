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
            ForEach(Tab.allCases) { tab in
                Spacer()

                if tab == .add {
                    Button {
                        withAnimation(.spring()) {
                            viewModel.selectedTab = .add
                        }
                    } label: {
                        ZStack {
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
                                .foregroundColor(viewModel.selectedTab == tab ? .redTheme : Color.navText)
                                .offset(y:40)
                        }
                    }
                    .offset(y: -26) // slightly lifted look

                } else {
                    Button {
                        withAnimation(.easeInOut) {
                            viewModel.selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: tab.rawValue)
                                .font(.system(size: 22).weight(.light))
                                .foregroundColor(viewModel.selectedTab == tab ? .redTheme : Color.navText)

                            Text(tabTitle(tab))
                                .font(.system(size: 12))
                                .tracking(-0.2)
                                .foregroundColor(viewModel.selectedTab == tab ? .redTheme : Color.navText)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(.horizontal,12)
        .padding(.bottom, 9)
        .frame(height: 84)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.rectBorder, lineWidth: 1)
        )
    }
}
