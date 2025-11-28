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
import json
import os
import random
import sys
import time
from pathlib import Path


class StorageManager:
    """Manages persistent storage for download history and settings"""
    
    def __init__(self, app_name='raven.downloader.shohag'):
        """
        Initialize storage manager
        
        Args:
            app_name (str): Application name for config directory
        """
        self.app_name = app_name
        self.config_dir = self._get_config_dir()
        self.index_file = os.path.join(self.config_dir, 'index.json')  # Entry index
        self.entries_dir = os.path.join(self.config_dir, 'entries')  # Entry directories
        self.settings_file = os.path.join(self.config_dir, 'settings.json')
        
        print(f"[StorageManager] Config directory: {self.config_dir}")
        sys.stdout.flush()
        print(f"[StorageManager] Index file: {self.index_file}")
        sys.stdout.flush()
        print(f"[StorageManager] Entries directory: {self.entries_dir}")
        sys.stdout.flush()
        print(f"[StorageManager] Settings file: {self.settings_file}")
        sys.stdout.flush()
        
        # Ensure directories exist
        os.makedirs(self.config_dir, exist_ok=True)
        os.makedirs(self.entries_dir, exist_ok=True)
    
    def _get_config_dir(self):
        """
        Get configuration directory path
        
        Returns:
            str: Path to config directory
        """
        # Try XDG config home first (Ubuntu Touch standard)
        xdg_config = os.environ.get('XDG_CONFIG_HOME')
        if xdg_config:
            return os.path.join(xdg_config, self.app_name)
        
        # Fallback to ~/.config
        return os.path.join(Path.home(), '.config', self.app_name)
    
    def _generate_entry_id(self):
        """
        Generate unique entry ID using timestamp and random component
        
        Returns:
            str: Unique entry ID
        """
        timestamp = int(time.time() * 1000)
        rand = random.randint(1000, 9999)
        return f"entry_{timestamp}_{rand}"
    
    def save_download_history(self, history_data):
        """
        DEPRECATED: Use entry-based storage via save_entry() instead
        This method is kept for backward compatibility but does nothing
        
        Args:
            history_data (list): List of download items
            
        Returns:
            bool: True (always succeeds as it's deprecated)
        """
        print(f"[StorageManager] save_download_history is deprecated - use entry-based storage")
        return True
    
    def load_download_history(self):
        """
        DEPRECATED: Use load_all_entries() instead
        This method returns all entries from entry-based storage for backward compatibility
        
        Returns:
            list: List of download items from entry-based storage
        """
        print(f"[StorageManager] load_download_history is deprecated - using load_all_entries()")
        return self.load_all_entries()
    
    def add_download_entry(self, entry):
        """
        Add a single download entry to history
        Now uses entry-based storage
        
        Args:
            entry (dict): Download entry data
            
        Returns:
            bool: True if successful
        """
        entry_id = self.save_entry(entry)
        return entry_id is not None
    
    def clear_download_history(self):
        """
        Clear all download history (entry-based storage)
        Removes all entries and clears index
        
        Returns:
            bool: True if successful
        """
        try:
            # Clear index file
            if os.path.exists(self.index_file):
                with open(self.index_file, 'w', encoding='utf-8') as f:
                    json.dump([], f)
            
            # Remove entries directory
            import shutil
            if os.path.exists(self.entries_dir):
                shutil.rmtree(self.entries_dir)
                os.makedirs(self.entries_dir, exist_ok=True)
            
            print(f"[StorageManager] Download history cleared")
            return True
        except Exception as e:
            print(f"[StorageManager] Error clearing history: {e}")
            return False
    
    def save_settings(self, settings):
        """
        Save application settings
        
        Args:
            settings (dict): Settings dictionary
            
        Returns:
            bool: True if successful
        """
        try:
            with open(self.settings_file, 'w', encoding='utf-8') as f:
                json.dump(settings, f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"Error saving settings: {e}")
            return False
    
    def load_settings(self):
        """
        Load application settings
        
        Returns:
            dict: Settings dictionary, empty dict if file doesn't exist
        """
        try:
            if os.path.exists(self.settings_file):
                with open(self.settings_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            return {}
        except Exception as e:
            print(f"Error loading settings: {e}")
            return {}
    
    def get_download_path(self):
        """
        Get download path for temporary storage.
        On Ubuntu Touch, apps can only write to their cache directory.
        Files should be downloaded here, then exported via ContentHub.
        
        Returns:
            str: Download directory path (app's cache directory)
        """
        # Use XDG_CACHE_HOME which the app has write permissions for
        xdg_cache = os.environ.get('XDG_CACHE_HOME')
        if xdg_cache:
            cache_downloads = os.path.join(xdg_cache, self.app_name, 'downloads')
        else:
            # Fallback to ~/.cache
            cache_downloads = os.path.join(Path.home(), '.cache', self.app_name, 'downloads')
        
        # Ensure directory exists
        os.makedirs(cache_downloads, exist_ok=True)
        print(f"[StorageManager] Download path: {cache_downloads}")
        
        return cache_downloads
    
    def get_thumbnails_path(self):
        """
        Get thumbnails cache directory path
        
        Returns:
            str: Thumbnails directory path
        """
        xdg_cache = os.environ.get('XDG_CACHE_HOME')
        if xdg_cache:
            thumbnails_dir = os.path.join(xdg_cache, self.app_name, 'thumbnails')
        else:
            thumbnails_dir = os.path.join(Path.home(), '.cache', self.app_name, 'thumbnails')
        
        os.makedirs(thumbnails_dir, exist_ok=True)
        return thumbnails_dir
    
    def download_thumbnail(self, thumbnail_url, video_id, entry_id=None):
        """
        Download and cache a thumbnail image
        
        Args:
            thumbnail_url (str): Remote thumbnail URL
            video_id (str): Video ID for filename
            entry_id (str): Optional entry ID to save in entry directory
            
        Returns:
            str: Local file path to cached thumbnail, or original URL if download fails
        """
        if not thumbnail_url or not video_id:
            return thumbnail_url
        
        try:
            import urllib.request
            import hashlib
            
            # Determine extension from URL
            ext = '.jpg'
            if '.png' in thumbnail_url.lower():
                ext = '.png'
            elif '.webp' in thumbnail_url.lower():
                ext = '.webp'
            
            # If entry_id provided, save in entry directory
            if entry_id:
                entry_dir = os.path.join(self.entries_dir, entry_id)
                os.makedirs(entry_dir, exist_ok=True)
                thumbnail_path = os.path.join(entry_dir, f"thumbnail{ext}")
            else:
                # Legacy: save in global thumbnails directory
                safe_id = hashlib.md5(video_id.encode()).hexdigest()
                thumbnail_filename = f"{safe_id}{ext}"
                thumbnail_path = os.path.join(self.get_thumbnails_path(), thumbnail_filename)
            
            # Check if already cached
            if os.path.exists(thumbnail_path):
                print(f"[StorageManager] Using cached thumbnail: {thumbnail_path}")
                return thumbnail_path
            
            # Download thumbnail
            print(f"[StorageManager] Downloading thumbnail from: {thumbnail_url}")
            urllib.request.urlretrieve(thumbnail_url, thumbnail_path)
            print(f"[StorageManager] Thumbnail saved to: {thumbnail_path}")
            
            return thumbnail_path
            
        except Exception as e:
            print(f"[StorageManager] Error downloading thumbnail: {e}")
            # Return original URL as fallback
            return thumbnail_url
    
    def save_entry(self, entry_data):
        """
        Save a download entry with its own directory
        
        Args:
            entry_data (dict): Entry data including all metadata
            
        Returns:
            str: Entry ID
        """
        try:
            print(f"[StorageManager] save_entry called with data: {list(entry_data.keys()) if entry_data else 'None'}")
            sys.stdout.flush()
            
            # Generate unique entry ID if not present
            entry_id = entry_data.get('entryId')
            if not entry_id:
                entry_id = self._generate_entry_id()
                entry_data['entryId'] = entry_id
                print(f"[StorageManager] Generated new entry_id: {entry_id}")
                sys.stdout.flush()
            else:
                print(f"[StorageManager] Using existing entry_id: {entry_id}")
                sys.stdout.flush()
            
            # Create entry directory
            entry_dir = os.path.join(self.entries_dir, entry_id)
            os.makedirs(entry_dir, exist_ok=True)
            print(f"[StorageManager] Entry directory created/verified: {entry_dir}")
            sys.stdout.flush()
            
            # Save entry metadata
            entry_file = os.path.join(entry_dir, 'metadata.json')
            with open(entry_file, 'w', encoding='utf-8') as f:
                json.dump(entry_data, f, indent=2, ensure_ascii=False)
            
            print(f"[StorageManager] Entry metadata saved to: {entry_file}")
            sys.stdout.flush()
            
            # Update index
            print(f"[StorageManager] Calling _update_index...")
            sys.stdout.flush()
            self._update_index(entry_id, entry_data)
            
            return entry_id
            
        except Exception as e:
            print(f"[StorageManager] Error saving entry: {e}")
            import traceback
            traceback.print_exc()
            return None
    
    def save_single_entry(self, entry_data):
        """
        Save or update a single entry (called from QML on user interactions)
        
        Args:
            entry_data (dict): Entry data to save
            
        Returns:
            dict: Result with success status
        """
        try:
            entry_id = self.save_entry(entry_data)
            if entry_id:
                return {
                    'success': True,
                    'entryId': entry_id,
                    'message': f'Entry {entry_id} saved successfully'
                }
            else:
                return {
                    'success': False,
                    'error': 'Failed to save entry'
                }
        except Exception as e:
            print(f"[StorageManager] Error in save_single_entry: {e}")
            import traceback
            traceback.print_exc()
            return {
                'success': False,
                'error': str(e)
            }
    
    def _update_index(self, entry_id, entry_data):
        """
        Update index file with entry summary
        
        Args:
            entry_id (str): Entry ID
            entry_data (dict): Full entry data
        """
        try:
            print(f"[StorageManager] _update_index called for: {entry_id}")
            sys.stdout.flush()
            print(f"[StorageManager] Index file path: {self.index_file}")
            sys.stdout.flush()
            
            # Load existing index
            index = self.load_index()
            print(f"[StorageManager] Current index has {len(index)} entries")
            sys.stdout.flush()
            
            # Create index entry with essential fields only
            index_entry = {
                'entryId': entry_id,
                'vTitle': entry_data.get('vTitle', ''),
                'vID': entry_data.get('vID', ''),
                'timestamp': int(entry_data.get('timestamp', 0)),
                'vIndex': int(entry_data.get('vIndex', 0))
            }
            
            # Skip empty entries
            if not index_entry['vTitle'] and not index_entry['vID']:
                print(f"[StorageManager] Skipping index update for empty entry: {entry_id}")
                sys.stdout.flush()
                return
            
            # Check if entry already exists by entryId OR by vID (to prevent duplicates)
            existing_index = next((i for i, e in enumerate(index) if e.get('entryId') == entry_id), None)
            
            # Also check for duplicate vID (same video, different entryId)
            if existing_index is None and index_entry['vID']:
                duplicate_index = next((i for i, e in enumerate(index) if e.get('vID') == index_entry['vID'] and e.get('vID') != ''), None)
                if duplicate_index is not None:
                    print(f"[StorageManager] Found duplicate vID at index {duplicate_index}, updating instead")
                    sys.stdout.flush()
                    existing_index = duplicate_index
                    # Update the entryId to use the existing one to prevent orphaned entries
                    entry_id = index[duplicate_index]['entryId']
                    index_entry['entryId'] = entry_id
            
            if existing_index is not None:
                print(f"[StorageManager] Updating existing entry at index {existing_index}")
                sys.stdout.flush()
                index[existing_index] = index_entry
            else:
                print(f"[StorageManager] Adding new entry to index")
                sys.stdout.flush()
                index.append(index_entry)
            
            # Ensure directory exists
            os.makedirs(os.path.dirname(self.index_file), exist_ok=True)
            
            # Save index
            print(f"[StorageManager] Writing index to: {self.index_file}")
            sys.stdout.flush()
            with open(self.index_file, 'w', encoding='utf-8') as f:
                json.dump(index, f, indent=2, ensure_ascii=False)
            
            print(f"[StorageManager] Index successfully written with {len(index)} entries")
            sys.stdout.flush()
            
            # Verify file was created
            if os.path.exists(self.index_file):
                file_size = os.path.getsize(self.index_file)
                print(f"[StorageManager] Index file verified: {self.index_file} ({file_size} bytes)")
                sys.stdout.flush()
            else:
                print(f"[StorageManager] WARNING: Index file not found after write!")
                sys.stdout.flush()
            
        except Exception as e:
            print(f"[StorageManager] Error updating index: {e}")
            import traceback
            traceback.print_exc()
    
    def load_index(self):
        """
        Load index of all entries
        
        Returns:
            list: List of entry summaries
        """
        try:
            if os.path.exists(self.index_file):
                with open(self.index_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            return []
        except Exception as e:
            print(f"[StorageManager] Error loading index: {e}")
            return []
    
    def load_entry(self, entry_id):
        """
        Load full entry data from its directory
        
        Args:
            entry_id (str): Entry ID
            
        Returns:
            dict: Entry data or None
        """
        try:
            entry_dir = os.path.join(self.entries_dir, entry_id)
            entry_file = os.path.join(entry_dir, 'metadata.json')
            
            if os.path.exists(entry_file):
                with open(entry_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            return None
        except Exception as e:
            print(f"[StorageManager] Error loading entry {entry_id}: {e}")
            return None
    
    def load_all_entries(self):
        """
        Load all entries from their directories
        
        Returns:
            list: List of all entry data
        """
        index = self.load_index()
        entries = []
        
        for index_entry in index:
            entry_id = index_entry.get('entryId')
            if entry_id:
                entry_data = self.load_entry(entry_id)
                if entry_data:
                    entries.append(entry_data)
        
        print(f"[StorageManager] Loaded {len(entries)} entries")
        return entries


# Module-level convenience functions
_storage = None

def get_storage_manager():
    """Get singleton storage manager instance"""
    global _storage
    if _storage is None:
        _storage = StorageManager()
    return _storage


def save_list_model_data(data):
    """
    Save download history (compatibility with C++ API)
    Uses new entry-based storage architecture
    
    Args:
        data (list): List of download items from QML ListModel
        
    Returns:
        bool: Success status
    """
    storage = get_storage_manager()
    print(f"[save_list_model_data] Called with {len(data) if data else 0} items")
    sys.stdout.flush()
    
    try:
        if data:
            print(f"[save_list_model_data] Data type: {type(data)}")
            sys.stdout.flush()
            
            # Save each item as separate entry
            for idx, item in enumerate(data):
                print(f"[save_list_model_data] Item {idx} type: {type(item)}, value: {item}")
                sys.stdout.flush()
                
                # PyOtherSide sends QObjects that act like dicts but aren't dict instances
                # We need to extract the data by accessing properties directly
                item_dict = {}
                
                # Check if it's a PyOtherSide QObject - match the actual class name
                type_str = str(type(item))
                if 'pyotherside' in type_str.lower() or 'qobject' in type_str.lower():
                    print(f"[save_list_model_data] Converting PyOtherSide QObject to dict")
                    sys.stdout.flush()
                    
                    # Try to get all properties - PyOtherSide QObjects can be iterated
                    try:
                        # List of expected properties from QML model
                        expected_keys = [
                            'entryId', 'vTitle', 'vThumbnail', 'vDuration', 'vID',
                            'vCodec', 'vResolutions', 'vVideoExts', 'vVideoFormats', 'vVideoProgress',
                            'aCodec', 'vAudioExts', 'vAudioFormats', 'vABR', 'vAudioSizes',
                            'vVideoIndex', 'vAudioIndex', 'selectedVideoCodec', 'selectedAudioCodec',
                            'vSizeModel', 'vIndex', 'timestamp'
                        ]
                        
                        for key in expected_keys:
                            try:
                                # Try to get the attribute
                                value = getattr(item, key, None)
                                if value is not None:
                                    item_dict[key] = value
                            except:
                                pass
                        
                        print(f"[save_list_model_data] Extracted {len(item_dict)} properties from QObject")
                        sys.stdout.flush()
                        
                    except Exception as e:
                        print(f"[save_list_model_data] Error extracting QObject properties: {e}")
                        sys.stdout.flush()
                        continue
                        
                elif isinstance(item, dict):
                    item_dict = item
                else:
                    # Try direct dict conversion as fallback
                    try:
                        item_dict = dict(item)
                    except:
                        print(f"[save_list_model_data] Warning: Could not convert item {idx} to dict, type was: {type_str}")
                        sys.stdout.flush()
                        continue
                
                if item_dict:
                    print(f"[save_list_model_data] Processing item {idx}: entryId={item_dict.get('entryId', 'NO_ID')}, title={item_dict.get('vTitle', 'NO_TITLE')[:30]}")
                    sys.stdout.flush()
                    
                    # Skip empty or invalid entries (no title AND no video ID)
                    if not item_dict.get('vTitle') and not item_dict.get('vID'):
                        print(f"[save_list_model_data] Skipping empty entry at index {idx}")
                        sys.stdout.flush()
                        continue
                    
                    # Ensure integer types for numeric fields
                    for int_field in ['vVideoIndex', 'vAudioIndex', 'vIndex', 'timestamp']:
                        if int_field in item_dict and item_dict[int_field] is not None:
                            try:
                                item_dict[int_field] = int(item_dict[int_field])
                            except (ValueError, TypeError):
                                item_dict[int_field] = 0
                    
                    # Add timestamp if not present
                    if 'timestamp' not in item_dict:
                        item_dict['timestamp'] = int(time.time() * 1000)  # milliseconds
                    
                    # Save entry (will create or update)
                    entry_id = storage.save_entry(item_dict)
                    print(f"[save_list_model_data] Item {idx} saved with entry_id: {entry_id}")
                    sys.stdout.flush()
            
            print(f"[save_list_model_data] Saved {len(data)} entries successfully")
            sys.stdout.flush()
            return True
        else:
            print("[save_list_model_data] No data to save")
            sys.stdout.flush()
            return True
    except Exception as e:
        print(f"[save_list_model_data] Error: {e}")
        sys.stdout.flush()
        import traceback
        traceback.print_exc()
        return False


def load_list_model_data():
    """
    Load download history (compatibility with C++ API)
    Uses new entry-based storage architecture
    
    Returns:
        list: List of download items for QML ListModel
    """
    storage = get_storage_manager()
    
    # Load all entries from entry-based storage
    entries = storage.load_all_entries()
    print(f"[load_list_model_data] Loaded {len(entries)} entries")
    
    # Return empty list if no entries
    if not entries:
        return []
    
    # Ensure all items have required fields for QML
    for item in entries:
        # Ensure entryId exists
        if 'entryId' not in item:
            # Generate one if missing (for legacy entries)
            item['entryId'] = storage._generate_entry_id()
        
        # Set defaults for missing fields
        if 'vTitle' not in item:
            item['vTitle'] = item.get('title', '')
        if 'vThumbnail' not in item:
            item['vThumbnail'] = item.get('thumbnail', '')
        
        # Verify thumbnail path exists, use placeholder if not
        thumbnail = item.get('vThumbnail', '')
        if thumbnail and not thumbnail.startswith('qrc://'):
            if not os.path.exists(thumbnail):
                print(f"[load_list_model_data] Thumbnail not found: {thumbnail}, using placeholder")
                item['vThumbnail'] = 'qrc:///assets/placeholder-video.png'
        
        if 'vDuration' not in item:
            item['vDuration'] = item.get('duration', '')
        if 'vID' not in item:
            item['vID'] = item.get('videoUrl', item.get('url', ''))
        if 'vVideoProgress' not in item:
            item['vVideoProgress'] = 1.0  # Completed downloads
        if 'vIndex' not in item:
            item['vIndex'] = item.get('indexID', 0)
            
        # Ensure JSON string fields exist
        for field in ['vCodec', 'vResolutions', 'vVideoExts', 'vVideoFormats', 
                      'aCodec', 'vAudioExts', 'vAudioFormats', 'vABR', 'vAudioSizes', 'vSizeModel']:
            if field not in item:
                item[field] = '[]'
        
        # Ensure index fields exist and are integers
        if 'vVideoIndex' not in item:
            item['vVideoIndex'] = 0
        else:
            item['vVideoIndex'] = int(item['vVideoIndex']) if item['vVideoIndex'] is not None else 0
            
        if 'vAudioIndex' not in item:
            item['vAudioIndex'] = 0
        else:
            item['vAudioIndex'] = int(item['vAudioIndex']) if item['vAudioIndex'] is not None else 0
            
        if 'vIndex' not in item:
            item['vIndex'] = item.get('indexID', 0)
        # Ensure vIndex is integer
        item['vIndex'] = int(item['vIndex']) if item['vIndex'] is not None else 0
        
        # Ensure selected codec fields exist
        if 'selectedVideoCodec' not in item:
            item['selectedVideoCodec'] = ''
        if 'selectedAudioCodec' not in item:
            item['selectedAudioCodec'] = ''
    
    # Return entries in reverse order (newest first)
    return list(reversed(entries))


# Module-level function for QML to save single entry
def save_single_entry(entry_data):
    """
    Save or update a single entry (called from QML)
    
    Args:
        entry_data (dict): Entry data to save
        
    Returns:
        dict: Result with success status
    """
    storage = get_storage_manager()
    return storage.save_single_entry(entry_data)
