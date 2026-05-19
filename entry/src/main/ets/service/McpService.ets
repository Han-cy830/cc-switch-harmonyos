import { relationalStore } from '@kit.ArkData';
import { dbService } from './DatabaseService';
import { McpServer } from '../model/Types';

export class McpService {
  async getAll(): Promise<McpServer[]> {
    const store = dbService.getStore();
    if (!store) return [];
    const list: McpServer[] = [];
    try {
      const rs = await store.querySql('SELECT * FROM mcp_servers ORDER BY name ASC');
      while (rs.goToNextRow()) {
        list.push(this.row(rs));
      }
      rs.close();
    } catch (e) {
      console.error('mcp getAll failed: ' + JSON.stringify(e));
    }
    return list;
  }

  async add(s: McpServer): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql(
        'INSERT INTO mcp_servers (id,name,transport,command,args,env,url,enabled,app_enabled,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
        [s.id, s.name, s.transport, s.command, s.argsStr, s.envStr, s.url, s.enabled ? 1 : 0, s.appEnabledStr, now, now]
      );
    } catch (e) {
      console.error('mcp add failed: ' + JSON.stringify(e));
    }
  }

  async update(s: McpServer): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql(
        'UPDATE mcp_servers SET name=?,transport=?,command=?,args=?,env=?,url=?,enabled=?,app_enabled=?,updated_at=? WHERE id=?',
        [s.name, s.transport, s.command, s.argsStr, s.envStr, s.url, s.enabled ? 1 : 0, s.appEnabledStr, now, s.id]
      );
    } catch (e) {
      console.error('mcp update failed: ' + JSON.stringify(e));
    }
  }

  async delete(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      await store.executeSql('DELETE FROM mcp_servers WHERE id=?', [id]);
    } catch (e) {
      console.error('mcp delete failed: ' + JSON.stringify(e));
    }
  }

  async toggle(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      await store.executeSql('UPDATE mcp_servers SET enabled=CASE WHEN enabled=1 THEN 0 ELSE 1 END WHERE id=?', [id]);
    } catch (e) {
      console.error('mcp toggle failed: ' + JSON.stringify(e));
    }
  }

  private row(rs: relationalStore.ResultSet): McpServer {
    const s = new McpServer();
    s.id = rs.getString(rs.getColumnIndex('id'));
    s.name = rs.getString(rs.getColumnIndex('name'));
    s.transport = rs.getString(rs.getColumnIndex('transport'));
    s.command = rs.getString(rs.getColumnIndex('command'));
    s.argsStr = rs.getString(rs.getColumnIndex('args'));
    s.envStr = rs.getString(rs.getColumnIndex('env'));
    s.url = rs.getString(rs.getColumnIndex('url'));
    s.enabled = rs.getLong(rs.getColumnIndex('enabled')) === 1;
    s.appEnabledStr = rs.getString(rs.getColumnIndex('app_enabled'));
    s.createdAt = rs.getString(rs.getColumnIndex('created_at'));
    s.updatedAt = rs.getString(rs.getColumnIndex('updated_at'));
    return s;
  }
}

export const mcpService = new McpService();
