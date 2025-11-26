# RAVEN Downloader

A professional YouTube and video platform downloader application built specifically for Ubuntu Touch, featuring a modern QML interface with Python-powered download capabilities.

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/raven.downloader.shohag)

## Overview

RAVEN Downloader is a native Ubuntu Touch application that enables users to download videos and audio from YouTube and other supported platforms. The application provides granular control over format selection, quality preferences, and includes advanced features such as subtitle embedding and playlist batch downloading.

## Features

### Core Functionality
- **Multi-Platform Support** - Download from YouTube, Vimeo, Dailymotion, and other yt-dlp supported platforms
- **Granular Format Selection** - Independent selection of video quality and audio bitrate
- **Playlist Processing** - Batch download entire playlists with format extraction
- **Real-Time Progress Tracking** - Live download progress updates with threaded operations
- **Subtitle Management** - Download, auto-caption, and embed subtitles in video files

### User Experience
- **Native Lomiri UI** - Fully integrated with Ubuntu Touch design language
- **Content Hub Integration** - System-level file sharing and export capabilities
- **Persistent History** - Download history with XDG-compliant configuration storage
- **Theme Support** - Multiple theme options (Ambiance, Suru Dark)
- **Responsive Layout** - Adaptive interface supporting various screen sizes

## Architecture

### Technology Stack

**Frontend Layer:**
- QML (QtQuick 2.7) - Declarative UI framework
- Lomiri Components 1.3 - Native Ubuntu Touch widgets
- Qt.labs.settings - Application settings persistence

**Bridge Layer:**
- PyOtherSide 1.4+ - QML-Python integration bridge enabling asynchronous Python calls from QML

**Backend Layer:**
- Python 3.8+ - Core business logic runtime
- yt-dlp - Video extraction library (embedded, not system-installed)
- Threading - Asynchronous download operations

### Module Organization

```
Backend Modules (src/):
├── download_manager.py    # Core download orchestration, yt-dlp integration
├── format_parser.py       # Video/audio format parsing and metadata extraction
├── url_validator.py       # URL validation with platform detection
└── storage_manager.py     # XDG-compliant persistent storage

Frontend Components (qml/):
├── MainPage.qml           # Primary UI, PyOtherSide integration
├── SettingsPage.qml       # User preferences and configuration
├── ExportPage.qml         # Content Hub export integration
└── Components/            # Reusable UI components
    ├── MediaItem.qml      # Download item representation
    ├── CustomProgressBar.qml
    ├── CustomBottomEdge.qml
    └── WarningDialog.qml
```

### Data Flow

```
User Input (QML) → PyOtherSide Bridge → Python Functions → yt-dlp API
                                                                ↓
Download Progress ← PyOtherSide Events ← Threading ← Progress Hooks
```

## Building from Source

### Prerequisites

| Component | Version | Purpose |
|-----------|---------|---------|
| Clickable | 8.0.0+ | Ubuntu Touch build orchestration |
| Docker/LXD | Latest | Containerized build environment |
| Python 3 | 3.8+ | Runtime dependency (target device) |

### Build Process

```bash
# Clean previous builds
clickable clean --arch all

# Build click package
clickable build --arch all

# Install on connected device
clickable install --arch all

# Run on desktop (testing)
clickable desktop
```

*NB: `clickable install --arch arm64` will fail due to the python3 installation dependency.*

### Build System Details

The project uses CMake with custom Clickable integration:

1. **CMake Configuration** - Handles file installation, translations, versioning
2. **Clickable Postbuild** - Embeds yt-dlp into `lib/python3/dist-packages/`
3. **Click Package** - Self-contained package with all Python dependencies

**Important:** yt-dlp is embedded during build via pip in the postbuild script. The application does NOT require or use system-installed yt-dlp.

## Dependencies

### Runtime (Device)
- **python3-minimal** - Python interpreter
- **python3-dev** - Development headers and build tools required for compiling Python C extensions
- **python3-setuptools** - Python package utilities
- **PyOtherSide 1.4+** - QML-Python bridge (provided by Ubuntu Touch)
- **Lomiri Components** - UI framework (provided by Ubuntu Touch)

### Build (Development)
- **clickable** >= 8.0.0
- **cmake** >= 3.0.0
- **python3-pip** - For embedding yt-dlp
- **intltool** - Translation support

### Embedded Libraries
- **yt-dlp** - Latest version, installed to `lib/python3/dist-packages/` during build

## Development

### Directory Structure

```
raven.downloader/
├── clickable.yaml          # Build configuration and postbuild script
├── CMakeLists.txt          # CMake build definitions
├── manifest.json.in        # Click package manifest template
├── raven.downloader.apparmor # Security policy definitions
├── src/                    # Python backend modules
├── qml/                    # QML frontend code
├── assets/                 # Images, icons, resources
├── po/                     # Translation files
└── build/                  # Build artifacts (generated)
```

### Debugging

```bash
# Real-time log monitoring
clickable logs --arch all

# Python-specific errors
clickable logs --arch all | grep -A 5 "Traceback"

# PyOtherSide bridge debugging
clickable logs --arch all | grep "pyotherside"

# Access build container
clickable shell
```

### Adding Python Dependencies

Edit `clickable.yaml` postbuild section:
```yaml
postbuild: |
  pip3 install --target="$TARGET_DIR/lib/python3/dist-packages" your-package
```

## Usage Guide

### Basic Video Download

1. Launch application
2. Enter video URL in text field
3. Select "single video" from dropdown
4. Click **Submit** to extract available formats
5. Choose desired video quality and audio format
6. Click **Download** on the media item
7. Monitor progress bar for download status

### Playlist Download

1. Enter YouTube playlist URL (must contain `list=` parameter)
2. Select "playlist" from dropdown
3. Click **Submit**
4. Application extracts all videos in playlist
5. Select formats for each video individually
6. Downloads proceed asynchronously

### Exporting Downloads

1. Upon completion, export dialog appears automatically
2. Select target application (File Manager, Documents, etc.)
3. File transfers via Content Hub

### Settings Configuration

Access via bottom-edge swipe:
- **Subtitle Options** - Auto-download and embedding preferences
- **Auto Download** - Skip format selection (use best quality)
- **Theme Selection** - UI theme customization
- **Clear History** - Remove all download records

## Configuration Files

The application uses XDG-compliant storage:

```
~/.config/raven.downloader.shohag/
├── history.json    # Download history
└── settings.json   # User preferences
```

Storage location respects `$XDG_CONFIG_HOME` environment variable.

## Security

### AppArmor Confinement

The application operates under Ubuntu Touch's AppArmor security framework with the following policy groups:

- `networking` - Internet access for video downloads
- `audio` - Audio format processing
- `video` - Video format processing  
- `content_exchange` - File import capabilities
- `content_exchange_source` - File export via Content Hub

Policy version: 20.04

## Troubleshooting

### yt-dlp Import Errors

**Symptom:** `yt-dlp not installed` error in logs

**Solution:**
```bash
clickable clean --arch all
clickable build --arch all
# Ensures postbuild script re-embeds yt-dlp
```

### PyOtherSide Module Not Found

**Symptom:** `module 'download_manager' not found`

**Cause:** Python path misconfiguration

**Solution:** Check `download_manager.py` sys.path modifications. Verify `lib/python3/dist-packages` exists in build output.

### Download Progress Not Updating

**Symptom:** Progress bar remains at 0%

**Diagnosis:**
```bash
clickable logs --arch all | grep -E "(progress|download)"
```

**Common Causes:**
- Network connectivity issues
- Invalid format selection
- Threading errors in progress hooks

### Playlist Detection Issues

**Symptom:** "Invalid playlist URL" error for valid playlists

**Solution:** Ensure URL contains `list=` parameter. Direct playlist page URLs (e.g., `/playlist?list=...`) are supported.

## Contributing

We welcome contributions that enhance functionality, improve code quality, or expand platform support.

### Contribution Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/enhancement-name`)
3. **Implement** changes with appropriate comments
4. **Test** on Ubuntu Touch device (emulator or physical)
5. **Commit** with descriptive messages
6. **Submit** pull request with detailed description

### Code Standards

- **Python:** PEP 8 compliance, docstrings for public functions
- **QML:** Consistent indentation, component documentation
- **Commits:** Clear, atomic commits with meaningful messages

### Testing Requirements

- Verify basic single video download
- Test playlist functionality
- Confirm subtitle/caption options work
- Validate Content Hub export
- Check log output for errors

## License

**GNU General Public License v3.0**

Copyright (C) 2025 Abdullah AL Shohag

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

## Acknowledgments

### Third-Party Software

- **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** - Powerful video extraction library
- **[PyOtherSide](https://github.com/thp/pyotherside)** - QML-Python integration bridge
- **[Ubuntu Touch](https://ubuntu-touch.io/)** - Mobile Linux platform

### Maintainer

Abdullah AL Shohag - [HackerShohag@outlook.com](mailto:HackerShohag@outlook.com)

---

**Repository:** [HackerShohag/RAVEN_Downloader](https://github.com/HackerShohag/RAVEN_Downloader)  
**Platform:** Ubuntu Touch (Lomiri)  
**Language:** Python 3 + QML
