import { Prompt, AppId, getAppConfigs } from '../model/Types';
import { promptService } from '../service/PromptService';

@Component
export struct PromptPage {
  @Prop currentApp: AppId = 'claude';
  @State prompts: Prompt[] = [];
  @State showDialog: boolean = false;
  @State editName: string = '';
  @State editContent: string = '';
  @State isEdit: boolean = false;
  @State editId: string = '';

  aboutToAppear(): void { this.loadData(); }
  async loadData(): Promise<void> { this.prompts = await promptService.getByApp(this.currentApp); }

  private getAppLabel(): string {
    const configs = getAppConfigs();
    for (let i = 0; i < configs.length; i++) {
      if (configs[i].appId === this.currentApp) return configs[i].label;
    }
    return '';
  }

  build() {
    Stack() {
    Column() {
      Row() {
        Column() {
          Text('提示词管理').fontSize(22).fontWeight(FontWeight.Bold)
          Text('管理 ' + this.getAppLabel() + ' 的系统提示词').fontSize(13).fontColor('#999').margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Button('+ 添加提示词').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF')
          .onClick(() => { this.isEdit = false; this.editName = ''; this.editContent = ''; this.showDialog = true; })
      }.width('100%').padding({ left: 24, right: 24, top: 20, bottom: 16 })

      if (this.prompts.length === 0) {
        Column() { Text('暂无提示词').fontSize(16).fontColor('#999') }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.prompts, (p: Prompt) => {
            ListItem() {
              Row() {
                Column() {
                  Row() {
                    Text(p.name).fontSize(16).fontWeight(FontWeight.Medium)
                    if (!p.enabled) { Text('已禁用').fontSize(11).fontColor('#999').backgroundColor('#F0F0F0').borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 }).margin({ left: 8 }) }
                  }
                  Text(p.content.length > 80 ? p.content.substring(0, 80) + '...' : p.content).fontSize(13).fontColor('#888').margin({ top: 6 }).maxLines(2)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Row({ space: 8 }) {
                  Toggle({ type: ToggleType.Switch, isOn: p.enabled }).onChange(async () => { await promptService.toggle(p.id); await this.loadData(); })
                  Button('编辑').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').fontSize(12).height(32)
                    .onClick(() => { this.isEdit = true; this.editId = p.id; this.editName = p.name; this.editContent = p.content; this.showDialog = true; })
                  Button('删除').type(ButtonType.Capsule).backgroundColor('#FFEBEE').fontColor('#F44336').fontSize(12).height(32)
                    .onClick(async () => { await promptService.delete(p.id); await this.loadData(); })
                }
              }.width('100%').padding(16).backgroundColor('#FFF').borderRadius(12).shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
            }
          })
        }.width('100%').layoutWeight(1).padding({ left: 24, right: 24 })
      }
    }.width('100%').height('100%')

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
        Text(this.isEdit ? '编辑提示词' : '添加提示词').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
        Text('名称').fontSize(14).fontColor('#666').margin({ bottom: 6 })
        TextInput({ text: this.editName, placeholder: '提示词名称' }).width('100%').height(44).onChange((v: string) => { this.editName = v; })
        Text('内容').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextArea({ text: this.editContent, placeholder: '输入系统提示词...' }).width('100%').height(200).onChange((v: string) => { this.editContent = v; })
        Row({ space: 12 }) {
          Button('取消').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').layoutWeight(1).onClick(() => { this.showDialog = false; })
          Button('保存').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF').layoutWeight(1)
            .onClick(async () => {
              if (this.editName.length === 0) return;
              if (this.isEdit) {
                const p = new Prompt();
                p.id = this.editId;
                p.name = this.editName;
                p.content = this.editContent;
                await promptService.update(p);
              } else {
                const p = new Prompt();
                p.id = 'p-' + Date.now().toString();
                p.appType = this.currentApp;
                p.name = this.editName;
                p.content = this.editContent;
                await promptService.add(p);
              }
              this.showDialog = false;
              await this.loadData();
            })
        }.width('100%').margin({ top: 20 })
      }.width(500).padding(24).backgroundColor('#FFF').borderRadius(16)
    }.width('100%').height('100%').backgroundColor('#00000060').justifyContent(FlexAlign.Center).onClick(() => { this.showDialog = false; })
  }
}
