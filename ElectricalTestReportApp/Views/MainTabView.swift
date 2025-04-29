//
//  MainTabView.swift
//  ElectricalTestReportApp
//
//  Created by Jeff Chadkirk on 29/4/2025.
//


// Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = FormViewModel()
    var body: some View {
        VStack(spacing: 0) {
            Image("PlatinumLogoWide")
                .resizable()
                .scaledToFit()
                .frame(height: 78)
                .padding(.top, 8)
            Text("Electrical Test Report")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 16)
            TabView {
                NavigationView { FormView(viewModel: viewModel) }
                    .tabItem {
                        Label("Form", systemImage: "doc.text")
                    }
                NavigationView { TestResultsPreviewView(testResults: $viewModel.testResults) }
                    .tabItem {
                        Label("Preview Results", systemImage: "table")
                    }
                NavigationView { HistoryView() }
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
                NavigationView { SettingsView() }
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}