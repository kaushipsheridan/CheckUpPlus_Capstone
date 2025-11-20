# Firebase Configuration Setup

This project uses Firebase for authentication and database services. Configuration files are **not tracked in git** for security reasons.

## 🔧 Required Setup (One-Time)

### For Android Development

1. **Download `google-services.json`:**
   - Go to [Firebase Console](https://console.firebase.google.com/project/checkupplus-5ce4d/settings/general)
   - Click on your Android app (package: `com.example.checkupplus_capstone`)
   - Click **"Download google-services.json"**

2. **Place the file in BOTH locations:**
   ```
   android/app/google-services.json
   android/app/src/google-services.json
   ```

### For iOS Development

1. **Download `GoogleService-Info.plist`:**
   - Go to [Firebase Console](https://console.firebase.google.com/project/checkupplus-5ce4d/settings/general)
   - Click on your iOS app (bundle: `com.example.checkuppluscapstone`)
   - Click **"Download GoogleService-Info.plist"**

2. **Place the file:**
   ```
   ios/Runner/GoogleService-Info.plist
   ```

## 🚀 After Placing Files

```bash
flutter clean
flutter pub get
flutter run
```

## 🔒 Security Note

These configuration files contain:
- Project IDs and numbers
- Client API keys
- OAuth client IDs
- Storage bucket names

**Why we exclude them from git:**
- ✅ Industry best practice
- ✅ Support multiple environments (dev/staging/prod)
- ✅ Reduce attack surface
- ✅ Allow team members to use separate Firebase projects

**Important:** Your data is protected by [Firestore Security Rules](https://console.firebase.google.com/project/checkupplus-5ce4d/firestore/rules), not by keeping these keys secret.

## 📁 File Locations Reference

```
CheckUpPlus_Capstone/
├── android/
│   └── app/
│       ├── google-services.json        ← Place here
│       └── src/
│           └── google-services.json    ← Also place here
└── ios/
    └── Runner/
        └── GoogleService-Info.plist    ← Place here
```

## 🆘 Troubleshooting

### "Firebase not initialized" error
- Ensure config files are in **all** required locations
- Run `flutter clean && flutter pub get`
- Restart your IDE

### "Permission denied" in Firestore
- Check [Firestore Security Rules](https://console.firebase.google.com/project/checkupplus-5ce4d/firestore/rules)
- Ensure user is authenticated before accessing data

### "MissingPluginException"
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Restart your device/emulator

## 📞 Team Access

To give a new team member Firebase access:
1. Add them to the Firebase project at [console.firebase.google.com](https://console.firebase.google.com/project/checkupplus-5ce4d/settings/iam)
2. Give them "Firebase Develop Admin" role
3. They download their own config files
4. They follow the setup steps above

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com/project/checkupplus-5ce4d)
- [Firestore Rules](https://console.firebase.google.com/project/checkupplus-5ce4d/firestore/rules)
- [Authentication Users](https://console.firebase.google.com/project/checkupplus-5ce4d/authentication/users)