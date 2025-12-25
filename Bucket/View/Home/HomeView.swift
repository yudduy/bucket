//
//  HomeView.swift
//  Bucket
//
//  Created by Sergio Sánchez Sánchez on 9/11/24.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            feedTab()
            exploreTab()
            createGoalTab()
            activityTab()
            profileTab()
        }
        .onChange(of: viewModel.selectedTab) { newValue in
            viewModel.showCreateGoalView = (newValue == 2)
        }
        .sheet(isPresented: $viewModel.showCreateGoalView, onDismiss: {
            viewModel.selectedTab = 0
        }) {
            if let currentUser = viewModel.currentUser {
                GoalPickerSheet(user: currentUser)
            }
        }
        .tint(.black)
        .onAppear {
            viewModel.loadCurrentUser()
        }
    }
    
    // MARK: - Tab Views
    
    private func feedTab() -> some View {
        FeedView()
            .tabItem {
                Image(systemName: viewModel.selectedTab == 0 ? "house.fill" : "house")
            }
            .tag(0)
    }
    
    private func exploreTab() -> some View {
        ExploreView()
            .tabItem {
                Image(systemName: "magnifyingglass")
            }
            .tag(1)
    }
    
    private func createGoalTab() -> some View {
        Text("") // Placeholder view
            .tabItem {
                Image(systemName: "plus.circle")
            }
            .tag(2)
    }
    
    private func activityTab() -> some View {
        ActivityView()
            .tabItem {
                Image(systemName: viewModel.selectedTab == 3 ? "heart.fill" : "heart")
            }
            .tag(3)
    }
    
    private func profileTab() -> some View {
        ProfileView(user: nil)
            .tabItem {
                Image(systemName: viewModel.selectedTab == 4 ? "person.fill" : "person")
            }
            .tag(4)
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

