import { AppSettings } from '../model/Types';
import { settingsService } from '../service/SettingsService';

@Component
export struct SettingsPage {
  @State settings: AppSettings = new AppSettings();
  @State section: string = 'general';

  aboutToAppear(): void {
    settingsService.get().then((s: AppSettings) => {
      this.settings = s;
    });
  }

  private async upd(key: string, val: string): Promise<void> {
    await settingsService.update(key, val);
    const s = await settingsService.get();
    this.settings = s;
  }

  build() {
    Row() {
      Column() {
        Text('设置').fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
        this.SideItem('general', '通用')
        this.SideItem('appearance', '外观')
        this.SideItem('proxy', '代理')
        this.SideItem('about', '关于')
      }
      .width(200)
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      Divider().vertical(true).color('#E5E5E5')
      Column() {
        if (this.section === 'general') {
          this.GeneralTab()
        } else if (this.section === 'appearance') {
          this.AppearanceTab()
        } else if (this.section === 'proxy') {
          this.ProxyTab()
        } else if (this.section === 'about') {
          this.AboutTab()
        }
      }
      .layoutWeight(1)
      .padding(24)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  SideItem(s: string, label: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.section === s ? '#FF6B35' : '#666')
      .fontWeight(this.section === s ? FontWeight.Medium : FontWeight.Normal)
      .width('100%')
      .padding({ left: 16, top: 10, bottom: 10 })
      .backgroundColor(this.section === s ? '#FFF3ED' : 'transparent')
      .borderRadius(8)
      .onClick(() => { this.section = s; })
  }

  @Builder
  GeneralTab() {
    Column({ space: 16 }) {
      Text('通用设置').fontSize(18).fontWeight(FontWeight.Bold)
      Row() {
        Text('开机自启').fontSize(14).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.settings.launchOnStartup })
          .onChange((v: boolean) => { this.upd('launchOnStartup', v ? 'true' : 'false'); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() {
        Text('静默启动').fontSize(14).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.settings.silentStartup })
          .onChange((v: boolean) => { this.upd('silentStartup', v ? 'true' : 'false'); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() {
        Text('关闭时最小化到托盘').fontSize(14).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.settings.minimizeToTray })
          .onChange((v: boolean) => { this.upd('minimizeToTray', v ? 'true' : 'false'); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() {
        Text('显示托盘图标').fontSize(14).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.settings.showInTray })
          .onChange((v: boolean) => { this.upd('showInTray', v ? 'true' : 'false'); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  AppearanceTab() {
    Column({ space: 16 }) {
      Text('外观设置').fontSize(18).fontWeight(FontWeight.Bold)
      Column() {
        Text('语言').fontSize(14).margin({ bottom: 8 })
        Select([{ value: 'zh' }, { value: 'en' }])
          .value(this.settings.language)
          .onSelect((_i: number, v: string) => { this.upd('language', v); })
          .width(200)
      }
      Column() {
        Text('主题').fontSize(14).margin({ bottom: 8 })
        Select([{ value: 'light' }, { value: 'dark' }, { value: 'system' }])
          .value(this.settings.theme)
          .onSelect((_i: number, v: string) => { this.upd('theme', v); })
          .width(200)
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  ProxyTab() {
    Column({ space: 16 }) {
      Text('代理设置').fontSize(18).fontWeight(FontWeight.Bold)
      Row() {
        Text('启用本地代理').fontSize(14).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.settings.enableLocalProxy })
          .onChange((v: boolean) => { this.upd('enableLocalProxy', v ? 'true' : 'false'); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() {
        Text('代理端口').fontSize(14).layoutWeight(1)
        TextInput({ text: this.settings.proxyPort.toString() })
          .width(120).height(40)
          .onChange((v: string) => { this.upd('proxyPort', v); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() {
        Text('启用故障转移').fontSize(14).layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.settings.enableFailover })
          .onChange((v: boolean) => { this.upd('enableFailover', v ? 'true' : 'false'); })
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  AboutTab() {
    Column({ space: 12 }) {
      Text('关于 CC Switch').fontSize(18).fontWeight(FontWeight.Bold)
      Text('版本: 1.0.0 (HarmonyOS)').fontSize(14).fontColor('#666')
      Text('Claude Code、Codex、Gemini CLI 的全方位管理工具').fontSize(14).fontColor('#666')
      Text('基于开源项目 CC Switch 移植').fontSize(14).fontColor('#666')
      Text('GitHub: Han-cy830/cc-switch-harmonyos').fontSize(14).fontColor('#FF6B35')
      Text('MIT License').fontSize(12).fontColor('#999').margin({ top: 8 })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
