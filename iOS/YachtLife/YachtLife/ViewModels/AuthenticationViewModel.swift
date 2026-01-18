import Foundation
import SwiftUI
import Combine

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
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
                } catch {
                    logout()
                }
            }
        }
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
        isAuthenticated = false
    }
}
