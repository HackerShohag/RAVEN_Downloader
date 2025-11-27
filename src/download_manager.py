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
import sys
import threading
import time
from pathlib import Path

# Add lib/python3/dist-packages to path for embedded yt-dlp
current_dir = Path(__file__).parent.parent
lib_path = current_dir / "lib" / "python3" / "dist-packages"
if lib_path.exists():
    sys.path.insert(0, str(lib_path))
    print(f"[download_manager] Added lib path: {lib_path}")

# Add bin directory to PATH for embedded ffmpeg
bin_path = current_dir / "bin"
if bin_path.exists():
    os.environ["PATH"] = str(bin_path) + os.pathsep + os.environ.get("PATH", "")
    print(f"[download_manager] Added bin path to PATH: {bin_path}")
    
    # Store ffmpeg location for yt-dlp
    ffmpeg_location = bin_path / "ffmpeg"
    if ffmpeg_location.exists():
        print(f"[download_manager] Found embedded ffmpeg at: {ffmpeg_location}")
        os.environ["FFMPEG_BINARY"] = str(ffmpeg_location)
    else:
        print(f"[download_manager] WARNING: ffmpeg binary not found at {ffmpeg_location}")
else:
    print(f"[download_manager] WARNING: bin directory not found at {bin_path}")

# Import yt-dlp
try:
    import yt_dlp
    print(f"[download_manager] yt-dlp imported successfully, version: {yt_dlp.version.__version__}")
except ImportError as e:
    print(f"[download_manager] WARNING: yt-dlp not installed: {e}")
    yt_dlp = None
except Exception as e:
    print(f"[download_manager] ERROR importing yt-dlp: {e}")
    yt_dlp = None

# Handle both relative and absolute imports
try:
    from .url_validator import is_valid_url, is_valid_playlist_url
    from .format_parser import parse_video_formats, parse_playlist_info, format_filesize
    from .storage_manager import get_storage_manager
    print("[download_manager] Using relative imports")
except ImportError:
    # Fall back to absolute imports when run directly
    from url_validator import is_valid_url, is_valid_playlist_url
    from format_parser import parse_video_formats, parse_playlist_info, format_filesize
    from storage_manager import get_storage_manager
    print("[download_manager] Using absolute imports")


def speak(message):
    """Send debug message to QML"""
    print(f"[DownloadManager] {message}")
    return message


class DownloadManager:
    """Main download manager class"""
    
    def __init__(self):
        """Initialize download manager"""
        self.active_downloads = {}
        self.download_counter = 0
        self.storage = get_storage_manager()
        self.last_progress_time = {}
        self.progress_throttle = 0.1  # Throttle to 100ms between updates
    
    def action_submit(self, url, download_type=0):
        """
        Submit URL for processing (extract format information)
        Replaces C++ downloadManager.actionSubmit()
        
        Args:
            url (str): Video URL to process
            download_type (int): 0 for single video, 1 for playlist
            
        Returns:
            dict: Format data or error information
        """
        print(f"[action_submit] Called with URL: {url}, download_type: {download_type}")
        
        try:
            if not yt_dlp:
                error_msg = 'yt-dlp is not installed'
                print(f"[action_submit] ERROR: {error_msg}")
                return {'error': error_msg}
            
            # Validate URL
            print(f"[action_submit] Validating URL...")
            if not is_valid_url(url):
                error_msg = f'Invalid URL provided: {url}'
                print(f"[action_submit] ERROR: {error_msg}")
                return {'error': error_msg}
            
            print(f"[action_submit] URL is valid")
            
            # Check if it's a playlist
            is_playlist = is_valid_playlist_url(url)
            print(f"[action_submit] Is playlist: {is_playlist}")
            
            if is_playlist and download_type == 0:
                # User submitted playlist as single video
                print(f"[action_submit] Playlist URL submitted as single video")
                return {'error': 'playlist_as_video', 'url': url}
            
            # Extract video/playlist information
            print(f"[action_submit] Extracting info from: {url}")
            
            ydl_opts = {
                'quiet': True,
                'no_warnings': True,
                'extract_flat': is_playlist,  # Don't download playlist videos
            }
            
            print(f"[action_submit] Creating YoutubeDL instance...")
            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                print(f"[action_submit] Calling extract_info...")
                info = ydl.extract_info(url, download=False)
                print(f"[action_submit] Info extracted - Title: {info.get('title', 'Unknown')}")
                
                if is_playlist:
                    # Parse playlist info
                    print(f"[action_submit] Parsing playlist info...")
                    playlist_data = parse_playlist_info(info)
                    print(f"[action_submit] Returning playlist data")
                    return {'type': 'playlist', 'data': playlist_data}
                else:
                    # Parse video formats
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
        Download video with specified format
        Replaces C++ downloadManager.actionDownload()
        
        Args:
            video_url (str): Video URL to download
            options (dict): Download options including format IDs, path, etc.
                - format: Combined format string (e.g., "137+140")
                - indexID: Download ID for progress tracking
                - downloadLocation: Custom download path (optional)
                - subtitle: Download subtitles (optional)
                - caption: Download captions (optional)
                - embedded: Embed subtitles (optional)
                
        Returns:
            dict: Download started confirmation with download_id
        """
        try:
            if not yt_dlp:
                error_msg = 'yt-dlp is not installed'
                print(f"[action_download] ERROR: {error_msg}")
                return {'success': False, 'error': error_msg}
            
            # Extract download ID from options
            download_id = options.get('indexID', self.download_counter)
            if 'indexID' not in options:
                self.download_counter += 1
                download_id = self.download_counter
            
            # Extract format string
            format_selector = options.get('format', 'best')
            
            # Get output path
            output_path = options.get('downloadLocation', self.storage.get_download_path())
            output_name = '%(title)s.%(ext)s'
            
            # Subtitle/caption options
            download_subtitles = options.get('subtitle', False)
            download_captions = options.get('caption', False)
            embed_subs = options.get('embedded', False)
            
            print(f"[action_download] Starting download {download_id} for {video_url}")
            print(f"[action_download] Format: {format_selector}, Path: {output_path}")
            
            # Progress hook - stores progress for polling
            def progress_hook(d):
                current_time = time.time()
                
                if d['status'] == 'downloading':
                    # Calculate progress percentage
                    downloaded = d.get('downloaded_bytes', 0)
                    total = d.get('total_bytes', 0) or d.get('total_bytes_estimate', 0)
                    
                    if total > 0:
                        progress = (downloaded / total) * 100.0
                        # Store progress for polling
                        self.last_progress_time[download_id] = {
                            'progress': progress,
                            'downloaded': downloaded,
                            'total': total,
                            'status': 'downloading',
                            'timestamp': current_time
                        }
                    
                elif d['status'] == 'finished':
                    # This is called after each fragment/stream download
                    # For audio+video, it's called twice (once for audio, once for video)
                    # Wait for post-processing to complete before marking as finished
                    filename = d.get('filename', 'Unknown')
                    print(f"[action_download] Stream downloaded: {filename}")
                    
                    # Update to processing status (ffmpeg merging)
                    self.last_progress_time[download_id] = {
                        'progress': 95.0,  # Show 95% while processing
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
            
            # Post-processing hook for ffmpeg merging
            def postprocessor_hook(d):
                if d['status'] == 'finished':
                    # Final file ready after merging
                    filename = d.get('info_dict', {}).get('filepath', 'Unknown')
                    print(f"[action_download] Post-processing complete: {filename}")
                    
                    # Now mark as truly finished
                    self.last_progress_time[download_id] = {
                        'progress': 100.0,
                        'status': 'finished',
                        'filename': filename,
                        'timestamp': time.time()
                    }
                    
                    # Add to history
                    self.storage.add_download_entry({
                        'url': video_url,
                        'filename': os.path.basename(filename),
                        'path': filename,
                        'timestamp': time.time(),
                    })
            
            # Build yt-dlp options
            output_template = os.path.join(output_path, output_name)
            
            ydl_opts = {
                'format': format_selector,
                'outtmpl': output_template,
                'progress_hooks': [progress_hook],
                'postprocessor_hooks': [postprocessor_hook],
                'quiet': False,
                'no_warnings': False,
            }
            
            # Configure ffmpeg location if available
            ffmpeg_binary = os.environ.get("FFMPEG_BINARY")
            if ffmpeg_binary and os.path.exists(ffmpeg_binary):
                ydl_opts['ffmpeg_location'] = os.path.dirname(ffmpeg_binary)
                print(f"[action_download] Using ffmpeg at: {ffmpeg_binary}")
            
            # Add subtitle options
            if download_subtitles or download_captions:
                ydl_opts['writesubtitles'] = True
                if download_captions:
                    ydl_opts['writeautomaticsub'] = True
                if embed_subs:
                    ydl_opts['embedsubtitles'] = True
                    ydl_opts['postprocessors'] = [{
                        'key': 'FFmpegEmbedSubtitle',
                    }]
            
            # Start download in separate thread
            def download_thread():
                try:
                    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                        ydl.download([video_url])
                    
                    # If still in processing state, mark as finished
                    # (happens when no post-processing needed)
                    if self.last_progress_time[download_id].get('status') == 'processing':
                        filename = self.last_progress_time[download_id].get('filename', 'Unknown')
                        self.last_progress_time[download_id] = {
                            'progress': 100.0,
                            'status': 'finished',
                            'filename': filename,
                            'timestamp': time.time(),
                            'success': True
                        }
                        
                        # Add to history
                        self.storage.add_download_entry({
                            'url': video_url,
                            'filename': os.path.basename(filename),
                            'path': filename,
                            'timestamp': time.time(),
                        })
                    else:
                        # Mark as success
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
        Cancel active download
        
        Args:
            download_id (int): Download ID to cancel
            
        Returns:
            dict: Cancellation result
        """
        if download_id in self.active_downloads:
            # Note: yt-dlp doesn't support cancellation easily
            # This is a limitation we need to document
            print(f"[cancel_download] Cancel requested for download {download_id} (not implemented)")
            return {'success': False, 'error': 'Download cancellation not supported yet'}
        else:
            return {'success': False, 'error': 'Download not found'}
    
    def get_download_progress(self, download_id):
        """
        Get current download progress
        
        Args:
            download_id (int): Download ID to check
            
        Returns:
            dict: Progress information or None if not found
        """
        if download_id in self.last_progress_time:
            return self.last_progress_time[download_id]
        return None
    
    def get_version_info(self):
        """
        Get yt-dlp version information
        
        Returns:
            str: Version string
        """
        if yt_dlp:
            return yt_dlp.version.__version__
        return "yt-dlp not installed"


# Global instance
_manager = None

def get_manager():
    """Get singleton download manager instance"""
    global _manager
    if _manager is None:
        _manager = DownloadManager()
    return _manager


# Module-level functions for QML access
def action_submit(url, download_type=0):
    """
    Submit URL for format extraction
    
    Args:
        url (str): Video URL
        download_type (int): 0 for video, 1 for playlist
        
    Returns:
        dict: Format data or error
    """
    manager = get_manager()
    return manager.action_submit(url, download_type)


def action_download(video_url, options):
    """
    Download video with options
    
    Args:
        video_url (str): Video URL
        options (dict): Download options
        
    Returns:
        dict: Download start confirmation
    """
    manager = get_manager()
    return manager.action_download(video_url, options)


def get_download_progress(download_id):
    """
    Get download progress
    
    Args:
        download_id (int): Download ID
        
    Returns:
        dict: Progress information or None
    """
    manager = get_manager()
    return manager.get_download_progress(download_id)


def cancel_download(download_id):
    """
    Cancel download
    
    Args:
        download_id (int): Download ID
        
    Returns:
        dict: Cancellation result
    """
    manager = get_manager()
    return manager.cancel_download(download_id)


def is_valid_video_url(url):
    """
    Check if URL is valid
    
    Args:
        url (str): URL to validate
        
    Returns:
        bool: True if valid
    """
    return is_valid_url(url)


def is_valid_playlist(url):
    """
    Check if URL is a playlist
    
    Args:
        url (str): URL to check
        
    Returns:
        bool: True if playlist
    """
    return is_valid_playlist_url(url)


def save_list_model_data(data):
    """
    Save download history
    
    Args:
        data: Data to save
        
    Returns:
        bool: Success status
    """
    try:
        from .storage_manager import save_list_model_data as save_data
    except ImportError:
        from storage_manager import save_list_model_data as save_data
    return save_data(data)


def load_list_model_data():
    """
    Load download history
    
    Returns:
        list: Download history
    """
    try:
        from .storage_manager import load_list_model_data as load_data
    except ImportError:
        from storage_manager import load_list_model_data as load_data
    return load_data()


def get_yt_dlp_version():
    """
    Get yt-dlp version
    
    Returns:
        str: Version string
    """
    manager = get_manager()
    return manager.get_version_info()

# Module initialization complete
print("[download_manager.py] Module loaded successfully")
print("[download_manager.py] Available functions: action_submit, action_download, is_valid_video_url, is_valid_playlist, save_list_model_data, load_list_model_data, get_yt_dlp_version")
