import { AppSettings } from '../model/Types';
import { settingsService } from '../service/SettingsService';

@Component
export struct SettingsPage {
  @State settings: AppSettings | null = null;
  @State section: string = 'general';

  aboutToAppear(): void { settingsService.get().then((s) => { this.settings = s; }); }

  private async upd(key: keyof AppSettings, val: Object): Promise<void> {
    await settingsService.update(key, val);
    this.settings = await settingsService.get();
  }

  build() {
    Row() {
      Column() {
        Text('设置').fontSize(22).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
        ForEach(['general', 'appearance', 'proxy', 'about'], (s: string) => {
          Text(this.getLbl(s)).fontSize(14).fontColor(this.section === s ? '#FF6B35' : '#666')
            .fontWeight(this.section === s ? FontWeight.Medium : FontWeight.Normal)
            .width('100%').padding({ left: 16, top: 10, bottom: 10 })
            .backgroundColor(this.section === s ? '#FFF3ED' : 'transparent').borderRadius(8)
            .onClick(() => this.section = s)
        })
      }.width(200).padding(16).alignItems(HorizontalAlign.Start)
      Divider().vertical(true).color('#E5E5E5')
      Column() {
        if (this.settings) {
          if (this.section === 'general') { GeneralTab({ s: this.settings, upd: (k, v) => this.upd(k, v) }) }
          else if (this.section === 'appearance') { AppearanceTab({ s: this.settings, upd: (k, v) => this.upd(k, v) }) }
          else if (this.section === 'proxy') { ProxyTab({ s: this.settings, upd: (k, v) => this.upd(k, v) }) }
          else if (this.section === 'about') { AboutTab() }
        }
      }.layoutWeight(1).padding(24).alignItems(HorizontalAlign.Start)
    }.width('100%').height('100%')
  }

  private getLbl(s: string): string {
    const m: Record<string, string> = { general: '通用', appearance: '外观', proxy: '代理', about: '关于' };
    return m[s] || s;
  }
}

@Component
struct GeneralTab {
  @Prop s: AppSettings;
  upd: (k: keyof AppSettings, v: Object) => void = () => {};
  build() {
    Column({ space: 16 }) {
      Text('通用设置').fontSize(18).fontWeight(FontWeight.Bold)
      Row() { Text('开机自启').fontSize(14).layoutWeight(1); Toggle({ type: ToggleType.Switch, isOn: this.s.launchOnStartup }).onChange((v: boolean) => this.upd('launchOnStartup', v)) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() { Text('静默启动').fontSize(14).layoutWeight(1); Toggle({ type: ToggleType.Switch, isOn: this.s.silentStartup }).onChange((v: boolean) => this.upd('silentStartup', v)) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() { Text('关闭时最小化到托盘').fontSize(14).layoutWeight(1); Toggle({ type: ToggleType.Switch, isOn: this.s.minimizeToTray }).onChange((v: boolean) => this.upd('minimizeToTray', v)) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() { Text('显示托盘图标').fontSize(14).layoutWeight(1); Toggle({ type: ToggleType.Switch, isOn: this.s.showInTray }).onChange((v: boolean) => this.upd('showInTray', v)) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}

@Component
struct AppearanceTab {
  @Prop s: AppSettings;
  upd: (k: keyof AppSettings, v: Object) => void = () => {};
  build() {
    Column({ space: 16 }) {
      Text('外观设置').fontSize(18).fontWeight(FontWeight.Bold)
      Column() { Text('语言').fontSize(14).margin({ bottom: 8 })
        Select([{ value: 'zh', label: '中文' }, { value: 'en', label: 'English' }]).value(this.s.language)
          .onSelect((_i: number, v: string) => this.upd('language', v)).width(200)
      }
      Column() { Text('主题').fontSize(14).margin({ bottom: 8 })
        Select([{ value: 'light', label: '浅色' }, { value: 'dark', label: '深色' }, { value: 'system', label: '跟随系统' }]).value(this.s.theme)
          .onSelect((_i: number, v: string) => this.upd('theme', v)).width(200)
      }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}

@Component
struct ProxyTab {
  @Prop s: AppSettings;
  upd: (k: keyof AppSettings, v: Object) => void = () => {};
  build() {
    Column({ space: 16 }) {
      Text('代理设置').fontSize(18).fontWeight(FontWeight.Bold)
      Row() { Text('启用本地代理').fontSize(14).layoutWeight(1); Toggle({ type: ToggleType.Switch, isOn: this.s.enableLocalProxy }).onChange((v: boolean) => this.upd('enableLocalProxy', v)) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() { Text('代理端口').fontSize(14).layoutWeight(1); TextInput({ text: `${this.s.proxyPort}` }).width(120).height(40).onChange((v: string) => { const p = parseInt(v); if (!isNaN(p)) this.upd('proxyPort', p); }) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      Row() { Text('启用故障转移').fontSize(14).layoutWeight(1); Toggle({ type: ToggleType.Switch, isOn: this.s.enableFailover }).onChange((v: boolean) => this.upd('enableFailover', v)) }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}

@Component
struct AboutTab {
  build() {
    Column({ space: 12 }) {
      Text('关于 CC Switch').fontSize(18).fontWeight(FontWeight.Bold)
      Text('版本: 1.0.0 (HarmonyOS)').fontSize(14).fontColor('#666')
      Text('Claude Code、Codex、Gemini CLI 的全方位管理工具').fontSize(14).fontColor('#666')
      Text('基于开源项目 CC Switch 移植').fontSize(14).fontColor('#666')
      Text('GitHub: github.com/Han-cy830/cc-switch-harmonyos').fontSize(14).fontColor('#FF6B35')
      Text('MIT License').fontSize(12).fontColor('#999').margin({ top: 8 })
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
