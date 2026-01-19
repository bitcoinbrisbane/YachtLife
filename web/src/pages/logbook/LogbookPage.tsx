import { useState } from "react";
import {
	Box,
	Typography,
	Card,
	CardContent,
	CircularProgress,
	Alert,
	Chip,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
	Button,
	Dialog,
	DialogTitle,
	DialogContent,
	DialogActions,
	TextField,
	MenuItem,
	Snackbar,
} from "@mui/material";
import {
	Description as LogIcon,
	DirectionsBoat as BoatIcon,
	LocalGasStation as FuelIcon,
	Build as MaintenanceIcon,
	Warning as IncidentIcon,
	SailingOutlined as DepartureIcon,
	Anchor as ReturnIcon,
	Add as AddIcon,
} from "@mui/icons-material";
import { useLogbookEntries, useCreateLogbookEntry } from "../../hooks/useLogbook";
import { useYachts } from "../../hooks/useYachts";
import type { LogbookEntryType } from "../../types/logbook";

const getEntryTypeIcon = (type: LogbookEntryType) => {
	switch (type) {
		case "departure":
			return <DepartureIcon sx={{ fontSize: 18 }} />;
		case "return":
			return <ReturnIcon sx={{ fontSize: 18 }} />;
		case "fuel":
			return <FuelIcon sx={{ fontSize: 18 }} />;
		case "maintenance":
			return <MaintenanceIcon sx={{ fontSize: 18 }} />;
		case "incident":
			return <IncidentIcon sx={{ fontSize: 18 }} />;
		default:
			return <LogIcon sx={{ fontSize: 18 }} />;
	}
};

const getEntryTypeColor = (type: LogbookEntryType) => {
	switch (type) {
		case "departure":
			return "#2E7D32";
		case "return":
			return "#0277BD";
		case "fuel":
			return "#ED6C02";
		case "maintenance":
			return "#9C27B0";
		case "incident":
			return "#D32F2F";
		default:
			return "#757575";
	}
};

const getEntryTypeLabel = (type: LogbookEntryType) => {
	switch (type) {
		case "departure":
			return "Departure";
		case "return":
			return "Return";
		case "fuel":
			return "Fuel";
		case "maintenance":
			return "Maintenance";
		case "incident":
			return "Incident";
		default:
			return "General";
	}
};

export const LogbookPage = () => {
	const { data: entries, isLoading, error } = useLogbookEntries();
	const { data: yachts } = useYachts();
	const createLogbook = useCreateLogbookEntry();

	const [dialogOpen, setDialogOpen] = useState(false);
	const [snackbarOpen, setSnackbarOpen] = useState(false);
	const [snackbarMessage, setSnackbarMessage] = useState("");

	const [formData, setFormData] = useState({
		yacht_id: "",
		entry_type: "",
		fuel_liters: "",
		fuel_cost: "",
		hours_operated: "",
		notes: "",
	});

	const handleOpenDialog = () => {
		setDialogOpen(true);
	};

	const handleCloseDialog = () => {
		setDialogOpen(false);
		setFormData({
			yacht_id: "",
			entry_type: "",
			fuel_liters: "",
			fuel_cost: "",
			hours_operated: "",
			notes: "",
		});
	};

	const handleSubmit = async () => {
		if (!formData.yacht_id) {
			setSnackbarMessage("Please select a vessel");
			setSnackbarOpen(true);
			return;
		}

		try {
			await createLogbook.mutateAsync({
				yacht_id: formData.yacht_id,
				entry_type: formData.entry_type || undefined,
				fuel_liters: formData.fuel_liters ? parseFloat(formData.fuel_liters) : undefined,
				fuel_cost: formData.fuel_cost ? parseFloat(formData.fuel_cost) : undefined,
				hours_operated: formData.hours_operated ? parseFloat(formData.hours_operated) : undefined,
				notes: formData.notes || undefined,
			});

			setSnackbarMessage("Log entry created successfully");
			setSnackbarOpen(true);
			handleCloseDialog();
		} catch {
			setSnackbarMessage("Failed to create log entry");
			setSnackbarOpen(true);
		}
	};

	if (isLoading) {
		return (
			<Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: 400 }}>
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return <Alert severity="error">Failed to load logbook entries. Please try again later.</Alert>;
	}

	return (
		<Box>
			<Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 4 }}>
				<Box>
					<Typography variant="h4" gutterBottom fontWeight={600}>
						Logbook
					</Typography>
					<Typography variant="body1" color="text.secondary">
						All vessel activity logs and maintenance records
					</Typography>
				</Box>
				<Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenDialog}>
					New Log Entry
				</Button>
			</Box>

			{entries && entries.length > 0 ? (
				<TableContainer component={Paper}>
					<Table>
						<TableHead>
							<TableRow>
								<TableCell>Type</TableCell>
								<TableCell>Vessel</TableCell>
								<TableCell>Logged By</TableCell>
								<TableCell>Details</TableCell>
								<TableCell>Date</TableCell>
							</TableRow>
						</TableHead>
						<TableBody>
							{entries.map((entry) => (
								<TableRow key={entry.id} hover>
									<TableCell>
										<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
											<Box
												sx={{
													display: "flex",
													alignItems: "center",
													justifyContent: "center",
													width: 36,
													height: 36,
													borderRadius: 1,
													bgcolor: `${getEntryTypeColor(entry.entry_type)}15`,
													color: getEntryTypeColor(entry.entry_type),
												}}
											>
												{getEntryTypeIcon(entry.entry_type)}
											</Box>
											<Typography variant="body2" fontWeight={600}>
												{getEntryTypeLabel(entry.entry_type)}
											</Typography>
										</Box>
									</TableCell>
									<TableCell>
										<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
											<BoatIcon sx={{ fontSize: 16, color: "text.secondary" }} />
											<Typography variant="body2">{entry.yacht?.name || "Unknown"}</Typography>
										</Box>
									</TableCell>
									<TableCell>
										<Typography variant="body2">
											{entry.user?.first_name} {entry.user?.last_name}
										</Typography>
										{entry.booking && (
											<Typography variant="caption" color="text.secondary" display="block">
												Booking {new Date(entry.booking.start_date).toLocaleDateString()} -{" "}
												{new Date(entry.booking.end_date).toLocaleDateString()}
											</Typography>
										)}
									</TableCell>
									<TableCell>
										{entry.notes && (
											<Typography variant="body2" sx={{ mb: 0.5 }}>
												{entry.notes}
											</Typography>
										)}
										<Box sx={{ display: "flex", gap: 1, flexWrap: "wrap" }}>
											{entry.fuel_liters && (
												<Chip
													label={`${entry.fuel_liters}L fuel`}
													size="small"
													variant="outlined"
												/>
											)}
											{entry.fuel_cost && (
												<Chip label={`$${entry.fuel_cost}`} size="small" variant="outlined" />
											)}
											{entry.hours_operated && (
												<Chip label={`${entry.hours_operated}h`} size="small" variant="outlined" />
											)}
										</Box>
									</TableCell>
									<TableCell>
										<Typography variant="body2" color="text.secondary">
											{new Date(entry.created_at).toLocaleString()}
										</Typography>
									</TableCell>
								</TableRow>
							))}
						</TableBody>
					</Table>
				</TableContainer>
			) : (
				<Card>
					<CardContent>
						<Box sx={{ textAlign: "center", py: 8 }}>
							<LogIcon sx={{ fontSize: 64, color: "text.disabled", mb: 2 }} />
							<Typography variant="h6" color="text.secondary">
								No logbook entries found
							</Typography>
							<Typography variant="body2" color="text.secondary">
								Log entries will appear here as owners use the vessels
							</Typography>
						</Box>
					</CardContent>
				</Card>
			)}

			{/* Create Log Entry Dialog */}
			<Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
				<DialogTitle>Create Log Entry</DialogTitle>
				<DialogContent>
					<Box sx={{ display: "flex", flexDirection: "column", gap: 2, mt: 2 }}>
						<TextField
							select
							label="Vessel"
							value={formData.yacht_id}
							onChange={(e) => setFormData({ ...formData, yacht_id: e.target.value })}
							fullWidth
							required
						>
							{yachts?.map((yacht) => (
								<MenuItem key={yacht.id} value={yacht.id}>
									{yacht.name}
								</MenuItem>
							))}
						</TextField>

						<TextField
							select
							label="Entry Type"
							value={formData.entry_type}
							onChange={(e) => setFormData({ ...formData, entry_type: e.target.value })}
							fullWidth
							helperText="Leave blank for automatic detection based on bookings"
						>
							<MenuItem value="">Auto-detect</MenuItem>
							<MenuItem value="fuel">Fuel</MenuItem>
							<MenuItem value="maintenance">Maintenance</MenuItem>
							<MenuItem value="incident">Incident</MenuItem>
							<MenuItem value="general">General</MenuItem>
						</TextField>

						<TextField
							type="number"
							label="Fuel (Liters)"
							value={formData.fuel_liters}
							onChange={(e) => setFormData({ ...formData, fuel_liters: e.target.value })}
							fullWidth
							inputProps={{ step: "0.1", min: "0" }}
						/>

						<TextField
							type="number"
							label="Fuel Cost ($)"
							value={formData.fuel_cost}
							onChange={(e) => setFormData({ ...formData, fuel_cost: e.target.value })}
							fullWidth
							inputProps={{ step: "0.01", min: "0" }}
						/>

						<TextField
							type="number"
							label="Hours Operated"
							value={formData.hours_operated}
							onChange={(e) => setFormData({ ...formData, hours_operated: e.target.value })}
							fullWidth
							inputProps={{ step: "0.1", min: "0" }}
						/>

						<TextField
							label="Notes"
							value={formData.notes}
							onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
							fullWidth
							multiline
							rows={4}
						/>
					</Box>
				</DialogContent>
				<DialogActions>
					<Button onClick={handleCloseDialog}>Cancel</Button>
					<Button onClick={handleSubmit} variant="contained" disabled={createLogbook.isPending}>
						{createLogbook.isPending ? "Creating..." : "Create"}
					</Button>
				</DialogActions>
			</Dialog>

			{/* Snackbar for notifications */}
			<Snackbar
				open={snackbarOpen}
				autoHideDuration={4000}
				onClose={() => setSnackbarOpen(false)}
				message={snackbarMessage}
			/>
		</Box>
	);
};
