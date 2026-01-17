# YachtLife Mobile App (React Native)

Mobile application for yacht owners to manage bookings, invoices, maintenance, and more.

## Prerequisites

- Node.js 18+
- React Native CLI
- Xcode (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)

## Setup

1. Install dependencies:
```bash
yarn install
```

2. Install iOS dependencies:
```bash
cd ios && pod install && cd ..
```

3. Set up environment:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Running the App

### iOS
```bash
yarn ios
```

### Android
```bash
yarn android
```

## Project Structure

```
src/
├── screens/          # Screen components
│   ├── auth/         # Authentication screens (Apple Sign In, Onboarding)
│   ├── dashboard/    # Vessel dashboard with hero image
│   ├── bookings/     # Booking management
│   ├── invoices/     # Invoice viewing and payments
│   ├── logbook/      # Fuel and logbook entries
│   ├── maintenance/  # Maintenance requests with photos
│   ├── checklists/   # Pre-departure and return checklists
│   └── voting/       # Syndicate voting
├── components/       # Reusable components
├── navigation/       # Navigation configuration
├── services/         # API services
├── types/            # TypeScript types
└── utils/            # Utility functions
```

## Features

- Apple Sign In authentication
- Vessel dashboard with beautiful hero images
- Booking management (create, view, cancel, modify)
- Invoice viewing and Apple Pay/Google Pay payments
- Logbook entries for fuel and maintenance
- Pre-departure and return checklists
- Maintenance requests with camera integration
- Syndicate voting participation
- Push notifications

## Full Setup Instructions

To complete the React Native setup, you'll need to:
1. Run `npx react-native init` to generate iOS and Android platform folders
2. Configure Apple Sign In in Xcode
3. Configure Google Pay in Android Studio
4. Set up Firebase Cloud Messaging for push notifications

See the main README for detailed setup instructions.
