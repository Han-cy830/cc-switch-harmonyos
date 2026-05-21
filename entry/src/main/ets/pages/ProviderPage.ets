import { Provider, AppId, AppConfig, getAppConfigs } from '../model/Types';
import { providerService } from '../service/ProviderService';
import { ProviderPreset, getPresetsForApp } from '../model/ProviderPresets';
import { fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

@Component
export struct ProviderPage {
  @Prop currentApp: AppId = 'claude';
  @State providers: Provider[] = [];
  @State showDialog: boolean = false;
  @State editName: string = '';
  @State editUrl: string = '';
  @State editKey: string = '';
  @State editModel: string = '';
  @State isEdit: boolean = false;
  @State editId: string = '';
  @State editAppType: AppId = 'claude';
  @State showPresetDialog: boolean = false;
  @State presets: ProviderPreset[] = [];
  @State presetCategory: string = 'all';
  @State showConfigDialog: boolean = false;
  @State configContent: string = '';

  private appConfigs: AppConfig[] = getAppConfigs();

  aboutToAppear(): void {
    this.loadData();
  }

  async loadData(): Promise<void> {
    this.providers = await providerService.getByApp(this.currentApp);
  }

  private getAppCfg(): AppConfig {
    for (let i = 0; i < this.appConfigs.length; i++) {
      if (this.appConfigs[i].appId === this.currentApp) {
        return this.appConfigs[i];
      }
    }
    return this.appConfigs[0];
  }

  private generateConfig(p: Provider): string {
    if (this.currentApp === 'claude') {
      return '{\n  "env": {\n    "ANTHROPIC_BASE_URL": "' + p.baseUrl + '",\n    "ANTHROPIC_API_KEY": "' + p.apiKey + '",\n    "ANTHROPIC_MODEL": "' + p.model + '"\n  }\n}';
    } else if (this.currentApp === 'codex') {
      return '{\n  "model": "' + p.model + '",\n  "api_base_url": "' + p.baseUrl + '",\n  "api_key": "' + p.apiKey + '"\n}';
    } else if (this.currentApp === 'gemini') {
      return '{\n  "GEMINI_API_KEY": "' + p.apiKey + '",\n  "GEMINI_API_BASE": "' + p.baseUrl + '",\n  "GEMINI_MODEL": "' + p.model + '"\n}';
    }
    return '{\n  "baseUrl": "' + p.baseUrl + '",\n  "apiKey": "' + p.apiKey + '",\n  "model": "' + p.model + '"\n}';
  }

  private getConfigFilePath(): string {
    if (this.currentApp === 'claude') {
      return '/data/cc-switch/claude_config.json';
    } else if (this.currentApp === 'codex') {
      return '/data/cc-switch/codex_config.json';
    } else if (this.currentApp === 'gemini') {
      return '/data/cc-switch/gemini_config.json';
    }
    return '/data/cc-switch/config.json';
  }

  private async writeConfigToFile(p: Provider): Promise<boolean> {
    try {
      const config = this.generateConfig(p);
      const filePath = this.getConfigFilePath();
      const dir = '/data/cc-switch';
      try {
        await fs.mkdir(dir);
      } catch (e) {
        // Directory may already exist
      }
      const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      await fs.write(file.fd, config);
      await fs.close(file);
      return true;
    } catch (e) {
      console.error('Write config failed: ' + JSON.stringify(e));
      return false;
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Column() {
            Text(this.getAppCfg().icon + ' ' + this.getAppCfg().label)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
            Text(this.getAppCfg().description)
              .fontSize(13)
              .fontColor('#999')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
          Button('+ 添加提供商')
            .type(ButtonType.Capsule)
            .backgroundColor('#FF6B35')
            .fontColor('#FFF')
            .onClick(() => {
              this.presets = getPresetsForApp(this.currentApp);
              this.presetCategory = 'all';
              this.showPresetDialog = true;
            })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 20, bottom: 16 })

        if (this.providers.length === 0) {
          Column() {
            Text('暂无提供商').fontSize(16).fontColor('#999')
            Button('添加第一个提供商')
              .type(ButtonType.Capsule)
              .backgroundColor('#FF6B35')
              .fontColor('#FFF')
              .margin({ top: 16 })
              .onClick(() => {
                this.presets = getPresetsForApp(this.currentApp);
                this.presetCategory = 'all';
                this.showPresetDialog = true;
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.providers, (p: Provider) => {
              ListItem() {
                Row() {
                  Circle({ width: 12, height: 12 }).fill(p.isCurrent ? '#4CAF50' : '#E0E0E0')
                  Column() {
                    Row() {
                      Text(p.name).fontSize(16).fontWeight(FontWeight.Medium)
                      if (p.isCurrent) {
                        Text('当前')
                          .fontSize(11)
                          .fontColor('#FFF')
                          .backgroundColor('#4CAF50')
                          .borderRadius(4)
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .margin({ left: 8 })
                      }
                    }
                    if (p.baseUrl.length > 0) {
                      Text(p.baseUrl).fontSize(12).fontColor('#888').margin({ top: 4 }).maxLines(1)
                    }
                    if (p.model.length > 0) {
                      Text('模型: ' + p.model).fontSize(12).fontColor('#888').margin({ top: 2 })
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 12 })
                  Row({ space: 8 }) {
                    Button(p.isCurrent ? '已激活' : '切换')
                      .type(ButtonType.Capsule)
                      .backgroundColor(p.isCurrent ? '#E8F5E9' : '#FF6B35')
                      .fontColor(p.isCurrent ? '#4CAF50' : '#FFF')
                      .fontSize(12)
                      .height(32)
                      .onClick(async () => {
                        await providerService.switchTo(p.id, this.currentApp);
                        const success = await this.writeConfigToFile(p);
                        if (success) {
                          this.configContent = this.generateConfig(p);
                          this.showConfigDialog = true;
                        }
                        await this.loadData();
                      })
                    Button('复制配置')
                      .type(ButtonType.Capsule)
                      .backgroundColor('#E3F2FD')
                      .fontColor('#1976D2')
                      .fontSize(12)
                      .height(32)
                      .onClick(() => {
                        this.configContent = this.generateConfig(p);
                        this.showConfigDialog = true;
                      })
                    Button('编辑')
                      .type(ButtonType.Capsule)
                      .backgroundColor('#F0F0F0')
                      .fontColor('#666')
                      .fontSize(12)
                      .height(32)
                      .onClick(() => {
                        this.isEdit = true;
                        this.editId = p.id;
                        this.editAppType = p.appType;
                        this.editName = p.name;
                        this.editUrl = p.baseUrl;
                        this.editKey = p.apiKey;
                        this.editModel = p.model;
                        this.showDialog = true;
                      })
                    Button('删除')
                      .type(ButtonType.Capsule)
                      .backgroundColor('#FFEBEE')
                      .fontColor('#F44336')
                      .fontSize(12)
                      .height(32)
                      .onClick(async () => {
                        await providerService.delete(p.id, this.currentApp);
                        await this.loadData();
                      })
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFF')
                .borderRadius(12)
                .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 24, right: 24 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.showDialog) {
        this.DialogContent()
      }
      if (this.showPresetDialog) {
        this.PresetDialogContent()
      }
      if (this.showConfigDialog) {
        this.ConfigDialogContent()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  DialogContent() {
    Column() {
      Column() {
        Text(this.isEdit ? '编辑提供商' : '添加提供商')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })
        Text('名称').fontSize(14).fontColor('#666').margin({ bottom: 6 })
        TextInput({ text: this.editName, placeholder: '提供商名称' })
          .width('100%').height(44)
          .onChange((v: string) => { this.editName = v; })
        Text('API 地址').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextInput({ text: this.editUrl, placeholder: 'https://api.example.com/v1' })
          .width('100%').height(44)
          .onChange((v: string) => { this.editUrl = v; })
        Text('API Key').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextInput({ text: this.editKey, placeholder: 'sk-...' })
          .type(InputType.Password)
          .width('100%').height(44)
          .onChange((v: string) => { this.editKey = v; })
        Text('模型').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextInput({ text: this.editModel, placeholder: '模型名称' })
          .width('100%').height(44)
          .onChange((v: string) => { this.editModel = v; })
        Row({ space: 12 }) {
          Button('取消')
            .type(ButtonType.Capsule)
            .backgroundColor('#F0F0F0')
            .fontColor('#666')
            .layoutWeight(1)
            .onClick(() => { this.showDialog = false; })
          Button('保存')
            .type(ButtonType.Capsule)
            .backgroundColor('#FF6B35')
            .fontColor('#FFF')
            .layoutWeight(1)
            .onClick(async () => {
              if (this.editName.length === 0) return;
              const now = new Date().toISOString();
              if (this.isEdit) {
                const p = new Provider();
                p.id = this.editId;
                p.appType = this.editAppType;
                p.name = this.editName;
                p.baseUrl = this.editUrl;
                p.apiKey = this.editKey;
                p.model = this.editModel;
                p.category = 'custom';
                await providerService.update(p);
              } else {
                const p = new Provider();
                p.id = this.currentApp + '-' + Date.now().toString();
                p.appType = this.currentApp;
                p.name = this.editName;
                p.baseUrl = this.editUrl;
                p.apiKey = this.editKey;
                p.model = this.editModel;
                p.category = 'custom';
                p.createdAt = now;
                p.updatedAt = now;
                await providerService.add(p);
              }
              this.showDialog = false;
              await this.loadData();
            })
        }
        .width('100%')
        .margin({ top: 24 })
      }
      .width(480)
      .padding(24)
      .backgroundColor('#FFF')
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000060')
    .justifyContent(FlexAlign.Center)
    .onClick(() => { this.showDialog = false; })
  }

  private getFilteredPresets(): ProviderPreset[] {
    if (this.presetCategory === 'all') return this.presets;
    const result: ProviderPreset[] = [];
    for (let i = 0; i < this.presets.length; i++) {
      if (this.presets[i].category === this.presetCategory) {
        result.push(this.presets[i]);
      }
    }
    return result;
  }

  @Builder
  PresetDialogContent() {
    Column() {
      Column() {
        Row() {
          Text('选择提供商预设').fontSize(20).fontWeight(FontWeight.Bold)
          Blank()
          Button('自定义添加')
            .type(ButtonType.Capsule)
            .backgroundColor('#F0F0F0')
            .fontColor('#666')
            .fontSize(12)
            .onClick(() => {
              this.showPresetDialog = false;
              this.isEdit = false;
              this.editName = '';
              this.editUrl = '';
              this.editKey = '';
              this.editModel = '';
              this.showDialog = true;
            })
        }.width('100%').margin({ bottom: 16 })

        Row({ space: 8 }) {
          Button('全部').type(ButtonType.Capsule)
            .backgroundColor(this.presetCategory === 'all' ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.presetCategory === 'all' ? '#FFF' : '#666')
            .fontSize(12).height(32)
            .onClick(() => { this.presetCategory = 'all'; })
          Button('官方').type(ButtonType.Capsule)
            .backgroundColor(this.presetCategory === 'official' ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.presetCategory === 'official' ? '#FFF' : '#666')
            .fontSize(12).height(32)
            .onClick(() => { this.presetCategory = 'official'; })
          Button('中转').type(ButtonType.Capsule)
            .backgroundColor(this.presetCategory === 'aggregator' ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.presetCategory === 'aggregator' ? '#FFF' : '#666')
            .fontSize(12).height(32)
            .onClick(() => { this.presetCategory = 'aggregator'; })
          Button('云厂商').type(ButtonType.Capsule)
            .backgroundColor(this.presetCategory === 'cloud' ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.presetCategory === 'cloud' ? '#FFF' : '#666')
            .fontSize(12).height(32)
            .onClick(() => { this.presetCategory = 'cloud'; })
          Button('第三方').type(ButtonType.Capsule)
            .backgroundColor(this.presetCategory === 'third_party' ? '#FF6B35' : '#F0F0F0')
            .fontColor(this.presetCategory === 'third_party' ? '#FFF' : '#666')
            .fontSize(12).height(32)
            .onClick(() => { this.presetCategory = 'third_party'; })
        }.width('100%').margin({ bottom: 12 })

        List({ space: 8 }) {
          ForEach(this.getFilteredPresets(), (preset: ProviderPreset) => {
            ListItem() {
              Row() {
                Circle({ width: 10, height: 10 }).fill(preset.color)
                Column() {
                  Text(preset.name).fontSize(14).fontWeight(FontWeight.Medium)
                  Text(preset.description).fontSize(12).fontColor('#888').margin({ top: 2 })
                  Text(preset.model).fontSize(11).fontColor('#AAA').margin({ top: 2 })
                }.alignItems(HorizontalAlign.Start).margin({ left: 10 }).layoutWeight(1)
                Button('添加')
                  .type(ButtonType.Capsule)
                  .backgroundColor('#FF6B35')
                  .fontColor('#FFF')
                  .fontSize(12).height(32)
                  .onClick(async () => {
                    const p = new Provider();
                    p.id = preset.id;
                    p.appType = preset.appType as AppId;
                    p.name = preset.name;
                    p.baseUrl = preset.baseUrl;
                    p.model = preset.model;
                    p.category = preset.category;
                    p.color = preset.color;
                    await providerService.add(p);
                    this.showPresetDialog = false;
                    await this.loadData();
                  })
              }.width('100%').padding(12).backgroundColor('#FAFAFA').borderRadius(8)
            }
          })
        }.width('100%').layoutWeight(1)

        Row() {
          Button('关闭')
            .type(ButtonType.Capsule)
            .backgroundColor('#F0F0F0')
            .fontColor('#666')
            .layoutWeight(1)
            .onClick(() => { this.showPresetDialog = false; })
        }.width('100%').margin({ top: 12 })
      }.width(520).height(500).padding(24).backgroundColor('#FFF').borderRadius(16)
    }.width('100%').height('100%').backgroundColor('#00000060').justifyContent(FlexAlign.Center)
      .onClick(() => { this.showPresetDialog = false; })
  }

  @Builder
  ConfigDialogContent() {
    Column() {
      Column() {
        Text('激活成功').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#4CAF50').margin({ bottom: 16 })
        Text('配置已保存到：').fontSize(14).fontColor('#666').margin({ bottom: 8 })
        Text(this.getConfigFilePath()).fontSize(13).fontColor('#1976D2').backgroundColor('#E3F2FD').padding(8).borderRadius(4)
        Text('使用方法：').fontSize(14).fontWeight(FontWeight.Medium).margin({ top: 16, bottom: 8 })
        Text(this.getAppCfg().label === 'Claude Code' ?
          '1. 打开终端\n2. 运行: cat ' + this.getConfigFilePath() + ' | jq .env\n3. 将环境变量添加到 ~/.bashrc 或 ~/.zshrc' :
          this.getAppCfg().label === 'Codex' ?
            '1. 打开终端\n2. 运行: cp ' + this.getConfigFilePath() + ' ~/.codex/config.json\n3. 重启 Codex CLI' :
            '1. 打开终端\n2. 运行: cp ' + this.getConfigFilePath() + ' ~/.gemini/config.json\n3. 重启 Gemini CLI')
          .fontSize(13).fontColor('#666').margin({ bottom: 16 })
        TextArea({ text: this.configContent })
          .width('100%').height(150).fontSize(12).fontColor('#333')
          .backgroundColor('#F5F5F5').borderRadius(8).enabled(false)
        Row() {
          Button('关闭')
            .type(ButtonType.Capsule)
            .backgroundColor('#FF6B35')
            .fontColor('#FFF')
            .layoutWeight(1)
            .onClick(() => { this.showConfigDialog = false; })
        }.width('100%').margin({ top: 16 })
      }.width(520).padding(24).backgroundColor('#FFF').borderRadius(16)
    }.width('100%').height('100%').backgroundColor('#00000060').justifyContent(FlexAlign.Center)
      .onClick(() => { this.showConfigDialog = false; })
  }
}
