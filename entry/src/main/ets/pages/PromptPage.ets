import { Prompt, AppId, APP_CONFIGS } from '../model/Types';
import { promptService } from '../service/PromptService';

@Component
export struct PromptPage {
  @Prop currentApp: AppId = 'claude';
  @State prompts: Prompt[] = [];
  @State showDialog: boolean = false;
  @State editItem: Prompt | null = null;

  aboutToAppear(): void { this.loadData(); }
  async loadData(): Promise<void> { this.prompts = await promptService.getByApp(this.currentApp); }

  build() {
    Column() {
      Row() {
        Column() { Text('提示词管理').fontSize(22).fontWeight(FontWeight.Bold); Text(`管理 ${APP_CONFIGS.find((a) => a.appId === this.currentApp)?.label || ''} 的系统提示词`).fontSize(13).fontColor('#999').margin({ top: 4 }) }.alignItems(HorizontalAlign.Start)
        Blank()
        Button('+ 添加提示词').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF').onClick(() => { this.editItem = null; this.showDialog = true; })
      }.width('100%').padding({ left: 24, right: 24, top: 20, bottom: 16 })

      if (this.prompts.length === 0) {
        Column() { Text('暂无提示词').fontSize(16).fontColor('#999') }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.prompts, (p: Prompt) => {
            ListItem() {
              Row() {
                Column() {
                  Row() { Text(p.name).fontSize(16).fontWeight(FontWeight.Medium); if (!p.enabled) { Text('已禁用').fontSize(11).fontColor('#999').backgroundColor('#F0F0F0').borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 }).margin({ left: 8 }) } }
                  Text(p.content.substring(0, 80) + (p.content.length > 80 ? '...' : '')).fontSize(13).fontColor('#888').margin({ top: 6 }).maxLines(2)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Row({ space: 8 }) {
                  Toggle({ type: ToggleType.Switch, isOn: p.enabled }).onChange(async () => { await promptService.toggle(p.id); await this.loadData(); })
                  Button('编辑').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').fontSize(12).height(32).onClick(() => { this.editItem = p; this.showDialog = true; })
                  Button('删除').type(ButtonType.Capsule).backgroundColor('#FFEBEE').fontColor('#F44336').fontSize(12).height(32).onClick(async () => { await promptService.delete(p.id); await this.loadData(); })
                }
              }.width('100%').padding(16).backgroundColor('#FFF').borderRadius(12).shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
            }
          })
        }.width('100%').layoutWeight(1).padding({ left: 24, right: 24 })
      }
    }.width('100%').height('100%')

    if (this.showDialog) {
      PromptDialog({ prompt: this.editItem, appType: this.currentApp,
        onClose: () => { this.showDialog = false; },
        onSave: () => { this.showDialog = false; this.loadData(); }
      })
    }
  }
}

@Component
struct PromptDialog {
  @Prop prompt: Prompt | null;
  @Prop appType: AppId;
  onClose: () => void = () => {};
  onSave: () => void = () => {};
  @State name: string = '';
  @State content: string = '';

  aboutToAppear(): void { if (this.prompt) { this.name = this.prompt.name; this.content = this.prompt.content; } }

  async handleSave(): Promise<void> {
    if (!this.name.trim()) return;
    if (this.prompt) { await promptService.update({ ...this.prompt, name: this.name, content: this.content }); }
    else { await promptService.add({ id: `p-${Date.now()}`, appType: this.appType, name: this.name, content: this.content, enabled: true, sortOrder: 0, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() }); }
    this.onSave();
  }

  build() {
    Column() {
      Column() {
        Text(this.prompt ? '编辑提示词' : '添加提示词').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
        Text('名称').fontSize(14).fontColor('#666').margin({ bottom: 6 })
        TextInput({ text: this.name, placeholder: '提示词名称' }).width('100%').height(44).onChange((v: string) => this.name = v)
        Text('内容').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        TextArea({ text: this.content, placeholder: '输入系统提示词...' }).width('100%').height(200).onChange((v: string) => this.content = v)
        Row({ space: 12 }) {
          Button('取消').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').layoutWeight(1).onClick(() => this.onClose())
          Button('保存').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF').layoutWeight(1).onClick(() => this.handleSave())
        }.width('100%').margin({ top: 20 })
      }.width(500).padding(24).backgroundColor('#FFF').borderRadius(16)
    }.width('100%').height('100%').backgroundColor('#00000060').justifyContent(FlexAlign.Center).onClick(() => this.onClose())
  }
}
