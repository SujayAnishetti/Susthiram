---
description: How to initialize and configure Firebase for the Susthiram project
---

# Firebase Setup Workflow

Follow these steps to connect your Flutter app to your Firebase project.

## 1. Install Command Line Tools

If you haven't already, install the Firebase CLI and FlutterFire CLI.

```bash
# Install Firebase CLI (requires Node.js)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

## 2. Configure Project

Run the configuration command in the root of your project (`c:\Projects\BNB_Marathon\susthiram`).

```bash
flutterfire configure
```

**Interactive Steps:**
1.  Select your **Firebase Project** from the list (or create a new one).
2.  Select the **platforms** you want to support (Android, iOS, Web, macOS). Use arrow keys and spacebar to select.
3.  Press **Enter**.

## 3. Verify

This process will:
1.  Update `android/build.gradle` and `android/app/build.gradle`.
2.  Generate a valid `lib/firebase_options.dart` file.

Once done, your app will be able to initialize Firebase successfully.
