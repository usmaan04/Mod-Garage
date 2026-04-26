🚗 Mod Garage

**Mod Garage** is an iOS application designed for car enthusiasts to **track, manage, and document vehicle modifications**
It provides a user-friendly way for users to register their vehicles, log modifications, and get reminders
All backed by **Firebase authentication**, **secure cloud data**, and integration with the **DVLA API** for live vehicle information

---

## 📱 Features

### 🔐 Authentication
- Secure account creation and login using **Firebase Authentication**
- Sign in with:
  - Email & Password
  - Google Sign-In
- Persistent sessions with automatic login restoration
- Password reset flow
- Real-time validation and error handling

### Vehicle Management
- Add and manage multiple vehicles
- Set a **Primary Vehicle** for dashboard focus
- Edit or remove vehicles at any time
- Upload custom vehicle photos
- Store important details including:
  - Registration number
  - Make
  - Model
  - Year
  - MOT expiry
  - Tax expiry
  - MOT / Tax status

## 🇬🇧 DVLA API Integration

Mod Garage connects with the **DVLA API** to automatically fetch verified UK vehicle information from a registration plate.

Automatically retrieves:

- Vehicle make
- Colour
- Year of manufacture
- MOT status
- MOT expiry date
- Tax status
- Tax due date

This reduces manual entry and helps ensure reliable data.

## 🛠 Modification Tracking

Keep a complete record of every upgrade and change made to your vehicle.

Add and manage modifications such as:

- Performance upgrades
- Wheels / suspension
- Exterior styling
- Interior upgrades
- Maintenance 

### Each modification can include:

- Name
- Description
- Cost
- Date installed
- Photos / before & after images

## ⛽ Fuel Logging & Running Costs

Track fuel purchases and mileage over time.

### Features include:

- Log fuel fill-ups
- Store:
  - Date
  - Mileage
  - Fuel amount
  - Cost
- Review historical fuel logs
- Build long-term ownership insights

## 🔔 Smart Notifications & Reminders

Never miss an important deadline.

### Automatic reminders for:

- MOT expiry
- Road tax expiry

### Custom reminder controls:

- Multiple lead times (60, 30, 14, 7, 3, 1 days)
- Custom notification time of day
- Enable / disable MOT reminders
- Enable / disable Tax reminders

All notifications are generated locally on device.

## 🏠 Dashboard Experience

The Home Dashboard gives users an instant overview of their selected vehicle.

### Includes:

- Vehicle image and details
- Registration display
- MOT countdown
- Tax countdown
- Recent fuel logs
- Latest installed modifications
- Quick add actions
- Upcoming reminders overlay

---

## 🎨 UI / UX

Built fully in **SwiftUI** with a polished native iOS experience.

### Includes:

- Light mode
- Dark mode
- Smooth animations
- Loading skeleton states
- Responsive layouts
- Native sheets / overlays
- Clean automotive-inspired design

# 🔒 Security & Cloud Sync

All user data is securely stored using Firebase services.

### Powered by:

- **Firebase Authentication**
- **Cloud Firestore**
- Secure per-user data separation
- Real-time sync across devices

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend (UI)** | SwiftUI |
| **Backend** | Firebase |
| **Auth** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage |
| **API Integration** | DVLA API |
| **Build Tool** | Xcode |
| **Language** | Swift 5 |
| **Version Control** | Git & GitHub |
| **Project Management** | Trello |

---

## ⚙️ Installation

## Requirements

- macOS
- Xcode 15+
- iOS 17+
- CocoaPods or Swift Package Manager
- Firebase project setup
- GoogleService-Info.plist file
- An Apple Developer account (recommended for testing on device)
- A Firebase project
- DVLA API key

---

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/usmaan04/mod-garage.git
   cd mod-garage

2. **Open the project in Xcode:**
   open ModGarage.xcodeproj
   Xcode should automatically resolve packages.
   If not:
    In Xcode, go to:
       File > Add Package Dependencies
         Then add Firebase packages.

3. **Firebase Setup**
   Create a Firebase project at: https://console.firebase.google.com
   Then:
      - Add an iOS App
      - Use your app bundle identifier, for example: com.usmaan.modgarage
      - Enable Services
      - Turn on:
      - Firebase Authentication
      - Google Sign-In
      - Cloud Firestore
      - Firebase Storage (if using image uploads)
      - Download Config File
      - Download:
      - GoogleService-Info.plist
      - Drag this file into your Xcode project root.
      - Ensure: Copy items if needed is checked.
        
3. Configure Authentication
      - Inside Firebase Console:
      - Enable Sign-In Providers
      - Turn on:
          Email / Password
          Google Sign-In
          Google Sign-In Setup
      - Add your reversed client ID to your URL Types inside Xcode:
      - Targets > Info > URL Types
        
4. **Configure Firestore Database**
      - Create a Firestore database in Production or Test Mode.
      - Suggested collections:
         users/{userId}/vehicles
         users/{userId}/vehicles/{vehicleId}/modifications
         users/{userId}/vehicles/{vehicleId}/fuelLogs
      - Set your Firestore security rules appropriately.
        
6. **Configure Firebase Storage**
      - If using image uploads for:
         Vehicle photos
         Modification photos
      - Enable Firebase Storage inside Firebase Console.
      - 
7. **Add DVLA API Key**
      - Apply for UK DVLA Vehicle Enquiry API access.
      - Once you receive your key, add it to your app configuration.
      Example:
         let apiKey = "YOUR_DVLA_KEY"
      Recommended: store it in:
         .xcconfig
         Environment variables
         Secure config file

8. **Open the Project**
   Use one of:
      open ModGarage.xcodeproj
   or
      open ModGarage.xcworkspace
      
9. Run the App
   In Xcode:
      Select an iPhone Simulator or physical device
   Press:
      ⌘ + R
   The app should build and launch.
