# LoopSmith AI

## Overview
AI-powered royalty-free loop generation app for music producers and beat makers. Users describe loops via text prompts, select parameters (genre, mood, BPM, key, etc.), and generate professional-quality musical loops. Target audience: hip-hop, electronic, and multi-genre producers seeking fast creative workflows.

## Tech Stack & Key Decisions
- Flutter chosen over React Native for superior animation/rendering performance needed for waveform displays and glassmorphic UI
- ChangeNotifier + Provider for state — AuthService is global (main.dart); GeneratorProvider and BrowserProvider are route-scoped
- go_router with StatefulShellRoute for bottom navigation with 5 tabs: Generate, Library, Community, AI Copilot, Account
- Firebase project ID: loopsmith-ai; Android SDK app ID: 1:666214661695:android:2fc7a74ac1eaac9451428a
- Firebase Auth is fully live: Google Sign-In (google_sign_in), Apple (signInWithProvider), Email/Password, password reset
- Firestore collection `users/{uid}` stores UserModel fields; AuthService merges Firestore data with Firebase Auth user on every sign-in
- Bundle IDs: com.loopsmithai.app (both Android and iOS) — production-ready, do not change without publishing implications
- google_fonts (Inter) for clean, modern DAW-inspired typography

## Architecture
- App flow: Splash → Onboarding (first launch) → Auth → Main Shell
- AuthService (ChangeNotifier, global) owns sign-in state; UserModel.canGenerate gates free vs premium access
- LoopService handles all loop generation and in-memory storage; replace generateLoop() body for real AI API
- Export sheet (ExportSheet) and player sheet (LoopPlayerSheet) are shared widgets used from both browser and generator
- Privacy policy is fully in-app at /privacy — no external URL required for store submission

## Conventions
- All widgets/common/ widgets receive data via constructor params, never access providers directly
- Screen-specific widgets live in widgets/generator/, widgets/browser/, widgets/auth/
- Auth widgets (AuthSocialButton, AuthForm) follow the same glassmorphic pattern as all other glass widgets
- Glass cards use BackdropFilter + semi-transparent containers for glassmorphism; never use solid colors on cards
- Neon accent colors used semantically: cyan = primary actions, purple = premium/secondary, green = success/tertiary

## Key Patterns & Gotchas
- SplashScreen reads AuthService to decide: isSignedIn → /generate, else → /onboarding (skippable)
- Waveform painters use seeded Random(loop.id.hashCode) for deterministic shapes — never use a global seed
- Free tier limit (10/day) is enforced via UserModel.canGenerate; dailyGenerationsUsed resets by checking today's date
- AuthService subscribes to FirebaseAuth.authStateChanges() in constructor — sign-in state is automatically restored on app relaunch; never call notifyListeners() directly after sign-in, the stream handles it
- Apple Sign-In uses FirebaseAuth signInWithProvider(AppleAuthProvider()) — no sign_in_with_apple package needed; works on both iOS and Android (web flow on Android)
- iOS still needs GoogleService-Info.plist dropped in — without it Google Sign-In will work on Android but fail on iOS
- Stripe integration: add a /subscribe route with a WebView pointing to your Stripe Checkout session URL; server-side webhook calls AuthService.setPremium(true) which also writes to Firestore

## Design System
- Dark glassmorphic aesthetic inspired by modern DAWs (Ableton, FL Studio dark modes) — near-black backgrounds with translucent layered cards
- Neon cyan (#00E5FF) primary, purple (#BF5AF2) secondary, green (#30D158) tertiary — high contrast on dark, music production convention
- Inter font family throughout — neutral, highly legible, professional without being sterile
- 8px base spacing grid; glass cards use 16px internal padding with 16px outer radius; glow shadows on interactive elements
