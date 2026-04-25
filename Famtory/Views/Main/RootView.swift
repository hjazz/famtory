import SwiftUI

struct RootView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var familyVM = FamilyViewModel()

    var body: some View {
        Group {
            if authVM.isLoading {
                SplashView()
            } else if authVM.currentUser == nil {
                SignInView()
            } else if let familyId = authVM.currentUser?.familyId {
                MainTabView(familyVM: familyVM)
                    .task { await familyVM.loadFamily(id: familyId) }
            } else {
                FamilySetupView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authVM.currentUser?.familyId)
        .onChange(of: authVM.currentUser?.familyId) { _, familyId in
            guard let familyId else { return }
            Task { await familyVM.loadFamily(id: familyId) }
        }
    }
}

// MARK: - Splash

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.famBackground.ignoresSafeArea()
            Image("FamtoryLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .blendMode(.multiply)
        }
    }
}

// MARK: - Tab

struct MainTabView: View {
    @ObservedObject var familyVM: FamilyViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            HomeView(familyVM: familyVM)
                .tabItem { Label("오늘", systemImage: "house.fill") }

            CalendarView(familyVM: familyVM)
                .tabItem { Label("달력", systemImage: "calendar") }

            FamilyInfoView(familyVM: familyVM)
                .tabItem { Label("가족", systemImage: "person.2.fill") }
        }
        .tint(.famPrimary)
    }
}
