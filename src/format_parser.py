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

# Standard library imports - no external dependencies required


def parse_video_formats(info_dict):
    """
    Parse yt-dlp info dict into QML-compatible format
    
    Args:
        info_dict (dict): yt-dlp extracted info
        
    Returns:
        dict: Formatted data compatible with QML mediaFormats object
    """
    if not info_dict:
        return None
    
    formats_data = {
        'title': info_dict.get('title', 'Unknown'),
        'thumbnail': info_dict.get('thumbnail', ''),
        'duration': format_duration(info_dict.get('duration', 0)),
        'videoUrl': info_dict.get('webpage_url', info_dict.get('url', '')),
        'uploader': info_dict.get('uploader', ''),
        'uploadDate': info_dict.get('upload_date', ''),
        
        # Video format arrays
        'vcodeces': [],
        'notes': [],  # Resolutions
        'videoExtensions': [],
        'videoFormatIds': [],
        
        # Audio format arrays
        'acodeces': [],
        'audioExtensions': [],
        'audioFormatIds': [],
        'audioBitrates': [],
        'audioSizes': [],
        
        # Common
        'filesizes': [],
    }
    
    # Process all available formats
    formats = info_dict.get('formats', [])
    
    # Separate video and audio formats
    video_formats = []
    audio_formats = []
    
    for fmt in formats:
        vcodec = fmt.get('vcodec', 'none')
        acodec = fmt.get('acodec', 'none')
        
        # Video formats (has video codec)
        if vcodec and vcodec != 'none':
            video_formats.append(fmt)
        # Audio-only formats (has audio but no video)
        elif acodec and acodec != 'none' and vcodec == 'none':
            audio_formats.append(fmt)
    
    # Parse video formats
    for fmt in video_formats:
        format_id = str(fmt.get('format_id', ''))
        vcodec = fmt.get('vcodec', 'unknown')
        ext = fmt.get('ext', 'mp4')
        filesize = fmt.get('filesize', 0) or fmt.get('filesize_approx', 0) or 0
        
        # Resolution/quality note
        resolution = fmt.get('resolution', '')
        if not resolution:
            height = fmt.get('height', 0)
            width = fmt.get('width', 0)
            if height:
                resolution = f"{width}x{height}" if width else f"{height}p"
            else:
                resolution = fmt.get('format_note', 'unknown')
        
        formats_data['videoFormatIds'].append(format_id)
        formats_data['vcodeces'].append(vcodec)
        formats_data['videoExtensions'].append(ext)
        formats_data['notes'].append(resolution)
        formats_data['filesizes'].append(filesize)
    
    # Parse audio formats
    for fmt in audio_formats:
        format_id = str(fmt.get('format_id', ''))
        acodec = fmt.get('acodec', 'unknown')
        ext = fmt.get('ext', 'mp3')
        abr = fmt.get('abr', 0)  # Audio bitrate
        filesize = fmt.get('filesize', 0) or fmt.get('filesize_approx', 0) or 0
        
        formats_data['audioFormatIds'].append(format_id)
        formats_data['acodeces'].append(acodec)
        formats_data['audioExtensions'].append(ext)
        formats_data['audioBitrates'].append(int(abr) if abr else 0)
        formats_data['audioSizes'].append(filesize)
    
    return formats_data


def parse_playlist_info(info_dict):
    """
    Parse playlist information
    
    Args:
        info_dict (dict): yt-dlp extracted playlist info
        
    Returns:
        dict: Playlist metadata
    """
    if not info_dict:
        return None
    
    entries = info_dict.get('entries', [])
    
    return {
        'title': info_dict.get('title', 'Unknown Playlist'),
        'playlist_id': info_dict.get('id', ''),
        'uploader': info_dict.get('uploader', ''),
        'video_count': len(entries),
        'entries': entries,
    }


def format_duration(seconds):
    """
    Convert duration in seconds to readable format (HH:MM:SS)
    
    Args:
        seconds (int): Duration in seconds
        
    Returns:
        str: Formatted duration string
    """
    if not seconds or seconds <= 0:
        return "00:00"
    
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    
    if hours > 0:
        return f"{hours:02d}:{minutes:02d}:{secs:02d}"
    else:
        return f"{minutes:02d}:{secs:02d}"


def format_filesize(bytes_size):
    """
    Convert bytes to human-readable file size
    
    Args:
        bytes_size (int): Size in bytes
        
    Returns:
        str: Formatted size string (e.g., "10.5 MB")
    """
    if not bytes_size or bytes_size <= 0:
        return "Unknown"
    
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    size = float(bytes_size)
    unit_index = 0
    
    while size >= 1024.0 and unit_index < len(units) - 1:
        size /= 1024.0
        unit_index += 1
    
    return f"{size:.2f} {units[unit_index]}"


def get_best_format_id(info_dict, prefer_quality='best'):
    """
    Get the best format ID based on preference
    
    Args:
        info_dict (dict): yt-dlp extracted info
        prefer_quality (str): 'best', 'worst', or specific resolution like '720p'
        
    Returns:
        str: Format ID or None
    """
    formats = info_dict.get('formats', [])
    
    if not formats:
        return None
    
    if prefer_quality == 'best':
        # Get format with highest resolution
        video_formats = [f for f in formats if f.get('vcodec', 'none') != 'none']
        if video_formats:
            best_format = max(video_formats, key=lambda f: f.get('height', 0) or 0)
            return str(best_format.get('format_id', ''))
    
    return None
