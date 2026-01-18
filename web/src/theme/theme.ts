import { createTheme } from "@mui/material/styles";

// Maritime/Yacht color palette - inspired by ocean, luxury yachts
const theme = createTheme({
	palette: {
		mode: "light",
		primary: {
			main: "#0277BD", // Deep ocean blue
			light: "#58A5F0", // Light sky blue
			dark: "#01579B", // Navy blue
			contrastText: "#FFFFFF",
		},
		secondary: {
			main: "#00ACC1", // Cyan/turquoise
			light: "#5DDEF4", // Light cyan
			dark: "#007C91", // Dark cyan
			contrastText: "#FFFFFF",
		},
		success: {
			main: "#2E7D32", // Green for success states
			light: "#60AD5E",
			dark: "#1B5E20",
		},
		warning: {
			main: "#ED6C02", // Orange for warnings
			light: "#FF9800",
			dark: "#E65100",
		},
		error: {
			main: "#D32F2F", // Red for errors
			light: "#EF5350",
			dark: "#C62828",
		},
		background: {
			default: "#F5F7FA", // Light gray-blue background
			paper: "#FFFFFF",
		},
		text: {
			primary: "#1A2027", // Almost black
			secondary: "#60646B", // Medium gray
		},
	},
	typography: {
		fontFamily: [
			"-apple-system",
			"BlinkMacSystemFont",
			'"Segoe UI"',
			"Roboto",
			'"Helvetica Neue"',
			"Arial",
			"sans-serif",
		].join(","),
		h1: {
			fontSize: "2.5rem",
			fontWeight: 600,
			color: "#1A2027",
		},
		h2: {
			fontSize: "2rem",
			fontWeight: 600,
			color: "#1A2027",
		},
		h3: {
			fontSize: "1.75rem",
			fontWeight: 600,
			color: "#1A2027",
		},
		h4: {
			fontSize: "1.5rem",
			fontWeight: 600,
			color: "#1A2027",
		},
		h5: {
			fontSize: "1.25rem",
			fontWeight: 600,
			color: "#1A2027",
		},
		h6: {
			fontSize: "1.125rem",
			fontWeight: 600,
			color: "#1A2027",
		},
		button: {
			textTransform: "none", // Don't uppercase buttons
			fontWeight: 500,
		},
	},
	shape: {
		borderRadius: 12, // Rounded corners for modern look
	},
	components: {
		MuiButton: {
			styleOverrides: {
				root: {
					borderRadius: 10,
					padding: "10px 24px",
					fontSize: "1rem",
					fontWeight: 500,
				},
				contained: {
					boxShadow: "0 2px 8px rgba(2, 119, 189, 0.2)",
					"&:hover": {
						boxShadow: "0 4px 12px rgba(2, 119, 189, 0.3)",
					},
				},
			},
		},
		MuiCard: {
			styleOverrides: {
				root: {
					borderRadius: 12,
					boxShadow: "0 2px 8px rgba(0, 0, 0, 0.08)",
					"&:hover": {
						boxShadow: "0 4px 16px rgba(0, 0, 0, 0.12)",
					},
				},
			},
		},
		MuiPaper: {
			styleOverrides: {
				root: {
					backgroundImage: "none", // Remove MUI default gradient
				},
				elevation1: {
					boxShadow: "0 2px 8px rgba(0, 0, 0, 0.08)",
				},
				elevation2: {
					boxShadow: "0 4px 12px rgba(0, 0, 0, 0.1)",
				},
			},
		},
		MuiAppBar: {
			styleOverrides: {
				root: {
					boxShadow: "0 2px 8px rgba(0, 0, 0, 0.08)",
					backgroundColor: "#FFFFFF",
					color: "#1A2027",
				},
			},
		},
		MuiDrawer: {
			styleOverrides: {
				paper: {
					backgroundColor: "#FFFFFF",
					borderRight: "1px solid rgba(0, 0, 0, 0.08)",
				},
			},
		},
		MuiChip: {
			styleOverrides: {
				root: {
					borderRadius: 8,
					fontWeight: 500,
				},
			},
		},
	},
});

export default theme;
