# Fair Share Algorithm Specification

## Overview

The Fair Share Algorithm ensures equitable access to a shared vessel based on ownership percentage, accounting for slot desirability, historical usage, and booking preferences.

---

## Core Principles

1. **Proportional Access** - Owners receive time proportional to their ownership stake
2. **Equal Desirability** - High-demand periods are distributed fairly, not first-come-first-served
3. **Transparency** - Owners can see exactly why they have their current allocation
4. **Flexibility** - Supports swaps, standby, and consecutive-day bookings
5. **Self-Balancing** - System corrects imbalances over time automatically

---

## Slot Classification & Weighting

### Time Slot Types

| Slot Type | Days | Weight |
|-----------|------|--------|
| Premium Weekend | Sat-Sun (peak season) | 3.0 |
| Standard Weekend | Sat-Sun (off-peak) | 2.0 |
| Public Holiday | Any public holiday | 3.5 |
| Peak Weekday | Mon-Fri (school holidays) | 1.5 |
| Standard Weekday | Mon-Fri (regular) | 1.0 |

### Seasonal Multipliers (Configurable by Region)

| Season | Months (AU Example) | Multiplier |
|--------|---------------------|------------|
| Peak Summer | Dec-Feb | 1.5x |
| Shoulder | Mar-Apr, Oct-Nov | 1.2x |
| Off-Peak | May-Sep | 1.0x |

### Effective Slot Value

```
SlotValue = BaseWeight × SeasonMultiplier
```

**Example:** Saturday in January = 3.0 × 1.5 = **4.5 points**

---

## Owner Credit System

### Annual Credit Allocation

Each owner receives annual credits proportional to ownership:

```
OwnerCredits = TotalAnnualSlotValue × OwnershipPercentage
```

**Example (10-share syndicate, equal shares):**
- Total annual slot value: ~1,200 points
- Each 10% owner: 120 points/year
- Roughly 30-40 days depending on slot mix

### Credit Consumption

When an owner books a slot:
```
RemainingCredits = CurrentCredits - SlotValue
```

### Rolling Balance

Credits don't reset annually - they roll over with decay:
```
NewYearCredits = (PreviousBalance × 0.25) + AnnualAllocation
```

This allows:
- Slight banking for special occasions
- Prevents hoarding
- Self-corrects over-users

---

## Booking Priority Algorithm

### Priority Score Calculation

When multiple owners want the same slot:

```python
def calculate_priority(owner, slot, all_owners):
    # Base priority from ownership percentage
    base = owner.ownership_percentage * 100
    
    # Credit balance factor (higher balance = higher priority)
    avg_balance = mean([o.credit_balance for o in all_owners])
    balance_factor = (owner.credit_balance / avg_balance) * 20
    
    # Historical slot-type fairness
    # If owner has had fewer premium slots than fair share, boost priority
    expected_premium = owner.ownership_percentage * total_premium_slots_ytd
    actual_premium = owner.premium_slots_booked_ytd
    premium_deficit = (expected_premium - actual_premium) * 5
    
    # Consecutive booking penalty (prevent blocking)
    consecutive_penalty = owner.consecutive_days_booked * -2
    
    # Time since last booking bonus
    days_since_last = (today - owner.last_booking_date).days
    recency_bonus = min(days_since_last * 0.5, 10)
    
    return base + balance_factor + premium_deficit + consecutive_penalty + recency_bonus
```

### Conflict Resolution

1. Calculate priority score for each requesting owner
2. Highest score wins the slot
3. Losers automatically added to waitlist
4. In case of tie: random selection (logged for audit)

---

## Booking Windows

### Phased Release System

Slots become available in phases to ensure fair access:

| Phase | Timing | Who Can Book |
|-------|--------|--------------|
| Draft Round | 60 days out | Round-robin selection (see below) |
| Open Booking | 45 days out | Any owner, priority-scored |
| Short Notice | 7 days out | Any owner, first-come-first-served |
| Standby | 24 hours out | Any owner, no credit cost |

### Draft Round (Key Innovation)

For premium periods (summer, holidays), use a snake draft:

**Round 1:** Owner A → B → C → D → E
**Round 2:** Owner E → D → C → B → A
**Round 3:** Owner A → B → C → D → E
...

Draft order rotates each year so no owner is permanently disadvantaged.

---

## Consecutive Day Bookings

### Multi-Day Trip Support

Owners can book consecutive days for cruising:

```python
def book_consecutive(owner, start_date, num_days):
    slots = get_slots(start_date, num_days)
    total_value = sum(slot.value for slot in slots)
    
    # Apply consecutive day discount (encourages longer trips)
    if num_days >= 3:
        discount = 0.9  # 10% off
    elif num_days >= 7:
        discount = 0.8  # 20% off
    else:
        discount = 1.0
    
    final_cost = total_value * discount
    
    if owner.credit_balance >= final_cost:
        # Book all slots atomically
        return confirm_booking(owner, slots, final_cost)
    else:
        return insufficient_credits_error(owner, final_cost)
```

### Maximum Consecutive Days

Configurable per syndicate (default: 14 days max)

---

## Standby System

### How Standby Works

- Slots within 24-48 hours become "standby" if unbooked
- Any owner can claim at no credit cost
- Encourages vessel utilisation
- First-come-first-served (rewards engaged owners)

### Cancellation → Standby Flow

```
Owner cancels booking (>48hrs out)
    → Credits refunded (minus 10% cancellation fee if <7 days)
    → Slot moves to waitlist holders first
    → If no waitlist, slot becomes standby at 48hrs
```

---

## Swap Marketplace

### Owner-to-Owner Swaps

Owners can trade slots directly:

```python
def propose_swap(owner_a, slot_a, owner_b, slot_b):
    value_a = slot_a.value
    value_b = slot_b.value
    
    # Calculate credit adjustment
    difference = value_a - value_b
    
    # Create swap proposal
    swap = SwapProposal(
        proposer=owner_a,
        recipient=owner_b,
        slot_offered=slot_a,
        slot_requested=slot_b,
        credit_adjustment=difference  # Positive = B pays A
    )
    
    notify_owner(owner_b, swap)
    return swap
```

### Swap Rules

- Both parties must confirm
- Credit difference is transferred
- Management company notified (for cleaning/prep scheduling)
- Audit trail maintained

---

## Reporting & Transparency

### Owner Dashboard Metrics

Each owner sees:

| Metric | Description |
|--------|-------------|
| Credit Balance | Current points remaining |
| YTD Usage | Days/points used this year |
| Slot Mix | Breakdown of premium vs standard slots |
| Fairness Score | 100 = perfectly proportional, <100 = owed time, >100 = ahead |
| Upcoming Bookings | Next 90 days calendar |

### Fairness Score Calculation

```python
def fairness_score(owner):
    expected_usage = total_syndicate_usage_ytd * owner.ownership_percentage
    actual_usage = owner.usage_ytd
    
    if expected_usage == 0:
        return 100
    
    return (actual_usage / expected_usage) * 100
```

**Interpretation:**
- 100 = Exactly fair
- 80 = Owner has used 20% less than entitled (owed time)
- 120 = Owner has used 20% more than entitled (ahead)

---

## Edge Cases

### New Owner Joins Mid-Year

```python
def onboard_owner(new_owner, join_date):
    # Pro-rata credits for remainder of year
    days_remaining = (year_end - join_date).days
    annual_credits = calculate_annual_credits(new_owner.ownership_percentage)
    pro_rata_credits = annual_credits * (days_remaining / 365)
    
    new_owner.credit_balance = pro_rata_credits
    
    # No draft participation until next year
    new_owner.draft_eligible = False
```

### Owner Exits Mid-Year

- Remaining bookings can be:
  - Transferred to buyer (if share sold)
  - Released to standby pool
  - Swapped with other owners before departure

### Unequal Ownership

Algorithm handles any ownership split:

| Owner | Share | Annual Credits (1200 total) |
|-------|-------|----------------------------|
| A | 40% | 480 |
| B | 35% | 420 |
| C | 25% | 300 |

Draft order weighted: A picks first 40% of rounds, etc.

---

## Configuration Options (Per Syndicate)

| Setting | Default | Description |
|---------|---------|-------------|
| `peak_season_months` | Dec-Feb | High-demand period |
| `weekend_weight` | 2.0 | Premium for Sat/Sun |
| `holiday_weight` | 3.5 | Premium for public holidays |
| `max_consecutive_days` | 14 | Longest single booking |
| `draft_enabled` | true | Use draft for premium periods |
| `standby_window_hours` | 48 | When slots become free |
| `cancellation_fee_percent` | 10 | Fee for late cancellation |
| `rollover_decay` | 0.25 | Credit preservation between years |

---

## Database Schema (Simplified)

```sql
-- Core tables
CREATE TABLE owners (
    id UUID PRIMARY KEY,
    syndicate_id UUID REFERENCES syndicates(id),
    name VARCHAR(255),
    ownership_percentage DECIMAL(5,2),
    credit_balance DECIMAL(10,2),
    created_at TIMESTAMP
);

CREATE TABLE slots (
    id UUID PRIMARY KEY,
    syndicate_id UUID REFERENCES syndicates(id),
    date DATE,
    slot_type VARCHAR(50),  -- 'premium_weekend', 'standard_weekday', etc.
    base_weight DECIMAL(4,2),
    season_multiplier DECIMAL(3,2),
    effective_value DECIMAL(5,2) GENERATED ALWAYS AS (base_weight * season_multiplier),
    status VARCHAR(20) DEFAULT 'available'  -- 'available', 'booked', 'standby'
);

CREATE TABLE bookings (
    id UUID PRIMARY KEY,
    slot_id UUID REFERENCES slots(id),
    owner_id UUID REFERENCES owners(id),
    credits_charged DECIMAL(10,2),
    booking_type VARCHAR(20),  -- 'standard', 'draft', 'standby', 'swap'
    booked_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

CREATE TABLE waitlist (
    id UUID PRIMARY KEY,
    slot_id UUID REFERENCES slots(id),
    owner_id UUID REFERENCES owners(id),
    priority_score DECIMAL(10,2),
    created_at TIMESTAMP
);

CREATE TABLE swaps (
    id UUID PRIMARY KEY,
    proposer_id UUID REFERENCES owners(id),
    recipient_id UUID REFERENCES owners(id),
    slot_offered_id UUID REFERENCES slots(id),
    slot_requested_id UUID REFERENCES slots(id),
    credit_adjustment DECIMAL(10,2),
    status VARCHAR(20),  -- 'proposed', 'accepted', 'rejected', 'expired'
    created_at TIMESTAMP
);
```

---

## Summary

This algorithm ensures:

✅ **Proportional access** - Ownership % directly maps to usage rights
✅ **Premium slot fairness** - Draft system prevents first-mover advantage
✅ **Self-balancing** - Credit system auto-corrects over time
✅ **Flexibility** - Swaps, standby, and consecutive bookings supported
✅ **Transparency** - Owners always know their standing
✅ **Configurability** - Syndicates can tune to their preferences

The key insight is treating **time slots as a weighted currency** rather than equal units - a summer Saturday is worth 4-5x a winter Tuesday, and the algorithm respects this.

---

*Version 1.0 - January 2026*
