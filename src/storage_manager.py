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

import json
import os
import random
import sys
import time
from pathlib import Path

class StorageManager:
    """
    Manages persistent storage for download history, settings, and thumbnail caching.
    
    Implements entry-based storage architecture where each download gets a unique
    directory with metadata and associated assets (thumbnails). Uses JSON index
    for efficient listing and lookup.
    """
    
    def __init__(self, app_name='raven.downloader.shohag'):
        """
        Initialize storage manager with configuration paths.
        
        Args:
            app_name: Application identifier for config directory structure
        """
        self.app_name = app_name
        self.config_dir = self._get_config_dir()
        self.index_file = os.path.join(self.config_dir, 'index.json')
        self.entries_dir = os.path.join(self.config_dir, 'entries')
        self.settings_file = os.path.join(self.config_dir, 'settings.json')
        
        print(f"[StorageManager] Config directory: {self.config_dir}")
        sys.stdout.flush()
        print(f"[StorageManager] Index file: {self.index_file}")
        sys.stdout.flush()
        print(f"[StorageManager] Entries directory: {self.entries_dir}")
        sys.stdout.flush()
        print(f"[StorageManager] Settings file: {self.settings_file}")
        sys.stdout.flush()
        
        os.makedirs(self.config_dir, exist_ok=True)
        os.makedirs(self.entries_dir, exist_ok=True)
    
    def _get_config_dir(self):
        """
        Determine XDG-compliant configuration directory path.
        
        Returns:
            Path string to application config directory, prioritizing XDG_CONFIG_HOME
        """
        xdg_config = os.environ.get('XDG_CONFIG_HOME')
        if xdg_config:
            return os.path.join(xdg_config, self.app_name)
        
        return os.path.join(Path.home(), '.config', self.app_name)
    
    def _generate_entry_id(self):
        """
        Generate unique entry identifier using timestamp and random component.
        
        Returns:
            Unique entry ID string with format 'entry_{timestamp_ms}_{random}'
        """
        timestamp = int(time.time() * 1000)
        rand = random.randint(1000, 9999)
        return f"entry_{timestamp}_{rand}"
    
    def save_download_history(self, history_data):
        """
        DEPRECATED: Backwards compatibility stub for legacy API.
        
        Use entry-based storage via save_entry() instead. This method exists
        only for backwards compatibility and performs no operation.
        
        Args:
            history_data: Legacy download items list (ignored)
            
        Returns:
            True (always succeeds as operation is deprecated)
        """
        print(f"[StorageManager] save_download_history is deprecated - use entry-based storage")
        return True
    
    def load_download_history(self):
        """
        DEPRECATED: Backwards compatibility wrapper for legacy API.
        
        Use load_all_entries() instead. This method delegates to the new API
        to maintain backwards compatibility with existing code.
        
        Returns:
            List of all download entries from entry-based storage
        """
        print(f"[StorageManager] load_download_history is deprecated - using load_all_entries()")
        return self.load_all_entries()
    
    def add_download_entry(self, entry):
        """
        Add single download entry to persistent storage.
        
        Delegates to entry-based storage system using save_entry().
        
        Args:
            entry: Download entry data dictionary
            
        Returns:
            True if save successful, False otherwise
        """
        entry_id = self.save_entry(entry)
        return entry_id is not None
    
    def clear_download_history(self):
        """
        Delete all download history from entry-based storage.
        
        Removes all entry directories and clears the index file. This is
        a destructive operation that cannot be undone.
        
        Returns:
            True if successful, False on error
        """
        try:
            if os.path.exists(self.index_file):
                with open(self.index_file, 'w', encoding='utf-8') as f:
                    json.dump([], f)
            
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
        Persist application settings to JSON file.
        
        Args:
            settings: Settings dictionary to save
            
        Returns:
            True if successful, False on error
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
        Load application settings from JSON file.
        
        Returns:
            Settings dictionary, or empty dict if file does not exist
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
        Get writable download directory path for temporary storage.
        
        On Ubuntu Touch, apps can only write to their cache directory.
        Downloaded files are stored here temporarily before being exported
        via ContentHub to user-accessible storage.
        
        Returns:
            Path string to application cache downloads directory
        """
        xdg_cache = os.environ.get('XDG_CACHE_HOME')
        if xdg_cache:
            cache_downloads = os.path.join(xdg_cache, self.app_name, 'downloads')
        else:
            cache_downloads = os.path.join(Path.home(), '.cache', self.app_name, 'downloads')
        
        os.makedirs(cache_downloads, exist_ok=True)
        print(f"[StorageManager] Download path: {cache_downloads}")
        
        return cache_downloads
    
    def get_thumbnails_path(self):
        """
        Get XDG-compliant thumbnails cache directory path.
        
        Returns:
            Path string to application thumbnails cache directory
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
        Download and cache thumbnail image to local storage.
        
        Supports both entry-based storage (when entry_id provided) and legacy
        global thumbnails directory. Checks for existing cached copies before
        downloading.
        
        Args:
            thumbnail_url: Remote thumbnail URL
            video_id: Video identifier for filename generation
            entry_id: Optional entry ID to store in entry-specific directory
            
        Returns:
            Local file path to cached thumbnail, or original URL on failure
        """
        if not thumbnail_url or not video_id:
            return thumbnail_url
        
        try:
            import urllib.request
            import hashlib
            
            ext = '.jpg'
            if '.png' in thumbnail_url.lower():
                ext = '.png'
            elif '.webp' in thumbnail_url.lower():
                ext = '.webp'
            
            if entry_id:
                entry_dir = os.path.join(self.entries_dir, entry_id)
                os.makedirs(entry_dir, exist_ok=True)
                thumbnail_path = os.path.join(entry_dir, f"thumbnail{ext}")
            else:
                safe_id = hashlib.md5(video_id.encode()).hexdigest()
                thumbnail_filename = f"{safe_id}{ext}"
                thumbnail_path = os.path.join(self.get_thumbnails_path(), thumbnail_filename)
            
            if os.path.exists(thumbnail_path):
                print(f"[StorageManager] Using cached thumbnail: {thumbnail_path}")
                return thumbnail_path
            
            print(f"[StorageManager] Downloading thumbnail from: {thumbnail_url}")
            urllib.request.urlretrieve(thumbnail_url, thumbnail_path)
            print(f"[StorageManager] Thumbnail saved to: {thumbnail_path}")
            
            return thumbnail_path
            
        except Exception as e:
            print(f"[StorageManager] Error downloading thumbnail: {e}")
            return thumbnail_url
    
    def save_entry(self, entry_data):
        """
        Save download entry with dedicated directory for metadata and assets.
        
        Creates entry directory, saves metadata JSON, and updates index for
        efficient listing. Generates unique entry ID if not provided.
        
        Args:
            entry_data: Entry metadata dictionary including all download information
            
        Returns:
            Entry ID string if successful, None on error
        """
        try:
            print(f"[StorageManager] save_entry called with data: {list(entry_data.keys()) if entry_data else 'None'}")
            sys.stdout.flush()
            
            entry_id = entry_data.get('entryId')
            if not entry_id:
                entry_id = self._generate_entry_id()
                entry_data['entryId'] = entry_id
                print(f"[StorageManager] Generated new entry_id: {entry_id}")
                sys.stdout.flush()
            else:
                print(f"[StorageManager] Using existing entry_id: {entry_id}")
                sys.stdout.flush()
            
            entry_dir = os.path.join(self.entries_dir, entry_id)
            os.makedirs(entry_dir, exist_ok=True)
            print(f"[StorageManager] Entry directory created/verified: {entry_dir}")
            sys.stdout.flush()
            
            entry_file = os.path.join(entry_dir, 'metadata.json')
            with open(entry_file, 'w', encoding='utf-8') as f:
                json.dump(entry_data, f, indent=2, ensure_ascii=False)
            
            print(f"[StorageManager] Entry metadata saved to: {entry_file}")
            sys.stdout.flush()
            
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
        QML-accessible wrapper for saving individual entry.
        
        Provides result dictionary with success status for QML error handling.
        
        Args:
            entry_data: Entry metadata to save
            
        Returns:
            Dictionary with 'success' boolean and 'entryId' or 'error' message
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
        Update central index with entry summary for efficient listing.
        
        Maintains lightweight index file containing essential fields only,
        preventing duplicates by checking both entry ID and video ID.
        
        Args:
            entry_id: Unique entry identifier
            entry_data: Full entry metadata dictionary
        """
        try:
            print(f"[StorageManager] _update_index called for: {entry_id}")
            sys.stdout.flush()
            print(f"[StorageManager] Index file path: {self.index_file}")
            sys.stdout.flush()
            
            index = self.load_index()
            print(f"[StorageManager] Current index has {len(index)} entries")
            sys.stdout.flush()
            
            index_entry = {
                'entryId': entry_id,
                'vTitle': entry_data.get('vTitle', ''),
                'vID': entry_data.get('vID', ''),
                'timestamp': int(entry_data.get('timestamp', 0)),
                'vIndex': int(entry_data.get('vIndex', 0))
            }
            
            if not index_entry['vTitle'] and not index_entry['vID']:
                print(f"[StorageManager] Skipping index update for empty entry: {entry_id}")
                sys.stdout.flush()
                return
            
            existing_index = next((i for i, e in enumerate(index) if e.get('entryId') == entry_id), None)
            
            if existing_index is None and index_entry['vID']:
                duplicate_index = next((i for i, e in enumerate(index) if e.get('vID') == index_entry['vID'] and e.get('vID') != ''), None)
                if duplicate_index is not None:
                    print(f"[StorageManager] Found duplicate vID at index {duplicate_index}, updating instead")
                    sys.stdout.flush()
                    existing_index = duplicate_index
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
            
            os.makedirs(os.path.dirname(self.index_file), exist_ok=True)
            
            print(f"[StorageManager] Writing index to: {self.index_file}")
            sys.stdout.flush()
            with open(self.index_file, 'w', encoding='utf-8') as f:
                json.dump(index, f, indent=2, ensure_ascii=False)
            
            print(f"[StorageManager] Index successfully written with {len(index)} entries")
            sys.stdout.flush()
            
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
        Load central index of all entry summaries.
        
        Returns:
            List of entry summary dictionaries, or empty list if index does not exist
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
        Load complete entry metadata from directory.
        
        Args:
            entry_id: Entry identifier to load
            
        Returns:
            Entry data dictionary, or None if entry does not exist
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
        Load complete metadata for all entries.
        
        Reads index for entry IDs, then loads full data from each entry directory.
        
        Returns:
            List of all entry data dictionaries
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


_storage = None

def get_storage_manager():
    """
    Retrieve singleton StorageManager instance.
    
    Returns:
        Global StorageManager instance, creating it if necessary
    """
    global _storage
    if _storage is None:
        _storage = StorageManager()
    return _storage


def save_list_model_data(data):
    """
    Save QML ListModel data to entry-based storage.
    
    QML-accessible function providing backwards compatibility with C++ API.
    Handles PyOtherSide QObject conversion to Python dictionaries. Each list
    item is saved as a separate entry.
    
    Args:
        data: List of download items from QML ListModel (may be PyOtherSide QObjects)
        
    Returns:
        True if successful, False on error
    """
    storage = get_storage_manager()
    print(f"[save_list_model_data] Called with {len(data) if data else 0} items")
    sys.stdout.flush()
    
    try:
        if data:
            print(f"[save_list_model_data] Data type: {type(data)}")
            sys.stdout.flush()
            
            for idx, item in enumerate(data):
                print(f"[save_list_model_data] Item {idx} type: {type(item)}, value: {item}")
                sys.stdout.flush()
                
                item_dict = {}
                
                type_str = str(type(item))
                if 'pyotherside' in type_str.lower() or 'qobject' in type_str.lower():
                    print(f"[save_list_model_data] Converting PyOtherSide QObject to dict")
                    sys.stdout.flush()
                    
                    try:
                        expected_keys = [
                            'entryId', 'vTitle', 'vThumbnail', 'vDuration', 'vID',
                            'vCodec', 'vResolutions', 'vVideoExts', 'vVideoFormats', 'vVideoProgress',
                            'aCodec', 'vAudioExts', 'vAudioFormats', 'vABR', 'vAudioSizes',
                            'vVideoIndex', 'vAudioIndex', 'selectedVideoCodec', 'selectedAudioCodec',
                            'vSizeModel', 'vIndex', 'timestamp'
                        ]
                        
                        for key in expected_keys:
                            try:
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
                    try:
                        item_dict = dict(item)
                    except:
                        print(f"[save_list_model_data] Warning: Could not convert item {idx} to dict, type was: {type_str}")
                        sys.stdout.flush()
                        continue
                
                if item_dict:
                    print(f"[save_list_model_data] Processing item {idx}: entryId={item_dict.get('entryId', 'NO_ID')}, title={item_dict.get('vTitle', 'NO_TITLE')[:30]}")
                    sys.stdout.flush()
                    
                    if not item_dict.get('vTitle') and not item_dict.get('vID'):
                        print(f"[save_list_model_data] Skipping empty entry at index {idx}")
                        sys.stdout.flush()
                        continue
                    
                    for int_field in ['vVideoIndex', 'vAudioIndex', 'vIndex', 'timestamp']:
                        if int_field in item_dict and item_dict[int_field] is not None:
                            try:
                                item_dict[int_field] = int(item_dict[int_field])
                            except (ValueError, TypeError):
                                item_dict[int_field] = 0
                    
                    if 'timestamp' not in item_dict:
                        item_dict['timestamp'] = int(time.time() * 1000)
                    
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
    Load download history for QML ListModel.
    
    QML-accessible function providing backwards compatibility with C++ API.
    Ensures all required fields exist with proper defaults and validates
    thumbnail paths before returning.
    
    Returns:
        List of download entry dictionaries in reverse chronological order
    """
    storage = get_storage_manager()
    
    entries = storage.load_all_entries()
    print(f"[load_list_model_data] Loaded {len(entries)} entries")
    
    if not entries:
        return []
    
    for item in entries:
        if 'entryId' not in item:
            item['entryId'] = storage._generate_entry_id()
        
        if 'vTitle' not in item:
            item['vTitle'] = item.get('title', '')
        if 'vThumbnail' not in item:
            item['vThumbnail'] = item.get('thumbnail', '')
        
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
            item['vVideoProgress'] = 1.0
        if 'vIndex' not in item:
            item['vIndex'] = item.get('indexID', 0)
            
        for field in ['vCodec', 'vResolutions', 'vVideoExts', 'vVideoFormats', 
                      'aCodec', 'vAudioExts', 'vAudioFormats', 'vABR', 'vAudioSizes', 'vSizeModel']:
            if field not in item:
                item[field] = '[]'
        
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
        item['vIndex'] = int(item['vIndex']) if item['vIndex'] is not None else 0
        
        if 'selectedVideoCodec' not in item:
            item['selectedVideoCodec'] = ''
        if 'selectedAudioCodec' not in item:
            item['selectedAudioCodec'] = ''
    
    return list(reversed(entries))


def save_single_entry(entry_data):
    """
    Save or update individual entry from QML.
    
    QML-accessible wrapper for entry save operation.
    
    Args:
        entry_data: Entry metadata dictionary
        
    Returns:
        Dictionary with success status, entry ID, or error message
    """
    storage = get_storage_manager()
    return storage.save_single_entry(entry_data)
