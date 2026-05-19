import { dbService } from './DatabaseService';
import { Provider, AppId } from '../model/Types';

export class ProviderService {
  async getByApp(appType: AppId): Promise<Provider[]> {
    const store = dbService.getStore();
    if (!store) return [];
    const rs = await store.querySql('SELECT * FROM providers WHERE app_type = ? ORDER BY sort_order ASC', [appType]);
    const list: Provider[] = [];
    while (rs.goToNextRow()) { list.push(this.rowToProvider(rs)); }
    rs.close();
    return list;
  }

  async getCurrent(appType: AppId): Promise<Provider | null> {
    const store = dbService.getStore();
    if (!store) return null;
    const rs = await store.querySql('SELECT * FROM providers WHERE app_type = ? AND is_current = 1 LIMIT 1', [appType]);
    let p: Provider | null = null;
    if (rs.goToFirstRow()) { p = this.rowToProvider(rs); }
    rs.close();
    return p;
  }

  async add(provider: Provider): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql(
      'INSERT INTO providers (id,app_type,name,base_url,api_key,model,category,icon_url,color,is_current,sort_order,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [provider.id, provider.appType, provider.name, provider.baseUrl, provider.apiKey, provider.model, provider.category, provider.iconUrl, provider.color, provider.isCurrent ? 1 : 0, provider.sortOrder, now, now]
    );
  }

  async update(provider: Provider): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql(
      'UPDATE providers SET name=?,base_url=?,api_key=?,model=?,category=?,icon_url=?,color=?,is_current=?,updated_at=? WHERE id=? AND app_type=?',
      [provider.name, provider.baseUrl, provider.apiKey, provider.model, provider.category, provider.iconUrl, provider.color, provider.isCurrent ? 1 : 0, now, provider.id, provider.appType]
    );
  }

  async delete(id: string, appType: AppId): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    await store.executeSql('DELETE FROM providers WHERE id=? AND app_type=?', [id, appType]);
  }

  async switchTo(id: string, appType: AppId): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    const now = new Date().toISOString();
    await store.executeSql('UPDATE providers SET is_current=0,updated_at=? WHERE app_type=?', [now, appType]);
    await store.executeSql('UPDATE providers SET is_current=1,updated_at=? WHERE id=? AND app_type=?', [now, id, appType]);
  }

  async duplicate(id: string, appType: AppId): Promise<Provider | null> {
    const store = dbService.getStore();
    if (!store) return null;
    const rs = await store.querySql('SELECT * FROM providers WHERE id=? AND app_type=?', [id, appType]);
    if (!rs.goToFirstRow()) { rs.close(); return null; }
    const orig = this.rowToProvider(rs);
    rs.close();
    const np: Provider = { ...orig, id: `${appType}-${Date.now()}`, name: `${orig.name} (Copy)`, isCurrent: false };
    await this.add(np);
    return np;
  }

  private rowToProvider(rs: relationalStore.ResultSet): Provider {
    return {
      id: rs.getString(rs.getColumnIndex('id')),
      appType: rs.getString(rs.getColumnIndex('app_type')) as AppId,
      name: rs.getString(rs.getColumnIndex('name')),
      baseUrl: rs.getString(rs.getColumnIndex('base_url')),
      apiKey: rs.getString(rs.getColumnIndex('api_key')),
      model: rs.getString(rs.getColumnIndex('model')),
      category: rs.getString(rs.getColumnIndex('category')) as Provider['category'],
      iconUrl: rs.getString(rs.getColumnIndex('icon_url')),
      color: rs.getString(rs.getColumnIndex('color')),
      isCurrent: rs.getLong(rs.getColumnIndex('is_current')) === 1,
      sortOrder: rs.getLong(rs.getColumnIndex('sort_order')),
      createdAt: rs.getString(rs.getColumnIndex('created_at')),
      updatedAt: rs.getString(rs.getColumnIndex('updated_at')),
      maxTokens: 4096, temperature: 1.0, topP: 1.0,
      systemPrompt: '', customHeaders: {}, usageScript: ''
    };
  }
}

export const providerService = new ProviderService();
