import { dbService } from './DatabaseService';
import { Prompt, AppId } from '../model/Types';

export class PromptService {
  async getByApp(appType: AppId): Promise<Prompt[]> {
    const store = dbService.getStore();
    if (!store) return [];
    const rs = await store.querySql('SELECT * FROM prompts WHERE app_type = ? ORDER BY sort_order ASC', [appType]);
    const list: Prompt[] = [];
    while (rs.goToNextRow()) { list.push(this.row(rs)); }
    rs.close();
    return list;
  }

  async add(p: Prompt): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql(
      'INSERT INTO prompts (id,app_type,name,content,enabled,sort_order,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?)',
      [p.id, p.appType, p.name, p.content, p.enabled ? 1 : 0, p.sortOrder, now, now]
    );
  }

  async update(p: Prompt): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql('UPDATE prompts SET name=?,content=?,enabled=?,updated_at=? WHERE id=?',
      [p.name, p.content, p.enabled ? 1 : 0, now, p.id]);
  }

  async delete(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    await store.executeSql('DELETE FROM prompts WHERE id=?', [id]);
  }

  async toggle(id: string): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    await store.executeSql('UPDATE prompts SET enabled=CASE WHEN enabled=1 THEN 0 ELSE 1 END WHERE id=?', [id]);
  }

  private row(rs: relationalStore.ResultSet): Prompt {
    return {
      id: rs.getString(rs.getColumnIndex('id')),
      appType: rs.getString(rs.getColumnIndex('app_type')) as AppId,
      name: rs.getString(rs.getColumnIndex('name')),
      content: rs.getString(rs.getColumnIndex('content')),
      enabled: rs.getLong(rs.getColumnIndex('enabled')) === 1,
      sortOrder: rs.getLong(rs.getColumnIndex('sort_order')),
      createdAt: rs.getString(rs.getColumnIndex('created_at')),
      updatedAt: rs.getString(rs.getColumnIndex('updated_at'))
    };
  }
}

export const promptService = new PromptService();
