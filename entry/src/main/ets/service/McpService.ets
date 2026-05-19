import { dbService } from './DatabaseService';
import { McpServer } from '../model/Types';

export class McpService {
  async getAll(): Promise<McpServer[]> {
    const store = dbService.getStore();
    if (!store) return [];
    const rs = await store.querySql('SELECT * FROM mcp_servers ORDER BY name ASC');
    const list: McpServer[] = [];
    while (rs.goToNextRow()) { list.push(this.row(rs)); }
    rs.close();
    return list;
  }

  async add(s: McpServer): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql(
      'INSERT INTO mcp_servers (id,name,transport,command,args,env,url,enabled,app_enabled,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
      [s.id, s.name, s.transport, s.command, JSON.stringify(s.args), JSON.stringify(s.env), s.url, s.enabled ? 1 : 0, JSON.stringify(s.appEnabled), now, now]
    );
  }

  async update(s: McpServer): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql(
      'UPDATE mcp_servers SET name=?,transport=?,command=?,args=?,env=?,url=?,enabled=?,app_enabled=?,updated_at=? WHERE id=?',
      [s.name, s.transport, s.command, JSON.stringify(s.args), JSON.stringify(s.env), s.url, s.enabled ? 1 : 0, JSON.stringify(s.appEnabled), now, s.id]
    );
  }

  async delete(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    await store.executeSql('DELETE FROM mcp_servers WHERE id=?', [id]);
  }

  async toggle(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    await store.executeSql('UPDATE mcp_servers SET enabled=CASE WHEN enabled=1 THEN 0 ELSE 1 END WHERE id=?', [id]);
  }

  private row(rs: relationalStore.ResultSet): McpServer {
    return {
      id: rs.getString(rs.getColumnIndex('id')),
      name: rs.getString(rs.getColumnIndex('name')),
      transport: rs.getString(rs.getColumnIndex('transport')) as 'stdio' | 'http' | 'sse',
      command: rs.getString(rs.getColumnIndex('command')),
      args: JSON.parse(rs.getString(rs.getColumnIndex('args')) || '[]'),
      env: JSON.parse(rs.getString(rs.getColumnIndex('env')) || '{}'),
      url: rs.getString(rs.getColumnIndex('url')),
      enabled: rs.getLong(rs.getColumnIndex('enabled')) === 1,
      appEnabled: JSON.parse(rs.getString(rs.getColumnIndex('app_enabled')) || '{}'),
      createdAt: rs.getString(rs.getColumnIndex('created_at')),
      updatedAt: rs.getString(rs.getColumnIndex('updated_at'))
    };
  }
}

export const mcpService = new McpService();
