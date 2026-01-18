import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            BookingsView()
                .tabItem {
                    Label("Bookings", systemImage: "calendar")
                }

            InvoicesView()
                .tabItem {
                    Label("Invoices", systemImage: "doc.text.fill")
                }

            MaintenanceView()
                .tabItem {
                    Label("Maintenance", systemImage: "wrench.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
}
