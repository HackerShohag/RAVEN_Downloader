# RAVEN Downloader

**Professional video downloader for Ubuntu Touch** — Powered by yt-dlp with native QML interface and Python backend.

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/raven.downloader.shohag)
[![Build and publish to OpenStore](https://github.com/HackerShohag/RAVEN_Downloader/actions/workflows/openstore-monthly.yml/badge.svg)](https://github.com/HackerShohag/RAVEN_Downloader/actions/workflows/openstore-monthly.yml) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE) [![Version](https://img.shields.io/badge/version-2.0.0-green.svg)](manifest.json.in)

---

## Features

### Core Capabilities
- **12 Platform Support** — YouTube, Vimeo, Dailymotion, Twitch, Facebook, Instagram, Twitter/X, TikTok, SoundCloud, Reddit, Bilibili with intelligent URL validation
- **Granular Format Control** — Independent video resolution and audio bitrate selection
- **Smart Playlist Handling** — Batch downloads with per-video format customization (platform-dependent)
- **Pull-to-Refresh History** — Swipe down on download history to reload entries from storage
- **One-Tap History Clear** — Clear all download history with automatic UI refresh via signal-based architecture
- **Native ContentHub** — Seamless file export to any Ubuntu Touch app
- **Subtitle Engine** — Download, auto-caption, and embed subtitles in multiple languages
- **Entry-Based Storage** — Persistent history with dedicated directories and thumbnail caching
- **Adaptive Theming** — Ambiance and Suru Dark theme support

### Supported Platforms

| Platform | Video Downloads | Playlist Support |
|----------|----------------|------------------|
| **YouTube** | ✅ | ✅ Playlists |
| **Vimeo** | ✅ | ✅ Albums, Channels, Groups |
| **Dailymotion** | ✅ | ✅ Playlists |
| **Twitch** | ✅ | ✅ Collections |
| **Facebook** | ✅ | ✅ Series |
| **Instagram** | ✅ | ⚠️ Limited |
| **Twitter/X** | ✅ | ❌ |
| **TikTok** | ✅ | ✅ User Profiles |
| **SoundCloud** | ✅ | ✅ Playlists, Albums |
| **Reddit** | ✅ | ✅ Subreddit Feeds |
| **Bilibili** | ✅ | ✅ Playlists, Series |

> **Note:** Powered by yt-dlp's 1800+ extractors. The app validates URLs and provides platform-specific guidance for unsupported features.

---

## Quick Start

### Installation

```bash
# From OpenStore (Recommended)
[Get RAVEN Downloader from OpenStore](https://open-store.io/app/raven.downloader.shohag)

# Manual Build
clickable build
clickable install

# Desktop Testing
clickable desktop --no-nvidia
```

### Usage Examples

**Single Video Download**
1. Paste URL (e.g., `https://youtube.com/watch?v=VIDEO_ID`)
2. Submit → Select video quality and audio bitrate
3. Download → Export via ContentHub

**Playlist Download** (YouTube, Vimeo, Dailymotion, etc.)
1. Set type to "Playlist"
2. Paste playlist URL (e.g., `https://youtube.com/playlist?list=PLAYLIST_ID`)
3. Submit → Select formats for each video
4. Batch download with individual format control

**Advanced Settings** (Bottom-edge swipe)
- Enable subtitle downloads (embedded or separate)
- Toggle auto-captions
- Switch themes (Ambiance/Suru Dark)
- Clear download history (automatic UI refresh)

**History Management**
- Pull down on the download list to refresh from storage
- Swipe up from bottom edge → Settings → Clear All History (one-tap with automatic reload)

---

## Recent Updates

### Version 2.0.0 — December 2025

#### Major Enhancements
- **Pull-to-Refresh** — Swipe down on download history to reload entries from storage (6 grid unit threshold with debouncing)
- **Signal-Based History Clear** — One-tap history clearing with automatic UI refresh via PyOtherSide signals
- **Entry-Based Storage** — Dedicated directories per download with reliable persistence
- **Component Architecture** — 7 reusable QML components (ThumbnailImage, DownloadButton, CustomLabel, SectionLabel, etc.)
- **Code Optimization** — Reduced codebase by ~220 lines while adding features, cleaned debug logging
- **Python Type Hints** — Full type annotations for better IDE support and code clarity
- **Common Options Pattern** — Extracted duplicate yt-dlp configurations into `_get_common_ydl_opts()`

#### Bug Fixes
- **ContentHub Integration** — Resolved app restart issues during file export
- **Thumbnail Loading** — Fixed initial load bug in saved entries (Component.onCompleted)
- **Playlist Validation** — Enhanced platform-specific error messages

#### Code Quality
- **Minimal Debug Logging** — Removed verbose operational logs, kept only errors and critical state changes
- **PEP 8 Compliance** — All Python files follow style guidelines
- **Modular QML** — Extracted MainPageDialogs, MediaItem optimizations
- **Type Safety** — Type hints in url_validator, format_parser, download_manager
- **PyOtherSide Signals** — Event-driven architecture for cross-component communication

---

## Architecture

### Technology Stack
```
┌─────────────────────────────────────┐
│  QML UI (Lomiri Components 1.3)    │  ← User Interface
├─────────────────────────────────────┤
│  PyOtherSide Bridge                 │  ← QML ↔ Python IPC
├─────────────────────────────────────┤
│  Python Backend (Type-Annotated)    │
│  ├─ download_manager.py             │  ← yt-dlp orchestration, threading
│  ├─ format_parser.py                │  ← Metadata extraction, formatting
│  ├─ url_validator.py                │  ← 12-platform URL validation
│  └─ storage_manager.py              │  ← Entry-based persistence, caching
├─────────────────────────────────────┤
│  yt-dlp (Embedded)                  │  ← 1800+ site extractors
│  ffmpeg (Embedded)                  │  ← Media processing
└─────────────────────────────────────┘
```

### Component Hierarchy
```
qml/
├── MainPage.qml              (496 lines) — Main UI, URL submission, pull-to-refresh
├── SettingsPage.qml          — Configuration, theme selection, history clearing
├── ExportPage.qml            — ContentHub file export
├── AboutPage.qml             (140 lines) — Credits, optimized with components
└── Components/
    ├── DownloadItemManager.qml — History management with reload support
    ├── MediaItem.qml         (298 lines) — Download list item, optimized
    ├── ThumbnailImage.qml    — Smart thumbnail loader with caching
    ├── DownloadButton.qml    — Download orchestration with polling
    ├── MainPageDialogs.qml   — Error/warning dialog collection
    ├── CustomLabel.qml       — Reusable link labels
    ├── SectionLabel.qml      — Consistent section headers
    ├── ContentHubDialog.qml  — File export dialog
    ├── LoadingOverlay.qml    — Busy indicator overlay
    ├── CustomBottomEdge.qml  — Settings drawer
    └── Custom*.qml           — UI widgets (ComboPopup, ProgressBar, etc.)
```

---

## Storage Architecture

### Directory Structure
```
~/.config/raven.downloader.shohag/
├── index.json                     # Entry summaries (fast loading)
├── settings.json                  # User preferences, theme
└── entries/                       # Per-download directories
    └── entry_<timestamp>_<rand>/
        ├── metadata.json          # Full download metadata
        └── thumbnail.jpg          # Cached thumbnail

~/.cache/raven.downloader.shohag/
└── downloads/                     # Temporary download storage
    └── [video_files]              # Exported via ContentHub
```

### Data Flow
1. **URL Submit** → Validate → Extract metadata → Cache thumbnail in entry dir
2. **Download** → Temp cache → Progress tracking → ContentHub export
3. **History Load** → Read index.json → Lazy-load full metadata on demand
4. **Pull-to-Refresh** → Flickable contentY detection → Clear model → Reload from storage
5. **History Clear** → Python clears storage → PyOtherSide signal → QML reloads UI automatically

---

## Building

### Prerequisites
- **Clickable** 8.0+ ([Installation Guide](https://clickable-ut.dev/en/latest/install.html))
- **Docker** or **LXD** (container runtime)
- **Ubuntu Touch device** or emulator (testing)

### Build Commands
```bash
# Clean build (recommended for dependency updates)
clickable clean && clickable build

# Architecture-specific build
clickable build --arch arm64    # For ARM devices
clickable build --arch amd64    # For x86_64

# Desktop testing (requires yt-dlp installed locally)
clickable desktop --no-nvidia

# View build logs
clickable logs

# Install on connected device
clickable install
```

### Embedded Dependencies
Dependencies are bundled during build process:
- **yt-dlp** → `lib/python3/dist-packages/` (Python package)
- **ffmpeg** → `lib/<target-triplet>/bin/ffmpeg` (binary for media processing)

To update yt-dlp:
```bash
# Update lib/python3/dist-packages/ with latest yt-dlp
pip install --target lib/python3/dist-packages yt-dlp --upgrade
```

### Automated OpenStore Releases

GitHub Actions builds arm64, amd64, and armhf packages and publishes them to
OpenStore on the first day of every month at 04:23 UTC. The build installs the
latest stable `yt-dlp` release at build time and records the embedded version in
the workflow artifact.

Before enabling the workflow, add the OpenStore API key as the
`OPENSTORE_API_KEY` GitHub Actions secret (repository-level or in the
`openstore` environment). The key is available from the OpenStore account
settings. A release tag beginning with `v` also publishes all architectures.
You can run the workflow manually from the Actions tab; manual runs build only
unless **Publish the built packages to OpenStore** is selected.

---

## URL Format Examples

| Platform | Single Video | Playlist |
|----------|-------------|----------|
| **YouTube** | `youtube.com/watch?v=VIDEO_ID` | `youtube.com/playlist?list=PLAYLIST_ID` |
| **Vimeo** | `vimeo.com/VIDEO_ID` | `vimeo.com/album/ALBUM_ID` |
| **Dailymotion** | `dailymotion.com/video/VIDEO_ID` | `dailymotion.com/playlist/PLAYLIST_ID` |
| **Twitch** | `twitch.tv/videos/VIDEO_ID` | `twitch.tv/collections/COLLECTION_ID` |
| **Facebook** | `facebook.com/watch/?v=VIDEO_ID` | `facebook.com/watch/[series]` |
| **Instagram** | `instagram.com/p/POST_ID/` | `instagram.com/explore/tags/TAG/` (limited) |
| **Twitter/X** | `twitter.com/user/status/TWEET_ID` | ❌ Not supported |
| **TikTok** | `tiktok.com/@user/video/VIDEO_ID` | `tiktok.com/@username` (user profile) |
| **SoundCloud** | `soundcloud.com/artist/track` | `soundcloud.com/artist/sets/PLAYLIST` |
| **Reddit** | `reddit.com/r/sub/comments/POST_ID/` | `reddit.com/r/subreddit/top` |
| **Bilibili** | `bilibili.com/video/BV_ID` | `bilibili.com/medialist/PLAYLIST_ID` |

> **Auto-Detection:** The app validates URLs and shows platform-specific error messages for unsupported features.

---

## Development

### Project Structure
```
raven.downloader/
├── qml/                    # QML UI files
│   ├── MainPage.qml
│   ├── SettingsPage.qml
│   ├── ExportPage.qml
│   ├── AboutPage.qml
│   └── Components/        # Reusable components
├── src/                    # Python backend
│   ├── __init__.py
│   ├── download_manager.py
│   ├── format_parser.py
│   ├── url_validator.py
│   └── storage_manager.py
├── assets/                 # Images, icons
├── lib/                    # Embedded Python packages
│   └── python3/dist-packages/yt_dlp/
├── lib/<target-triplet>/bin/ # Embedded target binaries
│   └── ffmpeg
├── clickable.yaml          # Build configuration
├── manifest.json.in        # App metadata
└── README.md
```

### Adding Features
1. **Python Module** — Add to `src/`, import in `download_manager.py`
2. **QML Component** — Create in `qml/Components/`, import in parent files
3. **Platform Support** — Add pattern to `PLATFORM_PATTERNS` in `url_validator.py`

### Code Standards
- **Python**: PEP 8, type hints, docstrings
- **QML**: Lomiri Components 1.3, component-based design
- **Commits**: Atomic, descriptive messages

### Testing
```bash
# Python syntax check
python3 -m py_compile src/*.py

# QML validation (via clickable build)
clickable build

# Desktop run with full logs
clickable desktop --no-nvidia 2>&1 | tee app.log
```

---

## Troubleshooting

### Build Issues
| Error | Solution |
|-------|----------|
| **yt-dlp not found** | `clickable clean && clickable build` |
| **Module import error** | Verify `lib/python3/dist-packages` contains yt-dlp |
| **ffmpeg missing** | Check `lib/aarch64-linux-gnu/bin/ffmpeg` (or the matching target triplet) exists |
| **CMake warnings** | Safe to ignore deprecation warnings (compatibility) |

### Runtime Issues
| Problem | Diagnosis | Fix |
|---------|-----------|-----|
| **Progress stuck** | `clickable logs \| grep download` | Check network, try different format |
| **Playlist invalid** | Check [URL examples](#url-format-examples) | Ensure URL matches platform's playlist pattern |
| **Platform not supported** | Review [Supported Platforms](#supported-platforms) | Submit feature request with example URLs |
| **Thumbnails not loading** | Check `~/.config/raven.downloader.shohag/entries/` | Clear cache, re-download |
| **ContentHub fails** | Check AppArmor policy | Verify `content_exchange` permission |

### Debug Mode
Enable verbose logging:
```bash
# Terminal logs
clickable logs --follow

# Python debug output
# Edit src/download_manager.py, set ydl_opts['quiet'] = False
```

---

## Security

### AppArmor Policy
The app requires the following permissions (see `raven.downloader.apparmor`):
- **networking** — Download videos from internet
- **audio** — Audio playback (if implemented)
- **video** — Video preview (if implemented)
- **content_exchange** — Import URLs from other apps
- **content_exchange_source** — Export downloaded files to other apps

### Privacy
- **No tracking** — No analytics, telemetry, or user data collection
- **Local storage** — All data stored in user's config directory
- **No external APIs** — Direct connection to video platforms via yt-dlp

---

## Contributing

We welcome contributions! Follow these steps:

### Workflow
1. **Fork** the repository
2. **Create** feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** changes (`git commit -m 'Add amazing feature'`)
4. **Test** on Ubuntu Touch device/emulator
5. **Push** to branch (`git push origin feature/amazing-feature`)
6. **Submit** pull request

### Standards
- **Python**: PEP 8 style, type hints, docstrings
- **QML**: Lomiri Components 1.3, component-based design, clear property names
- **Commits**: Atomic, descriptive messages (e.g., "Fix thumbnail loading in saved entries")
- **Testing**: Verify on real device before submitting

### Areas for Contribution
- [ ] Add more platform support (e.g., Rumble, Odysee)
- [ ] Implement download queue with priority
- [ ] Add video preview in-app
- [ ] Improve error messages with recovery suggestions
- [ ] Add download scheduling
- [ ] Optimize thumbnail caching strategy

---

## License

**GNU General Public License v3.0**

Copyright (C) 2025 Abdullah AL Shohag

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the [GNU General Public License](LICENSE) for more details.

---

## Links & Resources

### Project
- **Repository**: [github.com/HackerShohag/RAVEN_Downloader](https://github.com/HackerShohag/RAVEN_Downloader)
- **OpenStore**: [open-store.io/app/raven.downloader.shohag](https://open-store.io/app/raven.downloader.shohag)
- **Issues**: [github.com/HackerShohag/RAVEN_Downloader/issues](https://github.com/HackerShohag/RAVEN_Downloader/issues)

### Contact
- **Developer**: Abdullah AL Shohag
- **Email**: [HackerShohag@outlook.com](mailto:HackerShohag@outlook.com)
- **Platform**: Ubuntu Touch (Lomiri)

### Technologies
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — Video extraction engine (1800+ sites)
- [PyOtherSide](https://github.com/thp/pyotherside) — QML ↔ Python bridge
- [Ubuntu Touch](https://ubuntu-touch.io/) — Mobile Linux platform
- [Lomiri UI Toolkit](https://gitlab.com/ubports/development/core/lomiri-ui-toolkit) — QML components
- [Clickable](https://clickable-ut.dev/) — Ubuntu Touch build tool

---

<div align="center">

**⭐ Star this project if you find it useful!**

*Built with ❤️ for the Ubuntu Touch community*

</div>

---

*Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) • [PyOtherSide](https://github.com/thp/pyotherside) • [Ubuntu Touch](https://ubuntu-touch.io/)*
