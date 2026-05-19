import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { getAllPresets, ProviderPreset } from '../model/ProviderPresets';
import { AppId } from '../model/Types';

const DB_NAME = 'cc_switch.db';

export class DatabaseService {
  private store: relationalStore.RdbStore | null = null;

  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.store = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      await this.seedDefaults();
    } catch (e) {
      console.error('DatabaseService init failed: ' + JSON.stringify(e));
    }
  }

  private async createTables(): Promise<void> {
    if (!this.store) return;
    try {
      await this.store.executeSql(`CREATE TABLE IF NOT EXISTS providers (
        id TEXT NOT NULL, app_type TEXT NOT NULL, name TEXT NOT NULL,
        base_url TEXT DEFAULT '', api_key TEXT DEFAULT '', model TEXT DEFAULT '',
        category TEXT DEFAULT 'custom', icon_url TEXT DEFAULT '', color TEXT DEFAULT '',
        is_current INTEGER DEFAULT 0, sort_order INTEGER DEFAULT 0,
        created_at TEXT DEFAULT '', updated_at TEXT DEFAULT '',
        max_tokens INTEGER DEFAULT 4096, temperature REAL DEFAULT 1.0,
        top_p REAL DEFAULT 1.0, system_prompt TEXT DEFAULT '',
        custom_headers TEXT DEFAULT '{}', usage_script TEXT DEFAULT '',
        PRIMARY KEY (id, app_type)
      )`);
      await this.store.executeSql(`CREATE TABLE IF NOT EXISTS mcp_servers (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, transport TEXT DEFAULT 'stdio',
        command TEXT DEFAULT '', args TEXT DEFAULT '[]', env TEXT DEFAULT '{}',
        url TEXT DEFAULT '', enabled INTEGER DEFAULT 1, app_enabled TEXT DEFAULT '{}',
        created_at TEXT DEFAULT '', updated_at TEXT DEFAULT ''
      )`);
      await this.store.executeSql(`CREATE TABLE IF NOT EXISTS prompts (
        id TEXT PRIMARY KEY, app_type TEXT NOT NULL, name TEXT NOT NULL,
        content TEXT DEFAULT '', enabled INTEGER DEFAULT 1,
        sort_order INTEGER DEFAULT 0, created_at TEXT DEFAULT '', updated_at TEXT DEFAULT ''
      )`);
      await this.store.executeSql(`CREATE TABLE IF NOT EXISTS skills (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT DEFAULT '',
        source TEXT DEFAULT '', version TEXT DEFAULT '',
        installed_at TEXT DEFAULT '', app_enabled TEXT DEFAULT '{}'
      )`);
      await this.store.executeSql(`CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY, value TEXT NOT NULL
      )`);
    } catch (e) {
      console.error('createTables failed: ' + JSON.stringify(e));
    }
  }

  private async seedDefaults(): Promise<void> {
    if (!this.store) return;
    try {
      const rs = await this.store.querySql('SELECT COUNT(*) as cnt FROM providers');
      let count = 0;
      if (rs.goToFirstRow()) {
        count = rs.getLong(rs.getColumnIndex('cnt'));
      }
      rs.close();
      if (count > 0) return;
      const now = new Date().toISOString();
      const presets = getAllPresets();
      for (let i = 0; i < presets.length; i++) {
        const p = presets[i];
        const isFirst = (p.id.endsWith('-official') || p.id.endsWith('-default')) ? 1 : 0;
        await this.store.executeSql(
          'INSERT INTO providers (id,app_type,name,base_url,model,category,color,is_current,sort_order,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
          [p.id, p.appType, p.name, p.baseUrl, p.model, p.category, p.color, isFirst, i, now, now]
        );
      }
    } catch (e) {
      console.error('seedDefaults failed: ' + JSON.stringify(e));
    }
  }

  getStore(): relationalStore.RdbStore | null {
    return this.store;
  }
}

export const dbService = new DatabaseService();
