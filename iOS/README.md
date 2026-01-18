# YachtLife iOS App (Native Swift/SwiftUI)

Native iOS application for yacht owners to manage bookings, invoices, maintenance, and more.

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Networking**: URLSession with async/await
- **Minimum iOS Version**: iOS 17.0+

## Project Structure

```
YachtLife/
├── Models/                 # Data models matching backend API
│   ├── User.swift
│   ├── Yacht.swift
│   ├── Booking.swift
│   ├── Invoice.swift
│   └── Maintenance.swift
├── Views/                  # SwiftUI views
│   ├── Auth/              # Login and authentication screens
│   ├── Dashboard/         # Vessel dashboard with hero images
│   ├── Bookings/          # Booking management
│   ├── Invoices/          # Invoice viewing and payments
│   ├── Maintenance/       # Maintenance requests with camera
│   └── Settings/          # User settings
├── ViewModels/            # View models for business logic
│   └── AuthenticationViewModel.swift
└── Services/              # API and business services
    └── APIService.swift
```

## Getting Started

### Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Go backend running on port 8080

### Running the App

1. **Open the project in Xcode:**
   ```bash
   cd iOS
   open YachtLife.xcodeproj
   ```

2. **Select your target device/simulator**
   - In Xcode, select a simulator or connected device from the scheme selector

3. **Build and run**
   - Press **Cmd+R** or click the Run button
   - The app will build and launch

### Configure API Endpoint

The API base URL is configured in `Services/APIService.swift`:
- **Debug**: `http://localhost:8080/api/v1`
- **Release**: `https://api.yachtlife.com/api/v1`

Make sure your Go backend is running on port 8080.

## Features

### Implemented ✅

- **Authentication** - Email/password login with JWT tokens
- **Dashboard** - View yacht information and upcoming bookings
- **Bookings** - List, view, and create bookings
- **Invoices** - View invoices and payment status
- **Maintenance** - Submit and track maintenance requests
- **Settings** - User profile and app settings

### To Be Implemented ⏳

- **Apple Pay Integration** - In-app invoice payments
- **Camera Integration** - Photo uploads for maintenance requests
- **Push Notifications** - Real-time updates for bookings and invoices
- **Voting** - Syndicate governance voting system
- **Logbook** - Fuel and maintenance logging
- **Checklists** - Pre-departure and return checklists

## API Integration

The app communicates with the Go backend via RESTful API calls.

### Authentication
- `POST /api/v1/auth/login` - Email/password login
- `GET /api/v1/auth/me` - Get current user

### Bookings
- `GET /api/v1/bookings` - List bookings
- `POST /api/v1/bookings` - Create booking

### Invoices
- `GET /api/v1/invoices` - List invoices

### Maintenance
- `GET /api/v1/maintenance` - List maintenance requests
- `POST /api/v1/maintenance` - Create maintenance request

### Yachts
- `GET /api/v1/yachts` - List yachts
- `GET /api/v1/yachts/:id` - Get yacht details

## Development

### Code Style

- Use SwiftUI for all UI components
- Follow MVVM architecture pattern
- Use async/await for networking
- Prefer composition over inheritance
- Use Swift naming conventions

### Testing

Unit tests and UI tests can be added via Xcode:
1. File > New > Target
2. Select "Unit Testing Bundle" or "UI Testing Bundle"

### Building for Release

1. Select "Any iOS Device" as the build destination
2. Product > Archive
3. Follow the prompts to upload to TestFlight or App Store

## Troubleshooting

### Build Errors
- **Clean build folder**: `Cmd+Shift+K`
- **Delete derived data**: `~/Library/Developer/Xcode/DerivedData`
- **Reset package caches**: File > Packages > Reset Package Caches

### API Connection Issues
- Ensure backend is running on `http://localhost:8080`
- Check that the simulator can reach localhost
- Verify `Info.plist` allows localhost networking

### Simulator Issues
- **Reset simulator**: Device > Erase All Content and Settings
- **Restart simulator**: Device > Restart

## Deployment

### TestFlight (Beta Testing)

1. Archive the app: Product > Archive
2. In Organizer, select your archive
3. Click "Distribute App"
4. Select "TestFlight & App Store"
5. Follow the prompts to upload

### App Store

1. Ensure all requirements are met
2. Archive and upload to App Store Connect
3. Fill in app information and screenshots
4. Submit for review

## Contributing

1. Create a feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## License

Proprietary - All rights reserved
