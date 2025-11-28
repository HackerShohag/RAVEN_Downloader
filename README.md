# RAVEN Downloader

A professional video downloader for Ubuntu Touch with Python-powered backend and native QML interface.

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/raven.downloader.shohag)

## Features

- **Format Control** - Independent video quality and audio bitrate selection
- **Playlist Support** - Batch download with individual format control
- **ContentHub Integration** - Native file export to any app
- **Subtitle Management** - Download, auto-caption, and embedding
- **Persistent History** - Entry-based storage with thumbnail caching
- **Theme Support** - Ambiance and Suru Dark themes

## Quick Start

```bash
# Build and install
clickable build --arch all
clickable install --arch all

# Or install from OpenStore
# Search for "RAVEN Downloader"
```

## Recent Updates

### Version 2.0.0 - November 2025

- **Entry-Based Storage**: Dedicated directories for reliable persistence
- **ContentHub Fix**: Resolved app restart issues during file export
- **Code Quality**: PEP 8 compliant Python, generalized QML components
- **Thumbnail Caching**: Local storage for offline access
- **Component Library**: Reusable LoadingOverlay, DialogBase, SettingsCheckbox, ContentHubDialog

## Architecture

**Stack**: QML + PyOtherSide + Python 3 + yt-dlp (embedded)

```text
UI Layer (QML)
    ↕ PyOtherSide Bridge
Backend (Python)
    ├─ download_manager.py    # yt-dlp orchestration
    ├─ format_parser.py        # Metadata extraction
    ├─ url_validator.py        # URL validation
    └─ storage_manager.py      # Entry-based persistence
```

## Storage Structure

```text
~/.config/raven.downloader.shohag/
├── index.json              # Entry summaries
├── settings.json           # User preferences
└── entries/                # Per-download directories
    └── entry_<id>/
        ├── metadata.json
        └── thumbnail.jpg

~/.cache/raven.downloader.shohag/downloads/  # Temp storage
```

## Building

**Prerequisites**: Clickable 8.0+, Docker/LXD

```bash
# Clean build
clickable clean --arch all && clickable build --arch all

# Desktop testing
clickable desktop

# Logs
clickable logs --arch all
```

**Dependencies** (embedded during build):

- yt-dlp → `lib/python3/dist-packages/`
- ffmpeg → `bin/`

## Usage

1. **Single Video**: Paste URL → Submit → Select format → Download
2. **Playlist**: Set type to "playlist" → Submit → Select formats per video
3. **Export**: Automatic ContentHub dialog on completion
4. **Settings**: Bottom-edge swipe for subtitles, theme, auto-download

## Development

### Adding Python Dependencies

Edit `clickable.yaml`:

```yaml
postbuild: |
  pip3 install --target="$TARGET_DIR/lib/python3/dist-packages" package-name
```

### Component Structure

```text
qml/Components/
├── ContentHubDialog.qml    # File export dialog
├── LoadingOverlay.qml      # Reusable busy indicator
├── SettingsCheckbox.qml    # Settings UI pattern
├── DialogBase.qml          # Simple dialog wrapper
├── MediaItem.qml           # Download item
└── Custom*.qml             # UI widgets
```

## Troubleshooting

**yt-dlp not found**: `clickable clean --arch all && clickable build --arch all`

**Module import error**: Check `lib/python3/dist-packages` exists in build

**Progress stuck**: Check logs with `clickable logs --arch all | grep download`

**Playlist URL invalid**: Ensure URL contains `list=` parameter| grep download`  
**Playlist URL invalid**: Ensure URL contains `list=` parameter

## Security

AppArmor policy: `networking`, `audio`, `video`, `content_exchange`, `content_exchange_source`

## Contributing

1. Fork repository
2. Create feature branch
3. Test on Ubuntu Touch device/emulator
4. Submit pull request

**Standards**: PEP 8 (Python), clear QML documentation, atomic commits

## License

GNU GPL v3.0 - Copyright (C) 2025 Abdullah AL Shohag

## Links

- **Repository**: [github.com/HackerShohag/RAVEN_Downloader](https://github.com/HackerShohag/RAVEN_Downloader)
- **Contact**: [HackerShohag@outlook.com](mailto:HackerShohag@outlook.com)
- **Platform**: Ubuntu Touch (Lomiri)
- **Repository**: [github.com/HackerShohag/RAVEN_Downloader](https://github.com/HackerShohag/RAVEN_Downloader)
- **Contact**: HackerShohag@outlook.com
- **Platform**: Ubuntu Touch (Lomiri)

---

*Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) • [PyOtherSide](https://github.com/thp/pyotherside) • [Ubuntu Touch](https://ubuntu-touch.io/)*
