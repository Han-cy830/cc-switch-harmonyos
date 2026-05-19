import { relationalStore } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const DB_NAME = 'cc_switch.db';

export class DatabaseService {
  private store: relationalStore.RdbStore | null = null;

  async init(context: common.UIAbilityContext): Promise<void> {
    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };
    this.store = await relationalStore.getRdbStore(context, config);
    await this.createTables();
    await this.seedDefaults();
  }

  private async createTables(): Promise<void> {
    if (!this.store) return;
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
  }

  private async seedDefaults(): Promise<void> {
    if (!this.store) return;
    const rs = await this.store.querySql('SELECT COUNT(*) as cnt FROM providers');
    let count = 0;
    if (rs.goToFirstRow()) { count = rs.getLong(rs.getColumnIndex('cnt')); }
    rs.close();
    if (count > 0) return;
    const now = new Date().toISOString();
    const defaults = [
      ['claude-official', 'claude', 'Anthropic (Official)', 'https://api.anthropic.com', 'claude-sonnet-4-20250514', 'official', '#FF6B35', 1],
      ['codex-official', 'codex', 'OpenAI (Official)', 'https://api.openai.com/v1', 'codex-mini', 'official', '#10A37F', 1],
      ['gemini-official', 'gemini', 'Google (Official)', 'https://generativelanguage.googleapis.com/v1beta', 'gemini-2.5-flash', 'official', '#4285F4', 1],
      ['opencode-default', 'opencode', 'Default', '', '', 'official', '#9C27B0', 1],
      ['openclaw-default', 'openclaw', 'Default', '', '', 'official', '#F44336', 1],
      ['hermes-default', 'hermes', 'Default', '', '', 'official', '#FFC107', 1]
    ];
    for (const p of defaults) {
      await this.store.executeSql(
        'INSERT INTO providers (id,app_type,name,base_url,model,category,color,is_current,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?)',
        [p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], now, now]
      );
    }
  }

  getStore(): relationalStore.RdbStore | null { return this.store; }
}

export const dbService = new DatabaseService();
