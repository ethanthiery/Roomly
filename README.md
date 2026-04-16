# Roomly

A shared chore management app for roommates — tasks are auto-assigned daily, tracked with a cloth reward system, and ranked on a monthly leaderboard.

---

## Requirements

- **Xcode 16+**
- **iOS 17+** (simulator or physical device)
- **macOS 14+**

No additional configuration needed — all dependencies are managed via Swift Package Manager and will resolve automatically on first open.

---

## Getting Started

```bash
git clone <your-repo-url>
cd Roomly
open Roomly.xcodeproj
```

Then in Xcode:

1. Wait for Swift Package Manager to finish resolving packages (progress bar at the top)
2. Select a simulator (e.g. **iPhone 16 Pro**) in the top toolbar
3. Press **⌘ + R** to build and run

---

## Testing the App

The app requires joining a room to access the main experience. On the onboarding **"Join a Room"** screen, use the test link below — it will be pre-filled automatically:

```
roomly://join?flat=roomly-default-flat
```

This connects you to a demo room with 3 roommates: **Lea, James & Laura**.

---

## Running on a Physical Device

If you want to run on a real iPhone instead of the simulator:

1. Connect your iPhone
2. In Xcode → top toolbar → select your device
3. Go to **Signing & Capabilities** → change the **Team** to your own Apple Developer account
4. Change the **Bundle Identifier** to something unique (e.g. `com.yourname.roomly`)
5. Press **⌘ + R**

---

## Dependencies

All resolved automatically via Swift Package Manager:

| Package | Purpose |
|---|---|
| Firebase iOS SDK | Auth, Firestore, Messaging |
| SuperwallKit | Paywall management |

---

## Key Features

- Daily task auto-assignment per roommate
- Cloth reward system with weekly tracking
- Monthly leaderboard (grind ranking)
- Day-Off card purchasable with cloths
- Onboarding flow with room creation/join
- Pro paywall via Superwall
