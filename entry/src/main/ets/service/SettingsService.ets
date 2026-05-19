import { dbService } from './DatabaseService';
import { AppSettings } from '../model/Types';

const DEFAULTS: AppSettings = {
  language: 'zh', theme: 'system', launchOnStartup: false, silentStartup: false,
  minimizeToTray: true, showInTray: true, enableLocalProxy: false, proxyPort: 15721,
  enableFailover: false, visibleApps: { claude: true, codex: true, gemini: true, opencode: true, openclaw: true, hermes: true }
};

export class SettingsService {
  private cache: AppSettings = { ...DEFAULTS };

  async load(): Promise<AppSettings> {
    const store = dbService.getStore();
    if (!store) return this.cache;
    try {
      const rs = await store.querySql("SELECT key, value FROM settings WHERE key LIKE 's_%'");
      while (rs.goToNextRow()) {
        const key = rs.getString(rs.getColumnIndex('key')).replace('s_', '');
        const val = rs.getString(rs.getColumnIndex('value'));
        try { (this.cache as Record<string, Object>)[key] = JSON.parse(val); } catch { (this.cache as Record<string, Object>)[key] = val; }
      }
      rs.close();
    } catch { /* use defaults */ }
    return this.cache;
  }

  async get(): Promise<AppSettings> { return this.cache; }

  async update(key: keyof AppSettings, value: Object): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    (this.cache as Record<string, Object>)[key] = value;
    const valStr = typeof value === 'string' ? value : JSON.stringify(value);
    await store.executeSql('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', [`s_${key}`, valStr]);
  }
}

export const settingsService = new SettingsService();
