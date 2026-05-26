# ⚡ Electricity Theft Inspection & Financial Calibration System (منظومة فحص وضبط سرقات التيار)

An enterprise-grade, field-ready Mobile Application built with **Flutter & Dart**, tailored specifically for electrical utility sectors (calibrated for **MEEDC / Middle Egypt Electricity Distribution Company** operational guidelines). This system digitizes the manual legal capturing of power grid violations, ensures multi-modal live evidence preservation, and automates real-time financial fine estimation via compliance-calibrated mathematical models.

---

## 🌟 Key Features

### 1. 📊 Precise Financial Calibration Engine
* Automatically computes legal penalties and consumption adjustments based on **dynamic grid tariffs** (Residential, Commercial, Agricultural, Services).
* Incorporates mathematical variables like **dispersion factors (معامل التشتت)** and customized accounting periods (frequently defaulted to 90 days).
* Scaled to match the company's official desktop benchmarking systems down to the exact decimal piaster.

### 2. 📸 Fault-Tolerant, Live Media Vault
* Mitigates aggressive Android OS state-rebuilds and memory trims by leveraging an **instant-cache-and-transfer file pipeline**.
* Captures and securely transfers live data (National ID Front/Back images and continuous live verification video recordings) immediately upon capture.
* Automatically segregates records into isolated directories named after the specific violator inside the shared `Download/` directory.

### 3. 📂 Automated Ledger Logging
* Operates a background parser that reads, writes, and appends inspection parameters cleanly to a localized central ledger file (`سجل_مخالفات_سرقات_2026.xlsx`).
* No heavy cloud databases required, ensuring **100% offline autonomy** for rural and low-connectivity remote tracking squads.

---

## 🛠️ System Architecture & Stack

* **Frontend Framework:** Flutter (Dart) - Declarative State Management
* **Hardware Interfacing:** `image_picker` customized configuration (80% compressed JPEG targeting fast disk I/O)
* **Local Parsing Engine:** `excel` library for localized binary spreadsheet manipulation
* **Platform Support:** Built exclusively to interface with Android scoped & public external storage permissions

---

## 📦 Production Deployment & Field Distribution

To generate a fully stable, release-optimized standalone production APK without unneeded icon assets or debugger hooks:

```bash
# Clean cached binaries
flutter clean

# Update and re-index package dependencies
flutter pub get

# Compile production-ready standalone Android release package
flutter build apk --release --no-tree-shake-icons