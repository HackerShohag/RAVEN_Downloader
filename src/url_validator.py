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

PLATFORM_PATTERNS = [
    {
        'name': 'YouTube',
        'domains': [r'youtube\.com', r'youtu\.be', r'm\.youtube\.com', r'yotu\.be'],
        'video_patterns': [r'/watch\?v=', r'/embed/', r'/shorts/', r'youtu\.be/'],
        'playlist_patterns': [r'[?&]list=', r'/playlist\?'],
    },
    {
        'name': 'Vimeo',
        'domains': [r'vimeo\.com', r'player\.vimeo\.com'],
        'video_patterns': [r'/\d+', r'/video/'],
        'playlist_patterns': [r'/album/', r'/channels/', r'/groups/', r'/showcase/'],
    },
    {
        'name': 'Dailymotion',
        'domains': [r'dailymotion\.com', r'dai\.ly'],
        'video_patterns': [r'/video/', r'dai\.ly/'],
        'playlist_patterns': [r'/playlist/', r'/user/.+/\d+'],
    },
    {
        'name': 'Twitch',
        'domains': [r'twitch\.tv', r'm\.twitch\.tv'],
        'video_patterns': [r'/videos/', r'/clips/'],
        'playlist_patterns': [r'/collections/', r'/(videos|clips)\?filter='],
    },
    {
        'name': 'Facebook',
        'domains': [r'facebook\.com', r'fb\.watch', r'fb\.com'],
        'video_patterns': [r'/videos?/', r'/watch/', r'fb\.watch/'],
        'playlist_patterns': [r'/watch/[^/]+/\d+'],
    },
    {
        'name': 'Instagram',
        'domains': [r'instagram\.com', r'instagr\.am'],
        'video_patterns': [r'/p/', r'/reel/', r'/tv/'],
        'playlist_patterns': [r'/explore/tags/'],
    },
    {
        'name': 'Twitter',
        'domains': [r'twitter\.com', r'x\.com', r't\.co'],
        'video_patterns': [r'/status/', r'/i/broadcasts/'],
        'playlist_patterns': [],
    },
    {
        'name': 'TikTok',
        'domains': [r'tiktok\.com', r'vm\.tiktok\.com'],
        'video_patterns': [r'/@[^/]+/video/', r'/v/'],
        'playlist_patterns': [r'/@[^/]+$'],
    },
    {
        'name': 'SoundCloud',
        'domains': [r'soundcloud\.com', r'snd\.sc'],
        'video_patterns': [r'/[^/]+/[^/]+$'],
        'playlist_patterns': [r'/sets/', r'/[^/]+/tracks', r'/[^/]+/albums'],
    },
    {
        'name': 'Reddit',
        'domains': [r'reddit\.com', r'redd\.it', r'v\.redd\.it'],
        'video_patterns': [r'/r/[^/]+/comments/', r'v\.redd\.it/'],
        'playlist_patterns': [r'/r/[^/]+/top', r'/r/[^/]+/hot', r'/user/[^/]+/submitted'],
    },
    {
        'name': 'Bilibili',
        'domains': [r'bilibili\.com', r'b23\.tv'],
        'video_patterns': [r'/video/av', r'/video/BV'],
        'playlist_patterns': [r'/medialist/', r'/favlist/', r'/bangumi/play/'],
    },
]


def is_valid_url(url: str) -> bool:
    """
    Validate if URL is from a supported video platform.
    
    Args:
        url: URL string to validate
        
    Returns:
        True if URL matches any supported platform pattern, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    url = url.strip()
    
    if not re.match(r'^https?://', url, re.IGNORECASE):
        url = 'https://' + url
    
    for platform in PLATFORM_PATTERNS:
        domain_match = any(re.search(domain, url, re.IGNORECASE) 
                          for domain in platform['domains'])
        
        if domain_match:
            video_match = any(re.search(pattern, url, re.IGNORECASE) 
                            for pattern in platform['video_patterns'])
            playlist_match = any(re.search(pattern, url, re.IGNORECASE) 
                               for pattern in platform['playlist_patterns'])
            
            if video_match or playlist_match:
                return True
    
    return False


def is_valid_playlist_url(url: str) -> bool:
    """
    Validate if URL is a playlist from a supported platform.
    
    Args:
        url: URL string to validate
        
    Returns:
        True if URL matches playlist pattern for any supported platform, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    url = url.strip()
    
    if not re.match(r'^https?://', url, re.IGNORECASE):
        url = 'https://' + url
    
    for platform in PLATFORM_PATTERNS:
        domain_match = any(re.search(domain, url, re.IGNORECASE) 
                          for domain in platform['domains'])
        
        if domain_match and platform['playlist_patterns']:
            playlist_match = any(re.search(pattern, url, re.IGNORECASE) 
                               for pattern in platform['playlist_patterns'])
            
            if playlist_match:
                return True
    
    return False


def get_platform_name(url: str) -> str:
    """
    Identify the video platform from URL.
    
    Args:
        url: URL string to analyze
        
    Returns:
        Platform name string, or 'Unknown' if not recognized
    """
    if not url or not isinstance(url, str):
        return 'Unknown'
    
    url = url.strip()
    
    for platform in PLATFORM_PATTERNS:
        domain_match = any(re.search(domain, url, re.IGNORECASE) 
                          for domain in platform['domains'])
        if domain_match:
            return platform['name']
    
    return 'Unknown'


def supports_playlists(url: str) -> bool:
    """
    Check if the platform supports playlist downloads.
    
    Args:
        url: URL string to check
        
    Returns:
        True if the platform has playlist support, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    url = url.strip()
    
    for platform in PLATFORM_PATTERNS:
        domain_match = any(re.search(domain, url, re.IGNORECASE) 
                          for domain in platform['domains'])
        if domain_match:
            return len(platform['playlist_patterns']) > 0
    
    return False


def extract_video_id(url: str) -> str:
    """
    Extract unique video identifier from YouTube URL.
    
    Args:
        url: YouTube URL string
        
    Returns:
        Video ID string, or None if not found
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


is_valid_video_url = is_valid_url
is_valid_playlist = is_valid_playlist_url
