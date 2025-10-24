# 🚗 Mod Garage

**Mod Garage** is an iOS application designed for car enthusiasts to **track, manage, and document their vehicle modifications**.
It provides a smart and user-friendly way for users to register their cars, log modifications, and get intelligent reminders.
All backed by **Firebase authentication**, **secure cloud data**, and integration with the **DVLA API** for live vehicle information.

---

## 📱 Features

### 🔐 Authentication
- Secure login and signup using **Firebase Authentication** (email and password).
- Persistent user sessions with seamless login state restoration.
- Real-time form validation with visual feedback and error handling.

- ### 🌙 Light & Dark Mode
- Adaptive design that follows the system’s light or dark mode.
- Consistent color scheme and layout across both themes.

### Future Features
- Add and track multiple vehicles.
- Integration with the **DVLA API** to fetch verified car details automatically (registration, model, year, MOT, etc.).
- Track modifications (e.g., performance, appearance, maintenance).
- View and edit modification history.
- Upload and view images of modifications.
- Automatic reminders for MOT, and tax using DVLA data.
- Notifications ensure compliance and help users stay on top of important dates.
- All user and vehicle data securely stored in **Firebase Firestore**.
- Real-time sync across multiple devices.

---

## 🧠 Rationale & Background

The idea behind Mod Garage is to create a **central hub for car enthusiasts** to manage every aspect of their vehicle’s journey.  
Existing platforms (like fuelly or DrivesMART) provide limited functionality — focusing mostly on fuel and efficiency.  
**Mod Garage** differentiates itself by combining:
- DVLA integration for verified vehicle data, and  
- a personal logbook for modifications, upgrades, and reminders.  

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend (UI)** | SwiftUI |
| **Backend** | Firebase Authentication & Firestore |
| **API Integration** | DVLA API |
| **Build Tool** | Xcode |
| **Language** | Swift 5 |
| **Version Control** | Git & GitHub |
| **Project Management** | Trello (Agile Methodology) |

---

## ⚙️ Installation

### Prerequisites
- macOS with **Xcode 15+**
- **CocoaPods** installed
- A valid **Firebase iOS app configuration file** 
- iOS 17.0 or later

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/usmaan04/mod-garage.git
   cd mod-garage
