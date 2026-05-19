import { relationalStore } from '@kit.ArkData';
import { dbService } from './DatabaseService';
import { Provider, AppId, ProviderCategory } from '../model/Types';

export class ProviderService {
  async getByApp(appType: AppId): Promise<Provider[]> {
    const store = dbService.getStore();
    if (!store) return [];
    const list: Provider[] = [];
    try {
      const rs = await store.querySql('SELECT * FROM providers WHERE app_type = ? ORDER BY sort_order ASC', [appType]);
      while (rs.goToNextRow()) {
        list.push(this.rowToProvider(rs));
      }
      rs.close();
    } catch (e) {
      console.error('getByApp failed: ' + JSON.stringify(e));
    }
    return list;
  }

  async getCurrent(appType: AppId): Promise<Provider | null> {
    const store = dbService.getStore();
    if (!store) return null;
    try {
      const rs = await store.querySql('SELECT * FROM providers WHERE app_type = ? AND is_current = 1 LIMIT 1', [appType]);
      if (rs.goToFirstRow()) {
        const p = this.rowToProvider(rs);
        rs.close();
        return p;
      }
      rs.close();
    } catch (e) {
      console.error('getCurrent failed: ' + JSON.stringify(e));
    }
    return null;
  }

  async add(provider: Provider): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql(
        'INSERT INTO providers (id,app_type,name,base_url,api_key,model,category,icon_url,color,is_current,sort_order,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)',
        [provider.id, provider.appType, provider.name, provider.baseUrl, provider.apiKey,
          provider.model, provider.category, provider.iconUrl, provider.color,
          provider.isCurrent ? 1 : 0, provider.sortOrder, now, now]
      );
    } catch (e) {
      console.error('add provider failed: ' + JSON.stringify(e));
    }
  }

  async update(provider: Provider): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql(
        'UPDATE providers SET name=?,base_url=?,api_key=?,model=?,category=?,icon_url=?,color=?,is_current=?,updated_at=? WHERE id=? AND app_type=?',
        [provider.name, provider.baseUrl, provider.apiKey, provider.model,
          provider.category, provider.iconUrl, provider.color,
          provider.isCurrent ? 1 : 0, now, provider.id, provider.appType]
      );
    } catch (e) {
      console.error('update provider failed: ' + JSON.stringify(e));
    }
  }

  async delete(id: string, appType: AppId): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      await store.executeSql('DELETE FROM providers WHERE id=? AND app_type=?', [id, appType]);
    } catch (e) {
      console.error('delete provider failed: ' + JSON.stringify(e));
    }
  }

  async switchTo(id: string, appType: AppId): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const now = new Date().toISOString();
      await store.executeSql('UPDATE providers SET is_current=0,updated_at=? WHERE app_type=?', [now, appType]);
      await store.executeSql('UPDATE providers SET is_current=1,updated_at=? WHERE id=? AND app_type=?', [now, id, appType]);
    } catch (e) {
      console.error('switchTo failed: ' + JSON.stringify(e));
    }
  }

  async duplicate(id: string, appType: AppId): Promise<Provider | null> {
    const store = dbService.getStore();
    if (!store) return null;
    try {
      const rs = await store.querySql('SELECT * FROM providers WHERE id=? AND app_type=?', [id, appType]);
      if (!rs.goToFirstRow()) {
        rs.close();
        return null;
      }
      const orig = this.rowToProvider(rs);
      rs.close();
      const np = new Provider();
      np.id = appType + '-' + Date.now().toString();
      np.appType = orig.appType;
      np.name = orig.name + ' (Copy)';
      np.baseUrl = orig.baseUrl;
      np.apiKey = orig.apiKey;
      np.model = orig.model;
      np.category = orig.category;
      np.color = orig.color;
      np.isCurrent = false;
      np.sortOrder = orig.sortOrder + 1;
      await this.add(np);
      return np;
    } catch (e) {
      console.error('duplicate failed: ' + JSON.stringify(e));
    }
    return null;
  }

  private rowToProvider(rs: relationalStore.ResultSet): Provider {
    const p = new Provider();
    p.id = rs.getString(rs.getColumnIndex('id'));
    p.appType = rs.getString(rs.getColumnIndex('app_type')) as AppId;
    p.name = rs.getString(rs.getColumnIndex('name'));
    p.baseUrl = rs.getString(rs.getColumnIndex('base_url'));
    p.apiKey = rs.getString(rs.getColumnIndex('api_key'));
    p.model = rs.getString(rs.getColumnIndex('model'));
    p.category = rs.getString(rs.getColumnIndex('category')) as string as ProviderCategory;
    p.iconUrl = rs.getString(rs.getColumnIndex('icon_url'));
    p.color = rs.getString(rs.getColumnIndex('color'));
    p.isCurrent = rs.getLong(rs.getColumnIndex('is_current')) === 1;
    p.sortOrder = rs.getLong(rs.getColumnIndex('sort_order'));
    p.createdAt = rs.getString(rs.getColumnIndex('created_at'));
    p.updatedAt = rs.getString(rs.getColumnIndex('updated_at'));
    return p;
  }
}

export const providerService = new ProviderService();
