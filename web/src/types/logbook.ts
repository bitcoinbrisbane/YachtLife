import type { Yacht } from "./yacht";
import type { Owner } from "./owner";

export type LogbookEntryType =
	| "departure"
	| "return"
	| "fuel"
	| "maintenance"
	| "general"
	| "incident";

export interface Booking {
	id: string;
	yacht_id: string;
	user_id: string;
	start_date: string;
	end_date: string;
	status: "pending" | "confirmed" | "cancelled" | "completed";
	booking_type: "regular" | "standby";
	is_standby: boolean;
	notes?: string;
	cancelled_at?: string;
	created_at: string;
	updated_at: string;
}

export interface LogbookEntry {
	id: string;
	yacht_id: string;
	booking_id?: string;
	user_id: string;
	entry_type: LogbookEntryType;
	fuel_liters?: number;
	fuel_cost?: number;
	hours_operated?: number;
	notes?: string;
	created_at: string;
	yacht?: Yacht;
	booking?: Booking;
	user?: Owner;
}

export interface CreateLogbookEntryRequest {
	yacht_id: string;
	entry_type?: LogbookEntryType;
	fuel_liters?: number;
	fuel_cost?: number;
	hours_operated?: number;
	notes?: string;
}
