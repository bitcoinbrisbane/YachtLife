import {
	Box,
	Typography,
	Card,
	CardContent,
	CircularProgress,
	Alert,
	Chip,
	Avatar,
	Table,
	TableBody,
	TableCell,
	TableContainer,
	TableHead,
	TableRow,
	Paper,
} from "@mui/material";
import {
	People as PeopleIcon,
	Email as EmailIcon,
	Phone as PhoneIcon,
	Public as CountryIcon,
} from "@mui/icons-material";
import { useOwners } from "../../hooks/useOwners";

export const OwnersPage = () => {
	const { data: owners, isLoading, error } = useOwners();

	if (isLoading) {
		return (
			<Box sx={{ display: "flex", justifyContent: "center", alignItems: "center", minHeight: 400 }}>
				<CircularProgress />
			</Box>
		);
	}

	if (error) {
		return <Alert severity="error">Failed to load owners. Please try again later.</Alert>;
	}

	return (
		<Box>
			<Box sx={{ display: "flex", justifyContent: "space-between", alignItems: "center", mb: 4 }}>
				<Box>
					<Typography variant="h4" gutterBottom fontWeight={600}>
						Syndicate Owners
					</Typography>
					<Typography variant="body1" color="text.secondary">
						Manage yacht syndicate ownership and shares
					</Typography>
				</Box>
				<Chip label={`${owners?.length || 0} Owners`} color="primary" icon={<PeopleIcon />} />
			</Box>

			{owners && owners.length > 0 ? (
				<TableContainer component={Paper}>
					<Table>
						<TableHead>
							<TableRow>
								<TableCell>Owner</TableCell>
								<TableCell>Contact</TableCell>
								<TableCell>Country</TableCell>
								<TableCell>Shares</TableCell>
								<TableCell>Joined</TableCell>
							</TableRow>
						</TableHead>
						<TableBody>
							{owners.map((owner) => (
								<TableRow key={owner.id} hover>
									<TableCell>
										<Box sx={{ display: "flex", alignItems: "center", gap: 2 }}>
											<Avatar
												sx={{
													bgcolor: "primary.main",
													width: 48,
													height: 48,
													fontSize: "1.25rem",
												}}
											>
												{owner.first_name[0]}
												{owner.last_name[0]}
											</Avatar>
											<Box>
												<Typography variant="body1" fontWeight={600}>
													{owner.first_name} {owner.last_name}
												</Typography>
												<Typography variant="caption" color="text.secondary">
													ID: {owner.id.substring(0, 8)}...
												</Typography>
											</Box>
										</Box>
									</TableCell>
									<TableCell>
										<Box sx={{ display: "flex", flexDirection: "column", gap: 0.5 }}>
											<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
												<EmailIcon sx={{ fontSize: 16, color: "text.secondary" }} />
												<Typography variant="body2">{owner.email}</Typography>
											</Box>
											{owner.phone && (
												<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
													<PhoneIcon sx={{ fontSize: 16, color: "text.secondary" }} />
													<Typography variant="body2">{owner.phone}</Typography>
												</Box>
											)}
										</Box>
									</TableCell>
									<TableCell>
										<Box sx={{ display: "flex", alignItems: "center", gap: 1 }}>
											<CountryIcon sx={{ fontSize: 16, color: "text.secondary" }} />
											<Typography variant="body2">{owner.country || "N/A"}</Typography>
										</Box>
									</TableCell>
									<TableCell>
										<Typography variant="body2" fontWeight={600}>
											{owner.syndicate_shares?.length || 0} vessel
											{owner.syndicate_shares?.length !== 1 ? "s" : ""}
										</Typography>
									</TableCell>
									<TableCell>
										<Typography variant="body2" color="text.secondary">
											{new Date(owner.created_at).toLocaleDateString()}
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
							<PeopleIcon sx={{ fontSize: 64, color: "text.disabled", mb: 2 }} />
							<Typography variant="h6" color="text.secondary">
								No owners found
							</Typography>
							<Typography variant="body2" color="text.secondary">
								Add your first owner to get started
							</Typography>
						</Box>
					</CardContent>
				</Card>
			)}
		</Box>
	);
};
