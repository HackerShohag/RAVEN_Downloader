'''
 Copyright (C) 2025  Abdullah AL Shohag

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 raven.downloader is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import os
import random
import sys
import threading
import time
from pathlib import Path

current_dir = Path(__file__).parent.parent

lib_path = current_dir / "lib" / "python3" / "dist-packages"
if lib_path.exists():
    sys.path.insert(0, str(lib_path))
    print(f"[download_manager] Added lib path: {lib_path}")

ffmpeg_lib_path = current_dir / "lib"
if ffmpeg_lib_path.exists():
    ld_library_path = os.environ.get("LD_LIBRARY_PATH", "")
    if ld_library_path:
        os.environ["LD_LIBRARY_PATH"] = f"{ffmpeg_lib_path}{os.pathsep}{ld_library_path}"
    else:
        os.environ["LD_LIBRARY_PATH"] = str(ffmpeg_lib_path)
    print(f"[download_manager] Added ffmpeg lib path to LD_LIBRARY_PATH: {ffmpeg_lib_path}")

bin_path = current_dir / "bin"
if bin_path.exists():
    os.environ["PATH"] = str(bin_path) + os.pathsep + os.environ.get("PATH", "")
    print(f"[download_manager] Added bin path to PATH: {bin_path}")
    
    ffmpeg_location = bin_path / "ffmpeg"
    if ffmpeg_location.exists():
        print(f"[download_manager] Found embedded ffmpeg at: {ffmpeg_location}")
        os.environ["FFMPEG_BINARY"] = str(ffmpeg_location)
    else:
        print(f"[download_manager] WARNING: ffmpeg binary not found at {ffmpeg_location}")
else:
    print(f"[download_manager] WARNING: bin directory not found at {bin_path}")

try:
    import yt_dlp
    print(f"[download_manager] yt-dlp imported successfully, version: {yt_dlp.version.__version__}")
except ImportError as e:
    print(f"[download_manager] WARNING: yt-dlp not installed: {e}")
    yt_dlp = None
except Exception as e:
    print(f"[download_manager] ERROR importing yt-dlp: {e}")
    yt_dlp = None

try:
    from .format_parser import format_filesize, parse_playlist_info, parse_video_formats
    from .storage_manager import get_storage_manager, save_list_model_data, load_list_model_data
    from .url_validator import (is_valid_playlist_url, is_valid_url, is_valid_video_url, 
                                is_valid_playlist, supports_playlists, get_platform_name)
    print("[download_manager] Using relative imports")
except ImportError:
    from format_parser import format_filesize, parse_playlist_info, parse_video_formats
    from storage_manager import get_storage_manager, save_list_model_data, load_list_model_data
    from url_validator import (is_valid_playlist_url, is_valid_url, is_valid_video_url, 
                               is_valid_playlist, supports_playlists, get_platform_name)
    print("[download_manager] Using absolute imports")

class DownloadManager:
    """
    Orchestrates video downloads using yt-dlp library.
    
    Manages download lifecycle including format extraction, progress tracking,
    and post-processing. Implements singleton pattern for global access.
    """
    
    def __init__(self):
        """
        Initialize download manager with empty state.
        
        Sets up tracking structures for active downloads, progress throttling,
        and storage manager integration.
        """
        self.active_downloads = {}
        self.download_counter = 0
        self.storage = get_storage_manager()
        self.last_progress_time = {}
        self.progress_throttle = 0.1
    
    @staticmethod
    def _get_common_ydl_opts():
        """
        Generate shared yt-dlp configuration options.
        
        Returns:
            Dictionary containing common options for yt-dlp operations including
            quiet mode, SSL bypass, and user agent configuration
        """
        return {
            'quiet': True,
            'no_warnings': True,
            'nocheckcertificate': True,
            'legacy_server_connect': True,
            'user_agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'cookiesfrombrowser': None,
        }
    
    def action_submit(self, url, download_type=0):
        """
        Extract video or playlist metadata from URL.
        
        Validates URL, determines content type (video/playlist), and extracts
        format information using yt-dlp. Replaces C++ downloadManager.actionSubmit().
        
        Args:
            url: Video or playlist URL to process
            download_type: Content type selector (0=single video, 1=playlist)
            
        Returns:
            Dictionary containing extracted format data and metadata, or error information
            if extraction fails. Format: {'type': 'video'|'playlist', 'data': {...}} or
            {'error': 'error message'}
        """
        print(f"[action_submit] Called with URL: {url}, download_type: {download_type}")
        
        try:
            if not yt_dlp:
                error_msg = 'yt-dlp is not installed'
                print(f"[action_submit] ERROR: {error_msg}")
                return {'error': error_msg}
            
            print(f"[action_submit] Validating URL...")
            if not is_valid_url(url):
                error_msg = f'Invalid URL provided: {url}'
                print(f"[action_submit] ERROR: {error_msg}")
                return {'error': error_msg}
            
            print(f"[action_submit] URL is valid")
            
            is_playlist = is_valid_playlist_url(url)
            print(f"[action_submit] Is playlist: {is_playlist}")
            
            if download_type == 1 and not supports_playlists(url):
                platform = get_platform_name(url)
                error_msg = f'{platform} does not support playlist downloads'
                print(f"[action_submit] ERROR: {error_msg}")
                return {'error': error_msg}
            
            if is_playlist and download_type == 0:
                print(f"[action_submit] Playlist URL submitted as single video")
                return {'error': 'playlist_as_video', 'url': url}
            
            if download_type == 1 and not is_playlist:
                platform = get_platform_name(url)
                error_msg = f'This is not a valid playlist URL for {platform}'
                print(f"[action_submit] ERROR: {error_msg}")
                return {'error': error_msg}
            
            print(f"[action_submit] Extracting info from: {url}")
            
            ydl_opts = self._get_common_ydl_opts()
            ydl_opts['extract_flat'] = is_playlist
            
            print(f"[action_submit] Creating YoutubeDL instance...")
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                print(f"[action_submit] Calling extract_info...")
                info = ydl.extract_info(url, download=False)
                print(f"[action_submit] Info extracted - Title: {info.get('title', 'Unknown')}")
                
                if is_playlist:
                    print(f"[action_submit] Parsing playlist info...")
                    playlist_data = parse_playlist_info(info)
                    print(f"[action_submit] Returning playlist data")
                    return {'type': 'playlist', 'data': playlist_data}
                else:
                    print(f"[action_submit] Parsing video formats...")
                    formats_data = parse_video_formats(info)
                    print(f"[action_submit] Formats parsed: {len(formats_data.get('videoFormatIds', []))} video, {len(formats_data.get('audioFormatIds', []))} audio")
                    print(f"[action_submit] Returning formats data")
                    return {'type': 'video', 'data': formats_data}
                    
        except Exception as e:
            error_msg = str(e)
            print(f"[action_submit] EXCEPTION: {error_msg}")
            import traceback
            traceback.print_exc()
            return {'error': error_msg}
    
    def action_download(self, video_url, options):
        """
        Execute video download with specified format and options.
        
        Starts threaded download process with progress tracking and post-processing.
        Replaces C++ downloadManager.actionDownload().
        
        Args:
            video_url: Video URL to download
            options: Download configuration dictionary:
                - format: Combined format string (e.g., "137+140")
                - indexID: Download ID for progress tracking
                - downloadLocation: Custom download path (optional)
                - subtitle: Download subtitles flag (optional)
                - caption: Download captions flag (optional)
                - embedded: Embed subtitles flag (optional)
                
        Returns:
            Dictionary with success status and download_id for tracking:
            {'success': True, 'download_id': int} or {'success': False, 'error': str}
        """
        try:
            if not yt_dlp:
                error_msg = 'yt-dlp is not installed'
                print(f"[action_download] ERROR: {error_msg}")
                return {'success': False, 'error': error_msg}
            
            download_id = options.get('indexID', self.download_counter)
            if 'indexID' not in options:
                self.download_counter += 1
                download_id = self.download_counter
            
            format_selector = options.get('format', 'best')
            
            output_path = options.get('downloadLocation', self.storage.get_download_path())
            output_name = '%(title)s.%(ext)s'
            
            download_subtitles = options.get('subtitle', False)
            download_captions = options.get('caption', False)
            embed_subs = options.get('embedded', False)
            
            print(f"[action_download] Starting download {download_id} for {video_url}")
            print(f"[action_download] Format: {format_selector}, Path: {output_path}")
            
            self.last_progress_time[download_id] = {
                'progress': 0,
                'status': 'preparing',
                'timestamp': time.time()
            }
            
            def progress_hook(d):
                current_time = time.time()
                
                if d['status'] == 'downloading':
                    downloaded = d.get('downloaded_bytes', 0)
                    total = d.get('total_bytes', 0) or d.get('total_bytes_estimate', 0)
                    
                    if total > 0:
                        progress = (downloaded / total) * 100.0
                        self.last_progress_time[download_id] = {
                            'progress': progress,
                            'downloaded': downloaded,
                            'total': total,
                            'status': 'downloading',
                            'timestamp': current_time
                        }
                    
                elif d['status'] == 'finished':
                    filename = d.get('filename', 'Unknown')
                    print(f"[action_download] Stream downloaded: {filename}")
                    
                    self.last_progress_time[download_id] = {
                        'progress': 95.0,
                        'status': 'processing',
                        'filename': filename,
                        'timestamp': current_time
                    }
                
                elif d['status'] == 'error':
                    print(f"[action_download] Download {download_id} error")
                    self.last_progress_time[download_id] = {
                        'progress': 0,
                        'status': 'error',
                        'timestamp': current_time
                    }
            
            def postprocessor_hook(d):
                if d['status'] == 'finished':
                    filename = d.get('info_dict', {}).get('filepath', 'Unknown')
                    print(f"[action_download] Post-processing complete: {filename}")
                    
                    self.last_progress_time[download_id] = {
                        'progress': 100.0,
                        'status': 'finished',
                        'filename': filename,
                        'timestamp': time.time()
                    }
                    
                    self.storage.add_download_entry({
                        'url': video_url,
                        'filename': os.path.basename(filename),
                        'path': filename,
                        'timestamp': time.time(),
                    })
            
            output_template = os.path.join(output_path, output_name)
            
            ydl_opts = self._get_common_ydl_opts()
            ydl_opts.update({
                'format': format_selector,
                'outtmpl': output_template,
                'progress_hooks': [progress_hook],
                'postprocessor_hooks': [postprocessor_hook],
                'quiet': False,
                'no_warnings': False,
            })
            
            ffmpeg_binary = os.environ.get("FFMPEG_BINARY")
            if ffmpeg_binary and os.path.exists(ffmpeg_binary):
                ydl_opts['ffmpeg_location'] = os.path.dirname(ffmpeg_binary)
                print(f"[action_download] Using ffmpeg at: {ffmpeg_binary}")
            
            if download_subtitles or download_captions:
                ydl_opts['writesubtitles'] = True
                if download_captions:
                    ydl_opts['writeautomaticsub'] = True
                if embed_subs:
                    ydl_opts['embedsubtitles'] = True
                    ydl_opts['postprocessors'] = [{
                        'key': 'FFmpegEmbedSubtitle',
                    }]
            
            def download_thread():
                try:
                    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                        ydl.download([video_url])
                    
                    if self.last_progress_time[download_id].get('status') == 'processing':
                        filename = self.last_progress_time[download_id].get('filename', 'Unknown')
                        self.last_progress_time[download_id] = {
                            'progress': 100.0,
                            'status': 'finished',
                            'filename': filename,
                            'timestamp': time.time(),
                            'success': True
                        }
                        
                        self.storage.add_download_entry({
                            'url': video_url,
                            'filename': os.path.basename(filename),
                            'path': filename,
                            'timestamp': time.time(),
                        })
                    else:
                        self.last_progress_time[download_id]['success'] = True
                        
                except Exception as e:
                    error_msg = str(e)
                    print(f"[action_download] Download thread error: {error_msg}")
                    self.last_progress_time[download_id] = {
                        'progress': 0,
                        'status': 'error',
                        'error': error_msg,
                        'timestamp': time.time(),
                        'success': False
                    }
            
            thread = threading.Thread(target=download_thread, daemon=True)
            thread.start()
            self.active_downloads[download_id] = thread
            
            print(f"[action_download] Download thread started for ID {download_id}")
            return {'success': True, 'download_id': download_id}
            
        except Exception as e:
            error_msg = str(e)
            print(f"[action_download] ERROR: {error_msg}")
            import traceback
            traceback.print_exc()
            return {'success': False, 'error': error_msg}
    
    def cancel_download(self, download_id):
        """
        Attempt to cancel an active download.
        
        Args:
            download_id: Download ID to cancel
            
        Returns:
            Dictionary with cancellation result. Note: yt-dlp does not support
            graceful cancellation, so this currently returns not-implemented error
        """
        if download_id in self.active_downloads:
            print(f"[cancel_download] Cancel requested for download {download_id} (not implemented)")
            return {'success': False, 'error': 'Download cancellation not supported yet'}
        else:
            return {'success': False, 'error': 'Download not found'}
    
    def get_download_progress(self, download_id):
        """
        Retrieve current progress information for download.
        
        Args:
            download_id: Download ID to query
            
        Returns:
            Dictionary with progress data including percentage, status, and timestamps,
            or None if download not found
        """
        if download_id in self.last_progress_time:
            return self.last_progress_time[download_id]
        return None
    
    def get_version_info(self):
        """
        Get yt-dlp library version information.
        
        Returns:
            Version string if yt-dlp is available, error message otherwise
        """
        if yt_dlp:
            return yt_dlp.version.__version__
        return "yt-dlp not installed"


_manager = None

def get_manager():
    """
    Retrieve singleton instance of DownloadManager.
    
    Returns:
        Global DownloadManager instance, creating it if necessary
    """
    global _manager
    if _manager is None:
        _manager = DownloadManager()
    return _manager


def action_submit(url, download_type=0):
    """
    Extract video or playlist metadata with thumbnail caching.
    
    QML-accessible wrapper for DownloadManager.action_submit() that adds
    automatic thumbnail download and caching for video entries.
    
    Args:
        url: Video or playlist URL to process
        download_type: Content type (0=video, 1=playlist)
        
    Returns:
        Dictionary with extracted data, cached thumbnail path, and generated entry ID
    """
    manager = get_manager()
    result = manager.action_submit(url, download_type)
    
    if result and result.get('type') == 'video' and result.get('data'):
        data = result['data']
        thumbnail_url = data.get('thumbnail')
        video_id = data.get('videoUrl', url)
        
        if thumbnail_url and video_id:
            storage = get_storage_manager()
            timestamp = int(time.time() * 1000)
            rand = random.randint(1000, 9999)
            entry_id = f"entry_{timestamp}_{rand}"
            
            cached_thumbnail = storage.download_thumbnail(thumbnail_url, video_id, entry_id)
            data['thumbnail'] = cached_thumbnail
            data['entryId'] = entry_id
            print(f"[action_submit] Entry ID: {entry_id}, Thumbnail: {cached_thumbnail}")
    
    return result


def action_download(video_url, options):
    """
    Initiate video download with specified configuration.
    
    QML-accessible wrapper for DownloadManager.action_download().
    
    Args:
        video_url: URL to download
        options: Download configuration dictionary
        
    Returns:
        Dictionary with download start confirmation and tracking ID
    """
    manager = get_manager()
    return manager.action_download(video_url, options)


def get_download_progress(download_id):
    """
    Query download progress for tracking.
    
    QML-accessible wrapper for DownloadManager.get_download_progress().
    
    Args:
        download_id: Download ID to query
        
    Returns:
        Progress dictionary or None
    """
    manager = get_manager()
    return manager.get_download_progress(download_id)


def cancel_download(download_id):
    """
    Request download cancellation.
    
    QML-accessible wrapper for DownloadManager.cancel_download().
    
    Args:
        download_id: Download ID to cancel
        
    Returns:
        Cancellation result dictionary
    """
    manager = get_manager()
    return manager.cancel_download(download_id)

def get_yt_dlp_version():
    """
    Retrieve yt-dlp version string.
    
    QML-accessible wrapper for DownloadManager.get_version_info().
    
    Returns:
        Version string
    """
    manager = get_manager()
    return manager.get_version_info()

if __name__ != "__main__":
    print("[download_manager.py] Module loaded successfully")
    print("[download_manager.py] Available functions: action_submit, action_download, is_valid_video_url, is_valid_playlist, save_list_model_data, load_list_model_data, get_yt_dlp_version")
