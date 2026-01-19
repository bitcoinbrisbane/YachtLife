import { Box, Card, CardContent, Typography, Paper, CircularProgress } from "@mui/material";
import {
	DirectionsBoat as BoatIcon,
	People as PeopleIcon,
	CalendarMonth as CalendarIcon,
	AttachMoney as MoneyIcon,
	TrendingUp as TrendingUpIcon,
} from "@mui/icons-material";
import { useAuth } from "../../context/AuthContext";
import { useYachts } from "../../hooks/useYachts";

interface StatCardProps {
	title: string;
	value: string | number | React.ReactNode;
	icon: React.ReactNode;
	color: string;
}

const StatCard = ({ title, value, icon, color }: StatCardProps) => (
	<Card>
		<CardContent>
			<Box sx={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
				<Box>
					<Typography color="text.secondary" variant="body2" gutterBottom>
						{title}
					</Typography>
					<Typography variant="h4" fontWeight={600}>
						{value}
					</Typography>
				</Box>
				<Box
					sx={{
						width: 60,
						height: 60,
						borderRadius: 2,
						backgroundColor: `${color}15`,
						display: "flex",
						alignItems: "center",
						justifyContent: "center",
						color: color,
					}}
				>
					{icon}
				</Box>
			</Box>
		</CardContent>
	</Card>
);

export const DashboardPage = () => {
	const { user } = useAuth();
	const { data: yachts, isLoading } = useYachts();

	return (
		<Box>
			<Typography variant="h4" gutterBottom fontWeight={600}>
				Welcome back, {user?.name}!
			</Typography>
			<Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
				Here's an overview of your yacht syndicate operations
			</Typography>

			<Box
				sx={{
					display: "grid",
					gridTemplateColumns: {
						xs: "1fr",
						sm: "repeat(2, 1fr)",
						md: "repeat(4, 1fr)",
					},
					gap: 3,
				}}
			>
				<StatCard
					title="Total Vessels"
					value={isLoading ? <CircularProgress size={24} /> : yachts?.length || 0}
					icon={<BoatIcon sx={{ fontSize: 32 }} />}
					color="#0277BD"
				/>
				<StatCard
					title="Active Owners"
					value="24"
					icon={<PeopleIcon sx={{ fontSize: 32 }} />}
					color="#00ACC1"
				/>
				<StatCard
					title="Upcoming Bookings"
					value="12"
					icon={<CalendarIcon sx={{ fontSize: 32 }} />}
					color="#2E7D32"
				/>
				<StatCard
					title="Monthly Revenue"
					value="$18,500"
					icon={<MoneyIcon sx={{ fontSize: 32 }} />}
					color="#ED6C02"
				/>
			</Box>

			<Box
				sx={{
					display: "grid",
					gridTemplateColumns: {
						xs: "1fr",
						md: "2fr 1fr",
					},
					gap: 3,
					mt: 3,
				}}
			>
				<Paper sx={{ p: 3, height: "100%" }}>
					<Typography variant="h6" gutterBottom fontWeight={600}>
						Recent Activity
					</Typography>
					<Typography color="text.secondary" variant="body2">
						Activity feed will be displayed here showing recent bookings, payments, and maintenance
						updates.
					</Typography>
					<Box sx={{ mt: 3, textAlign: "center", py: 4 }}>
						<TrendingUpIcon sx={{ fontSize: 64, color: "text.disabled", mb: 2 }} />
						<Typography color="text.secondary">
							Connect to the backend to see real-time activity
						</Typography>
					</Box>
				</Paper>
				<Paper sx={{ p: 3, height: "100%" }}>
					<Typography variant="h6" gutterBottom fontWeight={600}>
						Quick Actions
					</Typography>
					<Typography color="text.secondary" variant="body2" sx={{ mb: 2 }}>
						Common tasks and shortcuts
					</Typography>
					<Box sx={{ display: "flex", flexDirection: "column", gap: 1 }}>
						<Typography variant="body2" color="text.secondary">
							• Create new booking
						</Typography>
						<Typography variant="body2" color="text.secondary">
							• Add maintenance request
						</Typography>
						<Typography variant="body2" color="text.secondary">
							• Generate financial report
						</Typography>
						<Typography variant="body2" color="text.secondary">
							• Send notification to owners
						</Typography>
					</Box>
				</Paper>
			</Box>
		</Box>
	);
};
