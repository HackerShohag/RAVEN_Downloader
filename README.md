# RAVEN Downloader
[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/raven.downloader.shohag)

A simple youtube video downloader that can download entire playlist. This is Ubuntu Touch application based on qt framework.

### Requirements:
        ffmpeg
        yt-dlp

It uses the the `yt-dlp` binary release from [yt-dlp official repo](https://github.com/yt-dlp/yt-dlp/releases) named `yt-dlp_linux` (`yt-dlp_linux_aarch64` for arm64 and `yt-dlp_linux_armv7l` for arm).

### Needs testing:
        Theme Management (might have some bugs)
        Download Location (default is appData path: ~/.local/share/raven.downloader.shohag)

N.B.: Testing data or reporting bug would be appreciated. 

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
