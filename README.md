# RAVEN Downloader
[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/raven.downloader.shohag)

A YouTube video downloader for Ubuntu Touch with support for single videos and playlists. Built with Qt/QML framework and features embedded Python runtime for enhanced performance.

## Features

- Download individual videos and complete playlists
- Multiple quality/format selection (video, audio, combined)
- Embedded Python runtime with yt-dlp API integration
- Automatic fallback to binary execution mode
- Download progress tracking
- Download history management
- Dark/Light theme support

## Requirements

**Runtime Dependencies:**

- Ubuntu Touch 20.04 (Focal)
- Qt 5.12+
- ffmpeg (for format merging)
- Python 3.8+ (bundled in Click package)
- yt-dlp (bundled)

**Build Dependencies:**

- Clickable SDK
- CMake 3.16+
- Qt5 development packages
- Python 3.8 development headers

## Architecture

The application operates in two modes:

1. **Python API Mode** (Primary): Uses embedded Python interpreter to call yt-dlp directly as a library for better performance and error handling.

2. **QProcess Mode** (Fallback): Executes yt-dlp binary as subprocess when Python initialization fails.

## Installation

Install from [OpenStore](https://open-store.io/app/raven.downloader.shohag) or build from source:

```bash
clickable build
clickable install
```

## Configuration

**Download Location:** Default is `~/.local/share/raven.downloader.shohag`  
Can be changed in Settings page (needs testing).

**Python Bundle:** Automatically deployed in Click packages.
For development builds, run `./setup_python_bundle.sh` to create the bundle.

## Screenshots

Download Page             |  Settings Page
:-------------------------:|:-------------------------:
![Playlist Download Page](https://user-images.githubusercontent.com/47150885/226753975-bbebf3b5-954c-4559-930b-64a08b04afc4.png) | ![Settings Page](https://user-images.githubusercontent.com/47150885/226754242-5008069e-ac7c-4e1e-8c0e-fba715de5ded.png)



## License

Copyright (C) 2022  Abdullah AL Shohag

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3, as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
