<div align="center">

# MOpenKey

**A lightweight, blazingly fast Vietnamese input method engine for macOS.**  
*Optimized for macOS 15 Sequoia, Sonoma, Ventura, and Apple Silicon.*

[![macOS CI](https://github.com/minhlu99/MOpenKey/actions/workflows/ci.yml/badge.svg)](https://github.com/minhlu99/MOpenKey/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/minhlu99/MOpenKey?color=2ea44f&logo=apple)](https://github.com/minhlu99/MOpenKey/releases)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/macOS-11.0%20to%2015%2B%20(Sequoia)-black?logo=apple)]()
[![Architecture](https://img.shields.io/badge/Arch-Universal%20(arm64%20%2B%20x86__64)-orange)]()
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline%20%7C%20Zero%20Telemetry-success)]()

[Download Latest Release](https://github.com/minhlu99/MOpenKey/releases/latest) • [Report Bug](https://github.com/minhlu99/MOpenKey/issues/new?template=bug_report.yml) • [Request Feature](https://github.com/minhlu99/MOpenKey/issues/new?template=feature_request.yml)

</div>

---

## 📖 Overview

**MOpenKey** is a modern open-source Vietnamese input method (Bộ gõ tiếng Việt) crafted specifically for macOS. 

While the built-in macOS Vietnamese input method often suffers from frustrating cursor jumping, unwanted text underlines in web browsers, and backspace timing bugs in Electron apps, **MOpenKey** provides a seamless, native, and customizable typing experience without interfering with your workflow.

MOpenKey is an actively maintained continuation and modernization of **OpenKey** (originally by Mai Vũ Tuyên), updated to meet modern macOS architecture standards.

---

## ⚡ Feature Comparison

| Feature | macOS Default IME | EVKey | Original OpenKey | **MOpenKey** |
| :--- | :---: | :---: | :---: | :---: |
| **Open Source (GPLv3)** | ❌ | ❌ | ✅ | **✅ (Active)** |
| **No Underline Bug in Browsers** | ❌ | ✅ | ✅ | **✅** |
| **Apple Silicon Native (arm64)** | ✅ | ✅ | ⚠️ Partial | **✅ Universal 2** |
| **macOS 15 Sequoia Resiliency** | ✅ | ⚠️ | ⚠️ | **✅ (Auto-recovering EventTap)** |
| **Modern macOS Startup (SMAppService)** | ✅ | ❌ | ❌ | **✅** |
| **Modern Browsers (Arc, Edge, Canary)** | ❌ | ⚠️ | ❌ | **✅ Verified** |
| **100% Offline / Zero Keylogging** | ✅ | ⚠️ Closed-source | ✅ | **✅ 100% Verifiable** |
| **Independent Settings & Bundle ID** | N/A | N/A | ❌ | **✅ (`com.minhlu.mopenkey`)** |

---

## ✨ Highlights & Modern Updates

* **🚀 Universal 2 Binary:** Native 64-bit performance for Apple Silicon (`arm64` - M1, M2, M3, M4) and Intel (`x86_64`) Macs.
* **🛡️ EventTap Auto-Recovery:** Eliminates the notorious typing freeze when macOS experiences high CPU load by capturing and auto-recovering from `kCGEventTapDisabledByTimeout`.
* **⚙️ Modern System Integration:**
  * Uses direct macOS Privacy & Security URL schemes instead of obsolete AppleScript prompts.
  * Replaces deprecated `SMLoginItemSetEnabled` with Apple's modern **`SMAppService`** (macOS 13+ standard).
  * Includes proper `NSInputMonitoringUsageDescription` for macOS Sequoia and Sonoma compliance.
* **🌐 Broad Browser & Editor Compatibility:** Tested and optimized for Chromium/Electron environments including **Google Chrome, Arc Browser, Microsoft Edge, Brave, VS Code, Sublime Text 4, Slack, and Discord**.
* **🔒 100% Privacy Focused:** No background network requests, no analytics, no keylogging.

---

## ⌨️ Supported Input Modes & Character Sets

### Kiểu gõ (Input Methods)
* **Telex** (Standard Vietnamese Telex)
* **VNI** (Number-based diacritics)
* **Simple Telex 1 & 2**

### Bảng mã (Character Sets)
* **Unicode** (Unicode dựng sẵn - Precomposed, standard for modern web and macOS)
* **Unicode Tổ hợp** (Unicode Compound - Decomposed)
* **TCVN3 (ABC)** (Legacy northern font standard)
* **VNI Windows** (Legacy southern font standard)
* **Vietnamese Locale CP 1258**

---

## 📥 Installation

### Method 1: Direct Download (Recommended)

1. Go to the [Releases](https://github.com/minhlu99/MOpenKey/releases) page.
2. Download the latest **`MOpenKey-macOS-Universal.dmg`** (or `.zip`).
3. Open the DMG and drag **MOpenKey.app** into your **Applications** folder.
4. Launch **MOpenKey** from Applications or Spotlight.

> [!NOTE]
> **First-time launch on macOS Sonoma & Sequoia:**  
> If macOS displays *"Apple cannot check it for malicious software"*:
> 1. Open **System Settings** > **Privacy & Security**.
> 2. Scroll to the **Security** section and click **Open Anyway**.

---

### Method 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/minhlu99/MOpenKey.git
cd MOpenKey

# Run the automated build and packaging pipeline
chmod +x scripts/build.sh
./scripts/build.sh
```

The compiled application, `.zip`, and `.dmg` will be generated in `dist/`.

---

## 🔒 Permissions Setup

To intercept and convert keystrokes into accented Vietnamese characters, macOS requires Accessibility permissions:

1. Open **System Settings** (`Cài đặt hệ thống`).
2. Navigate to **Privacy & Security** (`Quyền riêng tư & Bảo mật`) > **Accessibility** (`Trợ năng`).
3. Toggle the switch next to **MOpenKey** to **ON**.
4. *(Recommended)* Set your macOS built-in keyboard layout to **English (US)** to prevent keystroke collision with the default input engine.

---

## 🏗️ Project Architecture

```
MOpenKey/
├── Sources/
│   └── OpenKey/
│       ├── engine/               # Core C++ Vietnamese orthography & charset engine
│       │   ├── Engine.cpp        # Keystroke state machine & diacritic placement
│       │   ├── Vietnamese.cpp    # Vietnamese grammar rules & phonetic logic
│       │   ├── Macro.cpp         # Custom abbreviation expansion engine
│       │   └── ConvertTool.cpp   # Character set transcoding algorithms
│       └── macOS/                # Native macOS Cocoa & EventTap implementation
│           ├── ModernKey/        # Objective-C / Obj-C++ application wrapper
│           │   ├── OpenKey.mm    # CGEventTap keyboard interception & injection
│           │   ├── AppDelegate.m # Lifecycle & SMAppService launch management
│           │   └── ...
│           └── OpenKey.xcodeproj # Universal 2 Xcode Project
├── scripts/
│   └── build.sh                  # One-step compilation, code-signing & packaging
└── .github/
    └── workflows/                # Automated CI & Release pipelines
        ├── ci.yml                # Push / PR build validation
        └── release.yml           # Tagged release generation
```

---

## 🤝 Contributing

Contributions are warmly welcomed! Whether you want to fix a bug, improve documentation, or propose a feature:

1. Read our [Contributing Guidelines](CONTRIBUTING.md).
2. Familiarize yourself with our [Code of Conduct](CODE_OF_CONDUCT.md) and [Security Policy](SECURITY.md).
3. Submit a Pull Request following our [PR Template](.github/PULL_REQUEST_TEMPLATE.md).

---

## 📜 Attribution & Legal

* **Original Creator:** Mai Vũ Tuyên ([@tuyenvm](https://github.com/tuyenvm)) – creator of the original [OpenKey](https://github.com/tuyenvm/OpenKey) project.
* **MOpenKey Maintainer:** Minh Lu ([@minhlu99](https://github.com/minhlu99)) and community contributors.
* **License:** Licensed under the [GNU General Public License v3.0 (GPLv3)](LICENSE).
