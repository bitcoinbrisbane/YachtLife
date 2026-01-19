import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import theme from "./theme/theme";
import { AuthProvider, useAuth } from "./context/AuthContext";
import { LoginPage } from "./pages/auth/LoginPage";
import { DashboardPage } from "./pages/dashboard/DashboardPage";
import { DashboardLayout } from "./layouts/DashboardLayout";
import { Box, CircularProgress } from "@mui/material";

// Create a client for React Query
const queryClient = new QueryClient({
	defaultOptions: {
		queries: {
			staleTime: 1000 * 60 * 5, // 5 minutes
			refetchOnWindowFocus: false,
		},
	},
});

// Protected Route wrapper
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
	const { isAuthenticated, loading } = useAuth();

	if (loading) {
		return (
			<Box
				sx={{
					display: "flex",
					justifyContent: "center",
					alignItems: "center",
					minHeight: "100vh",
				}}
			>
				<CircularProgress />
			</Box>
		);
	}

	if (!isAuthenticated) {
		return <Navigate to="/login" replace />;
	}

	return <>{children}</>;
};

// Public Route wrapper (redirect to dashboard if already logged in)
const PublicRoute = ({ children }: { children: React.ReactNode }) => {
	const { isAuthenticated, loading } = useAuth();

	if (loading) {
		return (
			<Box
				sx={{
					display: "flex",
					justifyContent: "center",
					alignItems: "center",
					minHeight: "100vh",
				}}
			>
				<CircularProgress />
			</Box>
		);
	}

	if (isAuthenticated) {
		return <Navigate to="/dashboard" replace />;
	}

	return <>{children}</>;
};

function App() {
	return (
		<QueryClientProvider client={queryClient}>
			<ThemeProvider theme={theme}>
				<CssBaseline />
				<BrowserRouter>
					<AuthProvider>
						<Routes>
							{/* Public routes */}
							<Route
								path="/login"
								element={
									<PublicRoute>
										<LoginPage />
									</PublicRoute>
								}
							/>

							{/* Protected routes */}
							<Route
								path="/dashboard"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<DashboardPage />
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>

							{/* Placeholder routes for other pages */}
							<Route
								path="/vessels"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Vessels Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/owners"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Owners Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/bookings"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Bookings Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/financial"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Financial Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/maintenance"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Maintenance Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/voting"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Voting Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/reports"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Reports Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/notifications"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Notifications Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>
							<Route
								path="/settings"
								element={
									<ProtectedRoute>
										<DashboardLayout>
											<Box>Settings Page - Coming Soon</Box>
										</DashboardLayout>
									</ProtectedRoute>
								}
							/>

							{/* Default redirect */}
							<Route path="/" element={<Navigate to="/dashboard" replace />} />

							{/* 404 redirect */}
							<Route path="*" element={<Navigate to="/dashboard" replace />} />
						</Routes>
					</AuthProvider>
				</BrowserRouter>
				<ReactQueryDevtools initialIsOpen={false} />
			</ThemeProvider>
		</QueryClientProvider>
	);
}

export default App;
