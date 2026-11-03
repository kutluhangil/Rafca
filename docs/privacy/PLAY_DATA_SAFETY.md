# Google Play Console — Data Safety Form Specification

**Application Name:** Rafça
**Package ID:** `com.kutluhangil.rafca`
**Target Audience:** General Audience (Age 4+)
**Specification Authority:** `SPINE_BLUEPRINT.md` §5 & §445

---

## 1. Data Collection & Sharing Overview

| Question | Answer | Details |
|---|---|---|
| Does your app collect or share any of the required user data types? | **Yes** | Diagnostics / Crash logs & Search query text only. |
| Is all of the user data collected by your app encrypted in transit? | **Yes** | All data in transit uses modern TLS 1.3 / HTTPS. |
| Do you provide a way for users to request that their data be deleted? | **Yes** | Settings → "Kütüphaneyi Sıfırla" (Reset Library) deletes all records instantly. |

---

## 2. Data Types Breakdown

### A. Location
- **Collected:** No
- **Shared:** No

### B. Personal Info (Name, Email, User IDs)
- **Collected:** No (Account-free local usage by default).
- **Shared:** No

### C. Financial Info
- **Collected:** No
- **Shared:** No

### D. Photos and Videos
- **Collected:** **No** (Photos taken by camera stay strictly within local sandbox storage: `ApplicationDocumentsDirectory/spine/captures/`).
- **Shared:** **No**

### E. Audio Files
- **Collected:** No
- **Shared:** No

### F. Files and Documents
- **Collected:** No
- **Shared:** No

### G. App Activity (Search History)
- **Data Type:** In-app Search History / OCR Text Query
- **Collected:** Yes (Ephemeral transmission to matching service)
- **Shared:** No
- **Ephemerally processed:** Yes
- **Required or Optional:** Required for core app functionality (book recognition)
- **Purpose:** App Functionality (Book matching)

### H. App Info and Performance
- **Data Type:** Crash logs & Diagnostics
- **Collected:** Yes (Anonymous stack traces via Telemetry)
- **Shared:** No
- **Ephemerally processed:** No
- **Required or Optional:** Optional / Diagnostic
- **Purpose:** Analytics & Bug Fixing

### I. Device or Other IDs
- **Collected:** No
- **Shared:** No

---

## 3. Privacy Policy URL
`https://rafca.app/privacy` (corresponds to `/docs/privacy/PRIVACY_POLICY.md`).
