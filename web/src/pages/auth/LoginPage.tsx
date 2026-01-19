import { useState } from "react";
import { Box, Card, CardContent, TextField, Button, Typography, Alert } from "@mui/material";
import { DirectionsBoat as BoatIcon } from "@mui/icons-material";
import { useForm } from "react-hook-form";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";

interface LoginFormData {
	email: string;
	password: string;
}

export const LoginPage = () => {
	const [error, setError] = useState<string>("");
	const { login } = useAuth();
	const navigate = useNavigate();
	const {
		register,
		handleSubmit,
		formState: { errors, isSubmitting },
	} = useForm<LoginFormData>();

	const onSubmit = async (data: LoginFormData) => {
		try {
			setError("");
			await login(data.email, data.password);
			navigate("/dashboard");
		} catch {
			setError("Invalid email or password. Please try again.");
		}
	};

	return (
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
			<Card sx={{ maxWidth: 450, width: "100%" }}>
				<CardContent sx={{ p: 4 }}>
					<Box sx={{ textAlign: "center", mb: 4 }}>
						<BoatIcon sx={{ fontSize: 64, color: "primary.main", mb: 2 }} />
						<Typography variant="h4" gutterBottom fontWeight={600}>
							YachtLife
						</Typography>
						<Typography variant="body2" color="text.secondary">
							Management Dashboard
						</Typography>
					</Box>

					{error && (
						<Alert severity="error" sx={{ mb: 3 }}>
							{error}
						</Alert>
					)}

					<form onSubmit={handleSubmit(onSubmit)}>
						<TextField
							fullWidth
							label="Email"
							type="email"
							{...register("email", {
								required: "Email is required",
								pattern: {
									value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
									message: "Invalid email address",
								},
							})}
							error={!!errors.email}
							helperText={errors.email?.message}
							sx={{ mb: 2 }}
						/>

						<TextField
							fullWidth
							label="Password"
							type="password"
							{...register("password", {
								required: "Password is required",
								minLength: {
									value: 6,
									message: "Password must be at least 6 characters",
								},
							})}
							error={!!errors.password}
							helperText={errors.password?.message}
							sx={{ mb: 3 }}
						/>

						<Button
							fullWidth
							type="submit"
							variant="contained"
							size="large"
							disabled={isSubmitting}
						>
							{isSubmitting ? "Logging in..." : "Login"}
						</Button>
					</form>

					<Typography
						variant="caption"
						color="text.secondary"
						sx={{ display: "block", textAlign: "center", mt: 3 }}
					>
						For managers and administrators only
					</Typography>
				</CardContent>
			</Card>
		</Box>
	);
};
