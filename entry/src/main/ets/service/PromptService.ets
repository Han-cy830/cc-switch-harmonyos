import { relationalStore } from '@kit.ArkData';
import { dbService } from './DatabaseService';
import { Prompt, AppId } from '../model/Types';

export class PromptService {
  async getByApp(appType: AppId): Promise<Prompt[]> {
    const store = dbService.getStore();
    if (!store) return [];
    const list: Prompt[] = [];
    try {
      const rs = await store.querySql('SELECT * FROM prompts WHERE app_type = ? ORDER BY sort_order ASC', [appType]);
      while (rs.goToNextRow()) {
        list.push(this.row(rs));
      }
      rs.close();
    } catch (e) {
      console.error('prompt getByApp failed: ' + JSON.stringify(e));
    }
    return list;
  }

  async add(p: Prompt): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql(
        'INSERT INTO prompts (id,app_type,name,content,enabled,sort_order,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?)',
        [p.id, p.appType, p.name, p.content, p.enabled ? 1 : 0, p.sortOrder, now, now]
      );
    } catch (e) {
      console.error('prompt add failed: ' + JSON.stringify(e));
    }
  }

  async update(p: Prompt): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql('UPDATE prompts SET name=?,content=?,enabled=?,updated_at=? WHERE id=?',
        [p.name, p.content, p.enabled ? 1 : 0, now, p.id]);
    } catch (e) {
      console.error('prompt update failed: ' + JSON.stringify(e));
    }
  }

  async delete(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      await store.executeSql('DELETE FROM prompts WHERE id=?', [id]);
    } catch (e) {
      console.error('prompt delete failed: ' + JSON.stringify(e));
    }
  }

  async toggle(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      await store.executeSql('UPDATE prompts SET enabled=CASE WHEN enabled=1 THEN 0 ELSE 1 END WHERE id=?', [id]);
    } catch (e) {
      console.error('prompt toggle failed: ' + JSON.stringify(e));
    }
  }

  private row(rs: relationalStore.ResultSet): Prompt {
    const p = new Prompt();
    p.id = rs.getString(rs.getColumnIndex('id'));
    p.appType = rs.getString(rs.getColumnIndex('app_type')) as AppId;
    p.name = rs.getString(rs.getColumnIndex('name'));
    p.content = rs.getString(rs.getColumnIndex('content'));
    p.enabled = rs.getLong(rs.getColumnIndex('enabled')) === 1;
    p.sortOrder = rs.getLong(rs.getColumnIndex('sort_order'));
    p.createdAt = rs.getString(rs.getColumnIndex('created_at'));
    p.updatedAt = rs.getString(rs.getColumnIndex('updated_at'));
    return p;
  }
}

export const promptService = new PromptService();
