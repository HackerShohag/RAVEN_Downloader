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


def parse_video_formats(info_dict: dict) -> dict:
    """
    Parse yt-dlp metadata into QML-compatible format structure.
    
    Args:
        info_dict: Raw metadata dictionary from yt-dlp extraction
        
    Returns:
        Formatted dictionary containing separated video/audio formats with metadata,
        or None if input is invalid
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
        'vcodeces': [],
        'notes': [],
        'videoExtensions': [],
        'videoFormatIds': [],
        'acodeces': [],
        'audioExtensions': [],
        'audioFormatIds': [],
        'audioBitrates': [],
        'audioSizes': [],
        'filesizes': [],
    }
    
    formats = info_dict.get('formats', [])
    video_formats = []
    audio_formats = []
    
    for fmt in formats:
        vcodec = fmt.get('vcodec', 'none')
        acodec = fmt.get('acodec', 'none')
        
        if vcodec and vcodec != 'none':
            video_formats.append(fmt)
        elif acodec and acodec != 'none' and vcodec == 'none':
            audio_formats.append(fmt)
    
    for fmt in video_formats:
        format_id = str(fmt.get('format_id', ''))
        vcodec = fmt.get('vcodec', 'unknown')
        ext = fmt.get('ext', 'mp4')
        filesize = fmt.get('filesize', 0) or fmt.get('filesize_approx', 0) or 0
        
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
    
    for fmt in audio_formats:
        format_id = str(fmt.get('format_id', ''))
        acodec = fmt.get('acodec', 'unknown')
        ext = fmt.get('ext', 'mp3')
        abr = fmt.get('abr', 0)
        filesize = fmt.get('filesize', 0) or fmt.get('filesize_approx', 0) or 0
        
        formats_data['audioFormatIds'].append(format_id)
        formats_data['acodeces'].append(acodec)
        formats_data['audioExtensions'].append(ext)
        formats_data['audioBitrates'].append(int(abr) if abr else 0)
        formats_data['audioSizes'].append(filesize)
    
    return formats_data


def parse_playlist_info(info_dict: dict) -> dict:
    """
    Extract and structure playlist metadata from yt-dlp output.
    
    Args:
        info_dict: Raw playlist metadata from yt-dlp
        
    Returns:
        Dictionary containing playlist title, ID, video count, and processed entries,
        or None if input is invalid
    """
    if not info_dict:
        return None
    
    entries = info_dict.get('entries', [])
    processed_entries = []
    
    for entry in entries:
        if entry:
            processed_entry = {
                'id': entry.get('id', ''),
                'title': entry.get('title', 'Unknown'),
                'url': entry.get('url', '') or entry.get('webpage_url', ''),
                'duration': entry.get('duration', 0),
            }
            processed_entries.append(processed_entry)
    
    return {
        'title': info_dict.get('title', 'Unknown Playlist'),
        'playlist_id': info_dict.get('id', ''),
        'uploader': info_dict.get('uploader', ''),
        'video_count': len(processed_entries),
        'entries': processed_entries,
    }


def format_duration(seconds: int) -> str:
    """
    Convert duration from seconds to human-readable time format.
    
    Args:
        seconds: Duration in seconds
        
    Returns:
        Formatted string as MM:SS or HH:MM:SS, or "00:00" for invalid input
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


def format_filesize(bytes_size: int) -> str:
    """
    Convert byte size to human-readable format with appropriate units.
    
    Args:
        bytes_size: File size in bytes
        
    Returns:
        Formatted string with size and unit (B, KB, MB, GB, TB), or "Unknown" for invalid input
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


def get_best_format_id(info_dict: dict, prefer_quality: str = 'best') -> str:
    """
    Select optimal video format based on quality preference.
    
    Args:
        info_dict: yt-dlp metadata dictionary
        prefer_quality: Quality preference ('best', 'worst', or specific resolution)
        
    Returns:
        Format ID string of the selected format, or None if no suitable format found
    """
    formats = info_dict.get('formats', [])
    
    if not formats:
        return None
    
    if prefer_quality == 'best':
        video_formats = [f for f in formats if f.get('vcodec', 'none') != 'none']
        if video_formats:
            best_format = max(video_formats, key=lambda f: f.get('height', 0) or 0)
            return str(best_format.get('format_id', ''))
    
    return None
