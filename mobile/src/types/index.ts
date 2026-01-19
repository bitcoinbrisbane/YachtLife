export type LogbookEntryType =
  | 'departure'
  | 'return'
  | 'fuel'
  | 'maintenance'
  | 'general'
  | 'incident';

export interface Yacht {
  id: string;
  name: string;
  manufacturer: string;
  model: string;
  year: number;
  berth_location: string;
  berth_bay_number: string;
  home_port: string;
}

export interface User {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
}

export interface Booking {
  id: string;
  yacht_id: string;
  user_id: string;
  start_date: string;
  end_date: string;
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed';
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
  user?: User;
}

export interface CreateLogbookEntryRequest {
  yacht_id: string;
  entry_type?: LogbookEntryType;
  fuel_liters?: number;
  fuel_cost?: number;
  hours_operated?: number;
  notes?: string;
}
