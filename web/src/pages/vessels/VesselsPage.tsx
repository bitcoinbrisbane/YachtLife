import {
	Box,
	Typography,
	Card,
	CardContent,
	CircularProgress,
	Alert,
	Chip,
	IconButton,
} from "@mui/material";
import {
	DirectionsBoat as BoatIcon,
	LocationOn as LocationIcon,
	Speed as SpeedIcon,
	Visibility as ViewIcon,
} from "@mui/icons-material";
import { useYachts } from "../../hooks/useYachts";

export const VesselsPage = () => {
	const { data: yachts, isLoading, error } = useYachts();

	if (isLoading) {
		return (
			<Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: 400 }}>
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return <Alert severity="error">Failed to load vessels. Please try again later.</Alert>;
	}

	return (
		<Box>
			<Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 4 }}>
				<Box>
					<Typography variant="h4" gutterBottom fontWeight={600}>
						Fleet Management
					</Typography>
					<Typography variant="body1" color="text.secondary">
						Manage your yacht syndicate fleet
					</Typography>
				</Box>
				<Chip label={`${yachts?.length || 0} Vessels`} color="primary" icon={<BoatIcon />} />
			</Box>

			<Box
				sx={{
					display: "grid",
					gridTemplateColumns: {
						xs: "1fr",
						md: "repeat(2, 1fr)",
						lg: "repeat(3, 1fr)",
					},
					gap: 3,
				}}
			>
				{yachts?.map((yacht) => (
					<Card key={yacht.id} sx={{ height: "100%" }}>
						<CardContent>
							<Box
								sx={{
									display: "flex",
									justifyContent: "space-between",
									alignItems: "start",
									mb: 2,
								}}
							>
								<Box sx={{ flex: 1 }}>
									<Typography variant="h6" fontWeight={600} gutterBottom>
										{yacht.name}
									</Typography>
									<Typography variant="body2" color="text.secondary" gutterBottom>
										{yacht.manufacturer} {yacht.model}
									</Typography>
									<Typography variant="caption" color="text.secondary">
										{yacht.year} • {yacht.length_feet}ft
									</Typography>
								</Box>
								<IconButton size="small" color="primary">
									<ViewIcon />
								</IconButton>
							</Box>

							<Box sx={{ mt: 2, display: "flex", flexDirection: "column", gap: 1.5 }}>
								<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
									<LocationIcon sx={{ fontSize: 18, color: "text.secondary" }} />
									<Typography variant="body2" color="text.secondary">
										{yacht.berth_location || yacht.home_port}
										{yacht.berth_bay_number && ` (Bay ${yacht.berth_bay_number})`}
									</Typography>
								</Box>

								<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
									<SpeedIcon sx={{ fontSize: 18, color: "text.secondary" }} />
									<Typography variant="body2" color="text.secondary">
										{yacht.engine_make} {yacht.engine_model} ({yacht.engine_count}x{" "}
										{yacht.engine_horsepower}hp)
									</Typography>
								</Box>
							</Box>

							<Box sx={{ mt: 3, pt: 2, borderTop: "1px solid", borderColor: "divider" }}>
								<Box
									sx={{
										display: "grid",
										gridTemplateColumns: "repeat(3, 1fr)",
										gap: 2,
										textAlign: "center",
									}}
								>
									<Box>
										<Typography variant="caption" color="text.secondary" display="block">
											Passengers
										</Typography>
										<Typography variant="body2" fontWeight={600}>
											{yacht.max_passengers}
										</Typography>
									</Box>
									<Box>
										<Typography variant="caption" color="text.secondary" display="block">
											Fuel (L)
										</Typography>
										<Typography variant="body2" fontWeight={600}>
											{yacht.fuel_capacity_liters}
										</Typography>
									</Box>
									<Box>
										<Typography variant="caption" color="text.secondary" display="block">
											Water (L)
										</Typography>
										<Typography variant="body2" fontWeight={600}>
											{yacht.water_capacity_liters}
										</Typography>
									</Box>
								</Box>
							</Box>
						</CardContent>
					</Card>
				))}
			</Box>

			{yachts?.length === 0 && (
				<Box sx={{ textAlign: "center", py: 8 }}>
					<BoatIcon sx={{ fontSize: 64, color: "text.disabled", mb: 2 }} />
					<Typography variant="h6" color="text.secondary">
						No vessels found
					</Typography>
					<Typography variant="body2" color="text.secondary">
						Add your first vessel to get started
					</Typography>
				</Box>
			)}
		</Box>
	);
};
