import { Provider, AppId, APP_CONFIGS } from '../model/Types';
import { providerService } from '../service/ProviderService';

@Component
export struct ProviderPage {
  @Prop currentApp: AppId = 'claude';
  @State providers: Provider[] = [];
  @State showDialog: boolean = false;
  @State editItem: Provider | null = null;

  aboutToAppear(): void { this.loadData(); }

  async loadData(): Promise<void> { this.providers = await providerService.getByApp(this.currentApp); }

  private getAppCfg(): AppConfig { return APP_CONFIGS.find((a) => a.appId === this.currentApp) || APP_CONFIGS[0]; }

  build() {
    Column() {
      // 头部
      Row() {
        Column() {
          Text(`${this.getAppCfg().icon} ${this.getAppCfg().label}`).fontSize(22).fontWeight(FontWeight.Bold)
          Text(this.getAppCfg().description).fontSize(13).fontColor('#999').margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Button('+ 添加提供商').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF')
          .onClick(() => { this.editItem = null; this.showDialog = true; })
      }.width('100%').padding({ left: 24, right: 24, top: 20, bottom: 16 })

      // 列表
      if (this.providers.length === 0) {
        Column() {
          Text('暂无提供商').fontSize(16).fontColor('#999')
          Button('添加第一个提供商').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF').margin({ top: 16 })
            .onClick(() => { this.showDialog = true; })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.providers, (p: Provider) => {
            ListItem() {
              Row() {
                Circle({ width: 12, height: 12 }).fill(p.isCurrent ? '#4CAF50' : '#E0E0E0')
                Column() {
                  Row() {
                    Text(p.name).fontSize(16).fontWeight(FontWeight.Medium)
                    if (p.isCurrent) { Text('当前').fontSize(11).fontColor('#FFF').backgroundColor('#4CAF50').borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 }).margin({ left: 8 }) }
                  }
                  if (p.baseUrl) { Text(p.baseUrl).fontSize(12).fontColor('#888').margin({ top: 4 }).maxLines(1) }
                  if (p.model) { Text(`模型: ${p.model}`).fontSize(12).fontColor('#888').margin({ top: 2 }) }
                }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 12 })
                Row({ space: 8 }) {
                  Button(p.isCurrent ? '已激活' : '切换').type(ButtonType.Capsule)
                    .backgroundColor(p.isCurrent ? '#E8F5E9' : '#FF6B35')
                    .fontColor(p.isCurrent ? '#4CAF50' : '#FFF').fontSize(12).height(32)
                    .onClick(async () => { await providerService.switchTo(p.id, this.currentApp); await this.loadData(); })
                  Button('编辑').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').fontSize(12).height(32)
                    .onClick(() => { this.editItem = p; this.showDialog = true; })
                  Button('删除').type(ButtonType.Capsule).backgroundColor('#FFEBEE').fontColor('#F44336').fontSize(12).height(32)
                    .onClick(async () => { await providerService.delete(p.id, this.currentApp); await this.loadData(); })
                }
              }.width('100%').padding(16).backgroundColor('#FFF').borderRadius(12)
              .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
            }
          })
        }.width('100%').layoutWeight(1).padding({ left: 24, right: 24 })
      }
    }.width('100%').height('100%')

    if (this.showDialog) {
      ProviderDialog({ provider: this.editItem, appType: this.currentApp,
        onClose: () => { this.showDialog = false; },
        onSave: () => { this.showDialog = false; this.loadData(); }
      })
    }
  }
}

@Component
struct ProviderDialog {
  @Prop provider: Provider | null;
  @Prop appType: AppId;
  onClose: () => void = () => {};
  onSave: () => void = () => {};
  @State name: string = '';
  @State baseUrl: string = '';
  @State apiKey: string = '';
  @State model: string = '';

  aboutToAppear(): void {
    if (this.provider) {
      this.name = this.provider.name; this.baseUrl = this.provider.baseUrl;
      this.apiKey = this.provider.apiKey; this.model = this.provider.model;
    }
  }

  async handleSave(): Promise<void> {
    if (!this.name.trim()) return;
    const now = new Date().toISOString();
    if (this.provider) {
      await providerService.update({ ...this.provider, name: this.name, baseUrl: this.baseUrl, apiKey: this.apiKey, model: this.model });
    } else {
      await providerService.add({
        id: `${this.appType}-${Date.now()}`, appType: this.appType, name: this.name,
        baseUrl: this.baseUrl, apiKey: this.apiKey, model: this.model,
        category: 'custom', iconUrl: '', color: '#FF6B35', isCurrent: false, sortOrder: 0,
        createdAt: now, updatedAt: now, maxTokens: 4096, temperature: 1.0, topP: 1.0,
        systemPrompt: '', customHeaders: {}, usageScript: ''
      });
    }
    this.onSave();
  }

  build() {
    Column() {
      Column() {
        Text(this.provider ? '编辑提供商' : '添加提供商').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
        Text('名称').fontSize(14).fontColor('#666').margin({ bottom: 6 })
        TextInput({ text: this.name, placeholder: '提供商名称' }).width('100%').height(44).onChange((v: string) => this.name = v)
        Text('API 地址').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextInput({ text: this.baseUrl, placeholder: 'https://api.example.com/v1' }).width('100%').height(44).onChange((v: string) => this.baseUrl = v)
        Text('API Key').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextInput({ text: this.apiKey, placeholder: 'sk-...' }).type(InputType.Password).width('100%').height(44).onChange((v: string) => this.apiKey = v)
        Text('模型').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextInput({ text: this.model, placeholder: '模型名称' }).width('100%').height(44).onChange((v: string) => this.model = v)
        Row({ space: 12 }) {
          Button('取消').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').layoutWeight(1).onClick(() => this.onClose())
          Button('保存').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF').layoutWeight(1).onClick(() => this.handleSave())
        }.width('100%').margin({ top: 24 })
      }.width(480).padding(24).backgroundColor('#FFF').borderRadius(16)
    }.width('100%').height('100%').backgroundColor('#00000060').justifyContent(FlexAlign.Center)
    .onClick(() => this.onClose())
  }
}
