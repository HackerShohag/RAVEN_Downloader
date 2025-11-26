# RAVEN Downloader

A Simple YouTube Batch Downloader for Ubuntu Touch

## ✨ Features

- 📹 Download videos from YouTube and other platforms
- 🎵 Separate audio and video format selection
- 📝 Subtitle and caption download support
- 📋 Playlist support
- 📊 Real-time download progress tracking
- 💾 Download history persistence
- 🎨 Native Ubuntu Touch UI

## 🏗️ Architecture

**Backend**: Python 3 with yt-dlp library  
**Frontend**: QML with Lomiri Components  
**Integration**: PyOtherSide bridge

### Migration from C++

This version has been migrated from C++ to Python backend. See [MIGRATION.md](MIGRATION.md) for details.

## 🚀 Building & Installation

### Prerequisites

- Clickable (Ubuntu Touch development tool)
- Docker or LXD for build container

### Build

```bash
clickable clean
clickable build
```

### Install on Device

```bash
clickable install
```

### Desktop Testing

```bash
clickable desktop
```

## 📦 Dependencies

### Runtime
- **Python 3.8+** - Core runtime
- **yt-dlp** - Embedded Python library (installed during build, NOT shell command)
- **PyOtherSide 1.4+** - QML-Python bridge

### Build
- clickable 8.0.0+
- python3-pip
- python3-setuptools
- python3-dev

**Note**: yt-dlp is embedded as a Python library in the click package. The app uses yt-dlp's Python API directly (function calls), not as a shell command. See [YT-DLP_INTEGRATION.md](YT-DLP_INTEGRATION.md) for details.

## 🔧 Development

### Project Structure

```
raven.downloader/
├── src/                    # Python backend
│   ├── download_manager.py # Main download logic
│   ├── format_parser.py    # Video format parsing
│   ├── url_validator.py    # URL validation
│   └── storage_manager.py  # History/settings storage
├── qml/                    # QML frontend
│   ├── Main.qml
│   ├── MainPage.qml
│   └── Components/
├── assets/                 # Images and resources
├── clickable.yaml          # Build configuration
└── MIGRATION.md           # Migration documentation
```

### Making Changes

1. Edit Python files in `src/`
2. Edit QML files in `qml/`
3. Reinstall: `clickable install`
4. Check logs: `clickable logs`

### Debugging

```bash
# Follow logs in real-time
clickable logs --follow

# Filter Python errors
clickable logs | grep python

# Shell into build container
clickable shell
```

## 📝 Usage

1. **Enter URL**: Paste YouTube video or playlist URL
2. **Select Type**: Choose "single video" or "playlist"
3. **Submit**: Click Submit to extract formats
4. **Choose Formats**: Select video quality and audio quality
5. **Download**: Click Download button
6. **Export**: Use content hub to share downloaded files

## 🐛 Troubleshooting

### "yt-dlp not installed"
```bash
clickable clean
clickable build
```

### Download fails
- Check network connection
- Verify URL is valid
- Check clickable logs for errors

### Progress not updating
- Restart app
- Check Python module loaded: `clickable logs | grep "module imported"`

## 📖 Documentation

- [MIGRATION.md](MIGRATION.md) - C++ to Python migration guide
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Implementation details

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on Ubuntu Touch device
5. Submit a pull request

## 📄 License

Copyright (C) 2025  Abdullah AL Shohag

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License version 3, as published by the
Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY
QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.

## 🙏 Credits

- **yt-dlp**: https://github.com/yt-dlp/yt-dlp
- **PyOtherSide**: https://github.com/thp/pyotherside
- **Ubuntu Touch**: https://ubuntu-touch.io/
