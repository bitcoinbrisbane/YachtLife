import { ThemeProvider } from "@mui/material/styles";
import CssBaseline from "@mui/material/CssBaseline";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import theme from "./theme/theme";
import { Box, Typography, Button, Card, CardContent } from "@mui/material";
import DirectionsBoatIcon from "@mui/icons-material/DirectionsBoat";

// Create a client for React Query
const queryClient = new QueryClient({
	defaultOptions: {
		queries: {
			staleTime: 1000 * 60 * 5, // 5 minutes
			refetchOnWindowFocus: false,
		},
	},
});

function App() {
	return (
		<QueryClientProvider client={queryClient}>
			<ThemeProvider theme={theme}>
				<CssBaseline />
				<Box
					sx={{
						minHeight: "100vh",
						background: "linear-gradient(135deg, #0277BD 0%, #00ACC1 100%)",
						display: "flex",
						alignItems: "center",
						justifyContent: "center",
						p: 2,
					}}
				>
					<Card sx={{ maxWidth: 600, width: "100%", textAlign: "center" }}>
						<CardContent sx={{ p: 6 }}>
							<DirectionsBoatIcon sx={{ fontSize: 80, color: "primary.main", mb: 2 }} />
							<Typography variant="h2" gutterBottom>
								YachtLife
							</Typography>
							<Typography variant="h5" color="text.secondary" gutterBottom>
								Yacht Syndicate Management
							</Typography>
							<Typography variant="body1" color="text.secondary" sx={{ mt: 3, mb: 4 }}>
								A comprehensive platform for managing yacht ownership, bookings,
								maintenance, and financial operations.
							</Typography>
							<Box sx={{ display: "flex", gap: 2, justifyContent: "center" }}>
								<Button variant="contained" size="large">
									Get Started
								</Button>
								<Button variant="outlined" size="large">
									Learn More
								</Button>
							</Box>
							<Typography variant="caption" color="text.secondary" sx={{ mt: 4, display: "block" }}>
								Management Dashboard • Coming Soon
							</Typography>
						</CardContent>
					</Card>
				</Box>
				<ReactQueryDevtools initialIsOpen={false} />
			</ThemeProvider>
		</QueryClientProvider>
	);
}

export default App;
