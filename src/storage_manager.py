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
        self.history_file = os.path.join(self.config_dir, 'history.json')
        self.settings_file = os.path.join(self.config_dir, 'settings.json')
        
        # Ensure config directory exists
        os.makedirs(self.config_dir, exist_ok=True)
    
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
    
    def save_download_history(self, history_data):
        """
        Save download history to file
        
        Args:
            history_data (list): List of download items
            
        Returns:
            bool: True if successful, False otherwise
        """
        try:
            with open(self.history_file, 'w', encoding='utf-8') as f:
                json.dump(history_data, f, indent=2, ensure_ascii=False)
            return True
        except Exception as e:
            print(f"Error saving download history: {e}")
            return False
    
    def load_download_history(self):
        """
        Load download history from file
        
        Returns:
            list: List of download items, empty list if file doesn't exist
        """
        try:
            if os.path.exists(self.history_file):
                with open(self.history_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            return []
        except Exception as e:
            print(f"Error loading download history: {e}")
            return []
    
    def add_download_entry(self, entry):
        """
        Add a single download entry to history
        
        Args:
            entry (dict): Download entry data
            
        Returns:
            bool: True if successful
        """
        history = self.load_download_history()
        history.append(entry)
        return self.save_download_history(history)
    
    def clear_download_history(self):
        """
        Clear all download history
        
        Returns:
            bool: True if successful
        """
        return self.save_download_history([])
    
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
        Get default download path
        
        Returns:
            str: Download directory path
        """
        # Try XDG downloads directory
        downloads = os.path.join(Path.home(), 'Downloads')
        if os.path.exists(downloads):
            return downloads
        
        # Fallback to home directory
        return str(Path.home())


# Module-level convenience functions
_storage = None

def get_storage_manager():
    """Get singleton storage manager instance"""
    global _storage
    if _storage is None:
        _storage = StorageManager()
    return _storage


def save_list_model_data(data):
    """Save download history (compatibility with C++ API)"""
    storage = get_storage_manager()
    return storage.save_download_history(data)


def load_list_model_data():
    """Load download history (compatibility with C++ API)"""
    storage = get_storage_manager()
    return storage.load_download_history()
