//
//  NotificationView.swift
//  Mod Garage
//
//  Created by Usmaan Ahmed on 17/02/2026.
//


import SwiftUI
import UIKit

struct NotificationView: View {
    @StateObject var viewModel: NotificationViewModel
    @State private var isShowingTimePicker = false

    private let chipOptions = [60, 30, 14, 7, 3, 1]

    var body: some View {
        GeometryReader{ proxy in
            VStack{
                ScrollView{
                    VStack(alignment: .leading, spacing: 16) {
                        switch viewModel.permissionState {
                        case .notDetermined:
                            HStack(spacing: 20) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.hasPermission == false ? Color.redTheme : Color.green)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "bell.slash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(Color.container)
                                }
                                
                                VStack(alignment: .leading, spacing: 8){
                                    Text("Notifications are off")
                                        .font(.system(size: 16).weight(.semibold))
                                        .foregroundStyle(Color.bw)
                                        .fontWidth(.condensed)
                                    Text("Enable notifications to receive MOT and Tax reminders")
                                        .font(.system(size: 12))
                                        .fontWidth(.condensed)
                                        .foregroundColor(.containerText)
                                        .multilineTextAlignment(.leading)

                                    Button("Enable notifications") {
                                        Task { await viewModel.requestPermission() }
                                    }
                                    .font(.system(size: 14))
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.hasPermission == true ? Color.green.opacity(0.3) : Color.lightPink)
                            )

                        case .denied:
                            HStack(spacing: 20) {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(viewModel.hasPermission == false ? Color.redTheme : Color.green)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "bell.slash.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundStyle(Color.container)
                                }
                                
                                VStack(alignment: .leading, spacing: 8){
                                    Text("Notifications are off")
                                        .font(.system(size: 16).weight(.semibold))
                                        .foregroundStyle(Color.bw)
                                        .fontWidth(.condensed)
                                    Text("Enable notifications to receive MOT and Tax reminders")
                                        .font(.system(size: 12))
                                        .fontWidth(.condensed)
                                        .foregroundColor(.containerText)
                                        .multilineTextAlignment(.leading)

                                    Button("Open iOS Settings") {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    .font(.system(size: 14))

                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.hasPermission == true ? Color.green.opacity(0.3) : Color.lightPink)
                            )
                        case .authorized:
                            HStack(spacing: 20){
                                ZStack{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.green)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "bell.and.waves.left.and.right.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(Color.container)
                                }
                                
                                Text("Notifications are Enabled")
                                    .font(.system(size: 16).weight(.semibold))
                                    .fontWidth(.condensed)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.hasPermission == true ? Color.green.opacity(0.2) : Color.lightPink)
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 16){
                            HStack(spacing: 10){
                                Image("mot")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.redTheme)
                                    .frame(width: 32, height: 32)
                                Text("MOT Reminders")
                                    .font(.system(size: 18).weight(.semibold))
                                    .fontWidth(.condensed)
                                
                                Toggle("", isOn: $viewModel.motEnabled)
                                    .onChange(of: viewModel.motEnabled) { _ in viewModel.needsSync = true }
                                
                            }
                            .frame(maxWidth: .infinity)
                            
                            if viewModel.motEnabled{
                                Text("Select how many days in advance you would like to be notified of your vehicle's MOT expiry date.")
                                    .font(.system(size: 15))
                                    .fontWidth(.condensed)
                                    .foregroundStyle(Color.containerText)
                                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                                
                                chips(selected: Set(viewModel.motLeadDays)) { day in
                                    var set = Set(viewModel.motLeadDays)

                                    if set.contains(day) {
                                        set.remove(day)
                                    } else {
                                        set.insert(day)
                                    }

                                    viewModel.updateMotLeadDays(Array(set))
                                }
                                .transition(.scale(scale: 0.95).combined(with: .opacity))
                            }
                            
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.2), value: viewModel.motEnabled)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.container)
                        )
                        
                        VStack(alignment: .leading, spacing: 16){
                            HStack(spacing: 10){
                                Image(systemName: "sterlingsign.arrow.trianglehead.counterclockwise.rotate.90")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.redTheme)
                                    .frame(width: 32, height: 32)
                                Text("Tax Reminders")
                                    .font(.system(size: 18).weight(.semibold))
                                    .fontWidth(.condensed)
                                
                                Toggle("", isOn: $viewModel.taxEnabled)
                                    .onChange(of: viewModel.taxEnabled) { _ in viewModel.needsSync = true }
                                
                            }
                            .frame(maxWidth: .infinity)
                            
                            if viewModel.taxEnabled{
                                Text("Select how many days in advance you would like to be notified of your vehicle's Tax expiry date.")
                                    .font(.system(size: 15))
                                    .fontWidth(.condensed)
                                    .foregroundStyle(Color.containerText)
                                    .transition(.scale(scale: 0.95).combined(with: .opacity))
                                  
                                
                                chips(selected: Set(viewModel.taxLeadDays)) { day in
                                    var set = Set(viewModel.taxLeadDays)

                                    if set.contains(day) {
                                        set.remove(day)
                                    } else {
                                        set.insert(day)
                                    }

                                    viewModel.updateTaxLeadDays(Array(set))
                                }
                                .transition(.scale(scale: 0.95).combined(with: .opacity))
                            }
                            
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.2), value: viewModel.taxEnabled)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.container)
                        )
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10){
                                Image(systemName: "clock")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(Color.redTheme)
                                    .frame(width: 28, height: 28)
                                Text("Notification Time")
                                    .font(.system(size: 18).weight(.semibold))
                                    .fontWidth(.condensed)

                                Spacer()

                                // Inline preview of selected time
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.2)) {
                                        isShowingTimePicker.toggle()
                                    }
                                } label: {
                                    let hour = viewModel.reminderHour
                                    let minute = viewModel.reminderMinute
                                    Text(String(format: "%02d:%02d", hour, minute))
                                        .font(.system(size: 16).weight(.semibold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(.tertiarySystemFill))
                                        )
                                }
                                .buttonStyle(.plain)
                            }

                            // Animated container for pickers
                            if isShowingTimePicker {
                                HStack {
                                    Picker("", selection: $viewModel.reminderHour) {
                                        ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                                    }
                                    .pickerStyle(.wheel)
                                    .onChange(of: viewModel.reminderHour) { _ in viewModel.needsSync = true }

                                    Picker("", selection: $viewModel.reminderMinute) {
                                        ForEach(0..<60, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                                    }
                                    .pickerStyle(.wheel)
                                    .onChange(of: viewModel.reminderMinute) { _ in viewModel.needsSync = true }
                                }
                                .transition(.scale(scale: 0.95).combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.85, blendDuration: 0.2), value: isShowingTimePicker)
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.container)
                        )
                        
                        if let msg = viewModel.statusMessage {
                            Text(msg)
                                .padding(.vertical, 4)
                                .font(.system(size: 14))
                                .fontWidth(.condensed)
                                .foregroundStyle(Color.containerText)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        } else {
                            Text("Changes apply when you sync")
                                .padding(.vertical, 4)
                                .font(.system(size: 14))
                                .fontWidth(.condensed)
                                .foregroundStyle(Color.containerText)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        HStack {
                            Button(role: .destructive) {
                                Task { await viewModel.clearAllReminders() }
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Clear")
                                }
                                .font(.system(size: 16).weight(.semibold))
                                .fontWidth(.condensed)
                                .foregroundStyle(Color.redTheme)
                                .padding(.horizontal,10)
                                .padding(.vertical,16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.redTheme, lineWidth: 1)
                                )

                            }
                            
                            Button {
                                Task { await viewModel.syncAll() }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text(viewModel.isSyncing ? "Syncing..." : "Sync")
                                }
                                .font(.system(size: 16).weight(.semibold))
                                .fontWidth(.condensed)
                                .foregroundStyle(Color.container)
                                .padding(.horizontal,10)
                                .padding(.vertical,16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.redTheme)
                                )
                            }
                            .disabled(viewModel.isSyncing || !viewModel.hasPermission)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 17)
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: proxy.size.height - 48, alignment: .top)
            .background(Color.background)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
           
            .task {
                await viewModel.onOpen()
            }
            
        }
    }

    private func chips(selected: Set<Int>, onToggle: @escaping (Int) -> Void) -> some View {
        let cols = [GridItem(.adaptive(minimum: 100), spacing: 8)]

        return LazyVGrid(columns: cols, alignment: .leading, spacing: 8) {
            ForEach(chipOptions, id: \.self) { day in
                Button {
                    onToggle(day)
                } label: {
                    Text("\(day) " + (day == 1 ? "day" : "days"))
                        .font(.system(size: 16).weight(.semibold))
                        .foregroundStyle(selected.contains(day) ? Color.white : Color.bw)
                }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selected.contains(day) ? Color.redTheme : Color.innerContainer)
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("NotificationView") {
    NavigationStack {
        NotificationView(
            viewModel: NotificationViewModel(
                vehicleProvider: { [] }
            )
        )
    }
}

