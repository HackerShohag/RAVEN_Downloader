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

import re


def is_valid_url(url):
    """
    Check if URL is a valid YouTube/video URL
    
    Args:
        url (str): URL to validate
        
    Returns:
        bool: True if valid video URL, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    # YouTube patterns (including shorts)
    youtube_patterns = [
        r'(https?://)?(www\.)?(youtube\.com/watch\?v=)',
        r'(https?://)?(www\.)?(youtu\.be/)',
        r'(https?://)?(www\.)?(youtube\.com/embed/)',
        r'(https?://)?(www\.)?(m\.youtube\.com/watch\?v=)',
        r'(https?://)?(www\.)?(youtube\.com/shorts/)',
        r'(https?://)?(yotu\.be/)',
    ]
    
    # Other video platforms
    other_patterns = [
        r'(https?://)?(www\.)?(vimeo\.com/)',
        r'(https?://)?(www\.)?(dailymotion\.com/)',
        r'(https?://)?(www\.)?(twitch\.tv/)',
    ]
    
    all_patterns = youtube_patterns + other_patterns
    
    for pattern in all_patterns:
        if re.search(pattern, url, re.IGNORECASE):
            return True
    
    return False


def is_valid_playlist_url(url):
    """
    Check if URL contains playlist parameter
    
    Args:
        url (str): URL to validate
        
    Returns:
        bool: True if valid playlist URL, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    # YouTube playlist patterns
    playlist_patterns = [
        r'[?&]list=',  # Standard playlist parameter
        r'/playlist\?',  # Playlist page
    ]
    
    for pattern in playlist_patterns:
        if re.search(pattern, url, re.IGNORECASE):
            return True
    
    return False


def extract_video_id(url):
    """
    Extract video ID from YouTube URL
    
    Args:
        url (str): YouTube URL
        
    Returns:
        str: Video ID or None
    """
    if not url:
        return None
    
    patterns = [
        r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
        r'(?:embed\/)([0-9A-Za-z_-]{11})',
        r'(?:shorts\/)([0-9A-Za-z_-]{11})',
        r'^([0-9A-Za-z_-]{11})$',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    
    return None
