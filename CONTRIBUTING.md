# Contributing to OpenKey

Thank you for your interest in contributing to OpenKey! This project aims to maintain and modernize OpenKey as a lightweight, performant, and reliable Vietnamese input method for macOS.

## Code of Conduct

This project adheres to the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Started

### Prerequisites

* macOS 12.0 Monterey or later (compatible with macOS 13 Ventura, macOS 14 Sonoma, macOS 15 Sequoia).
* Xcode 15 or later with Command Line Tools (`xcode-select --install`).
* Git (`git --version`).

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/OpenKey.git
   cd OpenKey
   ```

2. Build using the automated packaging script:
   ```bash
   chmod +x scripts/build.sh
   ./scripts/build.sh
   ```

3. Alternatively, open the Xcode project:
   ```bash
   open Sources/OpenKey/macOS/OpenKey.xcodeproj
   ```
   Select the `OpenKey` scheme and press **Cmd + B** to build, or **Cmd + R** to run.

## Branching & Commit Guidelines

* `main`: Stable development branch.
* Feature branches: `feat/<feature-name>`, `fix/<bug-description>`.
* Use clear, conventional commit messages:
  * `feat: add support for ...`
  * `fix: prevent event tap timeout on macOS Sequoia`
  * `docs: update troubleshooting guide in README`

## Reporting Issues

* Use GitHub Issues and pick either the **Bug Report** or **Feature Request** template.
* Provide reproduction steps, your macOS version, and the affected applications (e.g. Chrome, VS Code, Slack).

## Submitting Pull Requests

1. Fork the repo and create your branch from `main`.
2. Ensure the project builds without errors (`./scripts/build.sh`).
3. Fill out the Pull Request template.
4. Squash commits if requested and adhere to the project's code style.
