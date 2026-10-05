# MOpenKey

[![macOS CI](https://github.com/minhlu99/MOpenKey/actions/workflows/ci.yml/badge.svg)](https://github.com/minhlu99/MOpenKey/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS%2011%2B%20(Big%20Sur%20--%20Sequoia)-lightgrey.svg)]()
[![Architecture](https://img.shields.io/badge/Architecture-Universal%20(Apple%20Silicon%20%2B%20Intel)-orange.svg)]()

> **MOpenKey** is a modern, lightweight, open-source Vietnamese input method (Bộ gõ tiếng Việt) for macOS.  
> It is an actively maintained continuation and modernization of **OpenKey**, optimized for modern macOS versions (macOS 13 Ventura, macOS 14 Sonoma, macOS 15 Sequoia) and Apple Silicon.

---

## 🌟 Highlights & Modern Updates

* **Native Universal Binary:** Full 64-bit native execution on Apple Silicon (`arm64` - M1/M2/M3/M4) and Intel (`x86_64`).
* **Independent Identity:** Distinct bundle identifier (`com.minhlu.mopenkey`) and Application Support directory (`~/Library/Application Support/MOpenKey`) to prevent conflicts with legacy OpenKey installations.
* **Modern macOS 14 & 15 Resiliency:**
  * **EventTap Auto-Recovery:** Recovers gracefully if macOS drops input hooks under system pressure (`kCGEventTapDisabledByTimeout`), preventing typing freeze.
  * **Modern System Settings Integration:** Uses current macOS Privacy & Security URL schemes instead of deprecated AppleScript targeting "System Preferences".
  * **Modern Startup Service:** Adopts Apple's modern `SMAppService` API (macOS 13+ standard) for reliable launch-on-login without helper crashes.
* **Typing Stability in Modern Apps:** Fixes cursor jump, underline issues, and double-character artifacts in Chromium/Electron applications (Chrome, VS Code, Slack, Discord).
* **100% Privacy Focused:** Operates entirely offline with zero keylogging, zero telemetry, and zero network data collection.

---

## ⌨️ Supported Input Methods & Charsets

### Kiểu gõ (Input Methods)
* **Telex**
* **VNI**
* **Simple Telex 1 & 2**

### Bảng mã (Character Sets)
* **Unicode** (Unicode dựng sẵn - Precomposed)
* **Unicode Tổ hợp** (Unicode Compound - Decomposed)
* **TCVN3 (ABC)**
* **VNI Windows**
* **Vietnamese Locale CP 1258**

---

## 🚀 Installation

### Option 1: Pre-built Release (Recommended)

1. Download `MOpenKey-macOS-Universal.dmg` (or `.zip`) from the [Releases](https://github.com/minhlu99/MOpenKey/releases) page.
2. Drag **MOpenKey.app** into your **Applications** folder.
3. Launch **MOpenKey** from Applications or Spotlight.

> **Note for macOS Gatekeeper:**  
> On macOS Sonoma and Sequoia, if you see a prompt saying *"Apple cannot verify this app"*:
> 1. Open **System Settings** > **Privacy & Security**.
> 2. Scroll down to the **Security** section and click **Open Anyway**.

### Option 2: Build from Source

```bash
git clone https://github.com/minhlu99/MOpenKey.git
cd MOpenKey
./scripts/build.sh
```

The compiled `MOpenKey.app` and packaging artifacts will be placed in the `dist/` directory.

---

## ⚙️ Accessibility Permissions Setup (Cấp quyền Trợ năng)

To convert keystrokes globally, macOS requires Accessibility permissions:

1. Open **System Settings** (`Cài đặt hệ thống`).
2. Navigate to **Privacy & Security** (`Quyền riêng tư & Bảo mật`) > **Accessibility** (`Trợ năng`).
3. Toggle the switch next to **MOpenKey** to **ON**.
4. *(Recommended)* Set your macOS built-in input source to English (US) to avoid duplicate input handler conflicts.

---

## 🏗️ Architecture & Codebase

* **Engine (`Sources/OpenKey/engine`):** Cross-platform C++ engine implementing Vietnamese orthography, grammar rules, macro processing, and charset conversions.
* **macOS UI & Hook Layer (`Sources/OpenKey/macOS`):** Objective-C / Objective-C++ bridging Cocoa UI, Menu Bar items, and CoreGraphics `CGEventTap` keyboard event processing.
* **CI/CD (`.github/workflows`):** Automated GitHub Actions testing builds on macOS runners, building Universal Binaries, and publishing releases.

---

## 🤝 Contributing

Contributions, bug reports, and suggestions are welcome! Please check our [Contributing Guidelines](CONTRIBUTING.md) and [Security Policy](SECURITY.md) before submitting a pull request.

---

## 📜 Attribution & Credits

* **Original Project:** [OpenKey](https://github.com/tuyenvm/OpenKey) by **Mai Vũ Tuyên ([@tuyenvm](https://github.com/tuyenvm))**.  
  We are immensely grateful to Mai Vũ Tuyên for creating the original open-source OpenKey engine and laying the foundation for open Vietnamese input method development on macOS.
* **MOpenKey Maintainer:** Minh Lu ([@minhlu99](https://github.com/minhlu99)) & macOS Community Contributors.

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**. See the [LICENSE](LICENSE) file for complete terms.
