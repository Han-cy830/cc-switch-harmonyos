import { dbService } from './DatabaseService';
import { AppSettings } from '../model/Types';

export class SettingsService {
  private cache: AppSettings = new AppSettings();

  async load(): Promise<AppSettings> {
    const store = dbService.getStore();
    if (!store) return this.cache;
    try {
      const rs = await store.querySql("SELECT key, value FROM settings WHERE key LIKE 's_%'");
      while (rs.goToNextRow()) {
        const key = rs.getString(rs.getColumnIndex('key')).replace('s_', '');
        const val = rs.getString(rs.getColumnIndex('value'));
        if (key === 'language') this.cache.language = val;
        else if (key === 'theme') this.cache.theme = val;
        else if (key === 'launchOnStartup') this.cache.launchOnStartup = val === 'true';
        else if (key === 'silentStartup') this.cache.silentStartup = val === 'true';
        else if (key === 'minimizeToTray') this.cache.minimizeToTray = val === 'true';
        else if (key === 'showInTray') this.cache.showInTray = val === 'true';
        else if (key === 'enableLocalProxy') this.cache.enableLocalProxy = val === 'true';
        else if (key === 'proxyPort') this.cache.proxyPort = parseInt(val);
        else if (key === 'enableFailover') this.cache.enableFailover = val === 'true';
      }
      rs.close();
    } catch (e) {
      console.error('settings load failed: ' + JSON.stringify(e));
    }
    return this.cache;
  }

  async get(): Promise<AppSettings> {
    return this.cache;
  }

  async update(key: string, value: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      if (key === 'language') this.cache.language = value;
      else if (key === 'theme') this.cache.theme = value;
      else if (key === 'launchOnStartup') this.cache.launchOnStartup = value === 'true';
      else if (key === 'silentStartup') this.cache.silentStartup = value === 'true';
      else if (key === 'minimizeToTray') this.cache.minimizeToTray = value === 'true';
      else if (key === 'showInTray') this.cache.showInTray = value === 'true';
      else if (key === 'enableLocalProxy') this.cache.enableLocalProxy = value === 'true';
      else if (key === 'proxyPort') this.cache.proxyPort = parseInt(value);
      else if (key === 'enableFailover') this.cache.enableFailover = value === 'true';
      await store.executeSql('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', ['s_' + key, value]);
    } catch (e) {
      console.error('settings update failed: ' + JSON.stringify(e));
    }
  }
}

export const settingsService = new SettingsService();
