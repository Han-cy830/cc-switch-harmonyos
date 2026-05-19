import { Provider, AppId, AppConfig, getAppConfigs } from '../model/Types';
import { providerService } from '../service/ProviderService';

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
              this.isEdit = false;
              this.editName = '';
              this.editUrl = '';
              this.editKey = '';
              this.editModel = '';
              this.showDialog = true;
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
                this.showDialog = true;
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
                        await this.loadData();
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
}
