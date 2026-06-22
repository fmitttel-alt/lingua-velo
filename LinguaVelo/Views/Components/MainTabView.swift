import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard = "Oggi"
        case lessons   = "Lezioni"
        case cycling   = "Fahrmodus"
        case progress  = "Progresso"
        case settings  = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .lessons:   return "book.fill"
            case .cycling:   return "bicycle"
            case .progress:  return "chart.bar.fill"
            case .settings:  return "gearshape.fill"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tag(Tab.dashboard)
                .tabItem { Label(Tab.dashboard.rawValue, systemImage: Tab.dashboard.icon) }

            LessonsListView()
                .tag(Tab.lessons)
                .tabItem { Label(Tab.lessons.rawValue, systemImage: Tab.lessons.icon) }

            CyclingModeEntryView()
                .tag(Tab.cycling)
                .tabItem { Label(Tab.cycling.rawValue, systemImage: Tab.cycling.icon) }

            ProgressoDashboardView()
                .tag(Tab.progress)
                .tabItem { Label(Tab.progress.rawValue, systemImage: Tab.progress.icon) }

            SettingsView()
                .tag(Tab.settings)
                .tabItem { Label(Tab.settings.rawValue, systemImage: Tab.settings.icon) }
        }
        .tint(AppTheme.Colors.salmon)
        .background(AppTheme.Colors.background)
    }
}
