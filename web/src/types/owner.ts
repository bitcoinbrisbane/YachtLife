import type { Yacht } from "./yacht";

export interface SyndicateShare {
	id: string;
	yacht_id: string;
	user_id: string;
	share_percentage: number;
	days_per_year: number;
	standby_days_remaining: number;
	joined_date: string;
	created_at: string;
	updated_at: string;
	yacht?: Yacht;
}

export interface Owner {
	id: string;
	apple_user_id?: string;
	email: string;
	first_name: string;
	last_name: string;
	phone?: string;
	country?: string;
	role: "owner" | "admin" | "manager";
	profile_image_url?: string;
	last_login_at?: string;
	created_at: string;
	updated_at: string;
	deleted_at?: string;
	syndicate_shares?: SyndicateShare[];
}
