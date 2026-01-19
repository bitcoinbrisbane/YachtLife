import { useState } from "react";
import type { ReactNode } from "react";
import {
	Box,
	Drawer,
	AppBar,
	Toolbar,
	List,
	Typography,
	Divider,
	IconButton,
	ListItem,
	ListItemButton,
	ListItemIcon,
	ListItemText,
	Avatar,
	Menu,
	MenuItem,
} from "@mui/material";
import {
	Menu as MenuIcon,
	Dashboard as DashboardIcon,
	DirectionsBoat as BoatIcon,
	People as PeopleIcon,
	CalendarMonth as CalendarIcon,
	AttachMoney as MoneyIcon,
	Build as BuildIcon,
	HowToVote as VoteIcon,
	Assessment as ReportIcon,
	Notifications as NotificationIcon,
	Settings as SettingsIcon,
	Logout as LogoutIcon,
} from "@mui/icons-material";
import { useNavigate, useLocation } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

const drawerWidth = 260;

interface MenuItem {
	text: string;
	icon: ReactNode;
	path: string;
}

const menuItems: MenuItem[] = [
	{ text: "Dashboard", icon: <DashboardIcon />, path: "/dashboard" },
	{ text: "Vessels", icon: <BoatIcon />, path: "/vessels" },
	{ text: "Owners", icon: <PeopleIcon />, path: "/owners" },
	{ text: "Bookings", icon: <CalendarIcon />, path: "/bookings" },
	{ text: "Financial", icon: <MoneyIcon />, path: "/financial" },
	{ text: "Maintenance", icon: <BuildIcon />, path: "/maintenance" },
	{ text: "Voting", icon: <VoteIcon />, path: "/voting" },
	{ text: "Reports", icon: <ReportIcon />, path: "/reports" },
	{ text: "Notifications", icon: <NotificationIcon />, path: "/notifications" },
	{ text: "Settings", icon: <SettingsIcon />, path: "/settings" },
];

interface DashboardLayoutProps {
	children: ReactNode;
}

export const DashboardLayout = ({ children }: DashboardLayoutProps) => {
	const [mobileOpen, setMobileOpen] = useState(false);
	const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
	const navigate = useNavigate();
	const location = useLocation();
	const { user, logout } = useAuth();

	const handleDrawerToggle = () => {
		setMobileOpen(!mobileOpen);
	};

	const handleMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
		setAnchorEl(event.currentTarget);
	};

	const handleMenuClose = () => {
		setAnchorEl(null);
	};

	const handleLogout = () => {
		logout();
		navigate("/login");
	};

	const drawer = (
		<Box>
			<Toolbar sx={{ gap: 1, py: 2 }}>
				<BoatIcon sx={{ fontSize: 32, color: "primary.main" }} />
				<Typography variant="h6" noWrap component="div" sx={{ fontWeight: 600 }}>
					YachtLife
				</Typography>
			</Toolbar>
			<Divider />
			<List>
				{menuItems.map((item) => {
					const isActive = location.pathname === item.path;
					return (
						<ListItem key={item.text} disablePadding>
							<ListItemButton
								selected={isActive}
								onClick={() => navigate(item.path)}
								sx={{
									mx: 1,
									borderRadius: 2,
									"&.Mui-selected": {
										backgroundColor: "primary.main",
										color: "white",
										"&:hover": {
											backgroundColor: "primary.dark",
										},
										"& .MuiListItemIcon-root": {
											color: "white",
										},
									},
								}}
							>
								<ListItemIcon
									sx={{
										color: isActive ? "white" : "text.secondary",
									}}
								>
									{item.icon}
								</ListItemIcon>
								<ListItemText primary={item.text} />
							</ListItemButton>
						</ListItem>
					);
				})}
			</List>
		</Box>
	);

	return (
		<Box sx={{ display: "flex" }}>
			<AppBar
				position="fixed"
				sx={{
					width: { sm: `calc(100% - ${drawerWidth}px)` },
					ml: { sm: `${drawerWidth}px` },
				}}
			>
				<Toolbar>
					<IconButton
						color="inherit"
						aria-label="open drawer"
						edge="start"
						onClick={handleDrawerToggle}
						sx={{ mr: 2, display: { sm: "none" } }}
					>
						<MenuIcon />
					</IconButton>
					<Typography
						variant="h6"
						noWrap
						component="div"
						sx={{ flexGrow: 1, color: "text.primary" }}
					>
						Yacht Syndicate Management
					</Typography>
					<IconButton onClick={handleMenuOpen} sx={{ ml: 2 }}>
						<Avatar sx={{ width: 36, height: 36, bgcolor: "primary.main" }}>
							{user?.name?.charAt(0) || "U"}
						</Avatar>
					</IconButton>
					<Menu
						anchorEl={anchorEl}
						open={Boolean(anchorEl)}
						onClose={handleMenuClose}
						transformOrigin={{ horizontal: "right", vertical: "top" }}
						anchorOrigin={{ horizontal: "right", vertical: "bottom" }}
					>
						<MenuItem disabled>
							<Box>
								<Typography variant="body2" fontWeight={600}>
									{user?.name}
								</Typography>
								<Typography variant="caption" color="text.secondary">
									{user?.email}
								</Typography>
							</Box>
						</MenuItem>
						<Divider />
						<MenuItem onClick={handleLogout}>
							<ListItemIcon>
								<LogoutIcon fontSize="small" />
							</ListItemIcon>
							Logout
						</MenuItem>
					</Menu>
				</Toolbar>
			</AppBar>
			<Box
				component="nav"
				sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
				aria-label="navigation menu"
			>
				<Drawer
					variant="temporary"
					open={mobileOpen}
					onClose={handleDrawerToggle}
					ModalProps={{
						keepMounted: true,
					}}
					sx={{
						display: { xs: "block", sm: "none" },
						"& .MuiDrawer-paper": { boxSizing: "border-box", width: drawerWidth },
					}}
				>
					{drawer}
				</Drawer>
				<Drawer
					variant="permanent"
					sx={{
						display: { xs: "none", sm: "block" },
						"& .MuiDrawer-paper": { boxSizing: "border-box", width: drawerWidth },
					}}
					open
				>
					{drawer}
				</Drawer>
			</Box>
			<Box
				component="main"
				sx={{
					flexGrow: 1,
					p: 3,
					width: { sm: `calc(100% - ${drawerWidth}px)` },
					minHeight: "100vh",
					backgroundColor: "background.default",
				}}
			>
				<Toolbar />
				{children}
			</Box>
		</Box>
	);
};
