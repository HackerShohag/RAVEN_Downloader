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

# Standard library imports
import re


# Video platform URL patterns
# Format: (domain_pattern, video_patterns, playlist_patterns, name)
PLATFORM_PATTERNS = [
    # YouTube
    {
        'name': 'YouTube',
        'domains': [r'youtube\.com', r'youtu\.be', r'm\.youtube\.com', r'yotu\.be'],
        'video_patterns': [
            r'/watch\?v=',
            r'/embed/',
            r'/shorts/',
            r'youtu\.be/',
        ],
        'playlist_patterns': [
            r'[?&]list=',
            r'/playlist\?',
        ],
    },
    
    # Vimeo
    {
        'name': 'Vimeo',
        'domains': [r'vimeo\.com', r'player\.vimeo\.com'],
        'video_patterns': [
            r'/\d+',  # vimeo.com/123456789
            r'/video/',
        ],
        'playlist_patterns': [
            r'/album/',
            r'/channels/',
            r'/groups/',
            r'/showcase/',
        ],
    },
    
    # Dailymotion
    {
        'name': 'Dailymotion',
        'domains': [r'dailymotion\.com', r'dai\.ly'],
        'video_patterns': [
            r'/video/',
            r'dai\.ly/',
        ],
        'playlist_patterns': [
            r'/playlist/',
            r'/user/.+/\d+',  # user playlists
        ],
    },
    
    # Twitch
    {
        'name': 'Twitch',
        'domains': [r'twitch\.tv', r'm\.twitch\.tv'],
        'video_patterns': [
            r'/videos/',
            r'/clips/',
        ],
        'playlist_patterns': [
            r'/collections/',
            r'/(videos|clips)\?filter=',  # filtered video lists
        ],
    },
    
    # Facebook
    {
        'name': 'Facebook',
        'domains': [r'facebook\.com', r'fb\.watch', r'fb\.com'],
        'video_patterns': [
            r'/videos?/',
            r'/watch/',
            r'fb\.watch/',
        ],
        'playlist_patterns': [
            r'/watch/[^/]+/\d+',  # video series
        ],
    },
    
    # Instagram
    {
        'name': 'Instagram',
        'domains': [r'instagram\.com', r'instagr\.am'],
        'video_patterns': [
            r'/p/',  # posts
            r'/reel/',
            r'/tv/',
        ],
        'playlist_patterns': [
            r'/explore/tags/',  # hashtag feeds (limited)
        ],
    },
    
    # Twitter/X
    {
        'name': 'Twitter',
        'domains': [r'twitter\.com', r'x\.com', r't\.co'],
        'video_patterns': [
            r'/status/',
            r'/i/broadcasts/',
        ],
        'playlist_patterns': [],  # Twitter doesn't have traditional playlists
    },
    
    # TikTok
    {
        'name': 'TikTok',
        'domains': [r'tiktok\.com', r'vm\.tiktok\.com'],
        'video_patterns': [
            r'/@[^/]+/video/',
            r'/v/',
        ],
        'playlist_patterns': [
            r'/@[^/]+$',  # user profile (all videos)
        ],
    },
    
    # SoundCloud
    {
        'name': 'SoundCloud',
        'domains': [r'soundcloud\.com', r'snd\.sc'],
        'video_patterns': [
            r'/[^/]+/[^/]+$',  # user/track
        ],
        'playlist_patterns': [
            r'/sets/',
            r'/[^/]+/tracks',  # user tracks
            r'/[^/]+/albums',  # user albums
        ],
    },
    
    # Reddit
    {
        'name': 'Reddit',
        'domains': [r'reddit\.com', r'redd\.it', r'v\.redd\.it'],
        'video_patterns': [
            r'/r/[^/]+/comments/',
            r'v\.redd\.it/',
        ],
        'playlist_patterns': [
            r'/r/[^/]+/top',
            r'/r/[^/]+/hot',
            r'/user/[^/]+/submitted',  # user submissions
        ],
    },
    
    # Bilibili
    {
        'name': 'Bilibili',
        'domains': [r'bilibili\.com', r'b23\.tv'],
        'video_patterns': [
            r'/video/av',
            r'/video/BV',
        ],
        'playlist_patterns': [
            r'/medialist/',
            r'/favlist/',
            r'/bangumi/play/',  # series
        ],
    },
]


def is_valid_url(url):
    """
    Check if URL is a valid video URL from supported platforms
    
    Args:
        url (str): URL to validate
        
    Returns:
        bool: True if valid video URL, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    url = url.strip()
    
    # Basic URL format check
    if not re.match(r'^https?://', url, re.IGNORECASE):
        # Try adding https://
        url = 'https://' + url
    
    # Check against all platform patterns
    for platform in PLATFORM_PATTERNS:
        # Check if domain matches
        domain_match = any(re.search(domain, url, re.IGNORECASE) 
                          for domain in platform['domains'])
        
        if domain_match:
            # Check if it matches video patterns OR playlist patterns
            video_match = any(re.search(pattern, url, re.IGNORECASE) 
                            for pattern in platform['video_patterns'])
            playlist_match = any(re.search(pattern, url, re.IGNORECASE) 
                               for pattern in platform['playlist_patterns'])
            
            if video_match or playlist_match:
                return True
    
    return False


def is_valid_playlist_url(url):
    """
    Check if URL is a playlist URL from supported platforms
    
    Args:
        url (str): URL to validate
        
    Returns:
        bool: True if valid playlist URL, False otherwise
    """
    if not url or not isinstance(url, str):
        return False
    
    url = url.strip()
    
    # Basic URL format check
    if not re.match(r'^https?://', url, re.IGNORECASE):
        url = 'https://' + url
    
    # Check against all platform patterns
    for platform in PLATFORM_PATTERNS:
        # Check if domain matches
        domain_match = any(re.search(domain, url, re.IGNORECASE) 
                          for domain in platform['domains'])
        
        if domain_match and platform['playlist_patterns']:
            # Check if it matches playlist patterns
            playlist_match = any(re.search(pattern, url, re.IGNORECASE) 
                               for pattern in platform['playlist_patterns'])
            
            if playlist_match:
                return True
    
    return False


def get_platform_name(url):
    """
    Identify the platform from URL
    
    Args:
        url (str): URL to check
        
    Returns:
        str: Platform name or 'Unknown'
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


def supports_playlists(url):
    """
    Check if the platform supports playlist downloads
    
    Args:
        url (str): URL to check
        
    Returns:
        bool: True if platform supports playlists
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


# Backwards compatibility aliases
is_valid_video_url = is_valid_url
is_valid_playlist = is_valid_playlist_url
