# Apple App Store — Privacy Nutrition Label

**App Name:** Rafça (Bundle ID: `com.kutluhangil.rafca`)
**Specification Authority:** `SPINE_BLUEPRINT.md` §5 & §445

This document defines the exact responses required in App Store Connect under **App Privacy**.

---

## 1. Data Used to Track You
**None.**
- Rafca does not display third-party advertisements.
- Rafca does not share any data with data brokers.
- Rafca does not use IDFA, Advertising Identifier, or any cross-app tracking SDK.

---

## 2. Data Linked to You
**None.**
- No account registration is required to use the app.
- All shelf captures, spine segments, library collections, and custom shelves are stored locally on the user's physical device.
- Optional cloud sync uses ephemeral cryptographic anonymous tokens governed by Row-Level Security.

---

## 3. Data Not Linked to You

### A. Diagnostics
- **Data Types:** Crash Data, Performance Data (Cold start duration, recognition latency).
- **Linked to Identity:** No.
- **Used for Tracking:** No.
- **Purposes:**
  - App Functionality (identifying non-fatal UI crashes and memory peaks).
  - Performance Optimization (verifying latency stays below the 8-second budget).

### B. User Content (Ephemeral Search Queries)
- **Data Types:** Search Terms / OCR Text (Book title and author string recognized from spine).
- **Linked to Identity:** No.
- **Used for Tracking:** No.
- **Storage:** Ephemeral query execution. Never persisted with user IP or profile.
- **Purposes:**
  - App Functionality (resolving physical book spines against the catalog database).

---

## 4. Photos and Camera Declarations
- **Camera Access (`NSCameraUsageDescription`):**
  - "Rafça uses the camera to scan physical book spines on your shelf and add them to your library. Photos are processed locally on your device and are never uploaded to the cloud."
- **Photo Library Access (`NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription`):**
  - "Rafça accesses your photos only to save your generated collection and shelf cards to your photo library."
