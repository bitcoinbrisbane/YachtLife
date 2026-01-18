import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let user = authViewModel.currentUser {
                        LabeledContent("Name", value: user.fullName)
                        LabeledContent("Email", value: user.email)
                        LabeledContent("Role", value: user.role.rawValue.capitalized)
                    }
                }

                Section("App") {
                    Link("Privacy Policy", destination: URL(string: "https://yachtlife.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://yachtlife.com/terms")!)
                    LabeledContent("Version", value: "1.0.0")
                }

                Section {
                    Button("Logout", role: .destructive) {
                        authViewModel.logout()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthenticationViewModel())
}
