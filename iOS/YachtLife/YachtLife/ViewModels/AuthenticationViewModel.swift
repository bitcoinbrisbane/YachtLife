import Foundation
import SwiftUI
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedYacht: Yacht?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        if UserDefaults.standard.string(forKey: "auth_token") != nil {
            Task {
                do {
                    currentUser = try await apiService.getCurrentUser()
                    isAuthenticated = true

                    // Load selected yacht if we have one stored
                    await loadSelectedYacht()
                } catch {
                    logout()
                }
            }
        }
    }

    private func loadSelectedYacht() async {
        guard let yachtIdString = UserDefaults.standard.string(forKey: "selected_yacht_id"),
              let yachtId = UUID(uuidString: yachtIdString) else {
            print("⚠️ No selected yacht ID found")
            return
        }

        do {
            selectedYacht = try await apiService.getYacht(id: yachtId)
            print("✅ Loaded selected yacht: \(selectedYacht?.name ?? "unknown")")
        } catch {
            print("❌ Failed to load selected yacht: \(error)")
            // Clear invalid yacht ID
            UserDefaults.standard.removeObject(forKey: "selected_yacht_id")
        }
    }

    private func saveSelectedYacht(_ yacht: Yacht) {
        selectedYacht = yacht
        UserDefaults.standard.set(yacht.id.uuidString, forKey: "selected_yacht_id")
        print("✅ Saved selected yacht: \(yacht.name) (\(yacht.id))")
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(email: email, password: password)
            apiService.setAuthToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func logout() {
        apiService.clearAuthToken()
        currentUser = nil
        selectedYacht = nil
        isAuthenticated = false

        // Clear selected yacht from storage
        UserDefaults.standard.removeObject(forKey: "selected_yacht_id")
        print("✅ Logged out and cleared selected yacht")
    }

    // Mock Apple Sign In for development/testing
    // Uses the test account credentials to login via email/password
    func mockAppleSignIn(
        userIdentifier: String,
        email: String,
        fullName: PersonNameComponents?,
        selectedVessel: Yacht?
    ) async {
        // For now, use the test account to login
        // In production, this would validate the Apple ID token
        await login(email: "skipper@neptunefleet.com", password: "password123")

        // Store the selected vessel
        if isAuthenticated, let vessel = selectedVessel {
            saveSelectedYacht(vessel)
        }
    }
}
