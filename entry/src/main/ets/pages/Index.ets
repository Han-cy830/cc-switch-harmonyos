import { APP_CONFIGS, AppId } from '../model/Types';

@Entry
@Component
struct Index {
  @State currentTab: string = 'providers';
  @State currentApp: AppId = 'claude';

  build() {
    Row() {
      // 侧边栏
      Column() {
        Text('CC').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FF6B35').margin({ top: 24, bottom: 16 })
        Divider().color('#E5E5E5').margin({ bottom: 8 })
        // 应用选择
        ForEach(APP_CONFIGS, (app: AppConfig) => {
          Column() {
            Text(app.icon).fontSize(20)
            Text(app.label).fontSize(10).fontColor(this.currentApp === app.appId ? '#FF6B35' : '#666').margin({ top: 2 })
          }
          .width(64).padding({ top: 8, bottom: 8 }).alignItems(HorizontalAlign.Center)
          .backgroundColor(this.currentApp === app.appId ? '#FFF3ED' : 'transparent')
          .borderRadius(8).margin({ bottom: 4 })
          .onClick(() => { this.currentApp = app.appId; })
        })
        Blank()
        // 底部导航
        ForEach(['providers', 'prompts', 'mcp', 'skills', 'sessions', 'settings'], (tab: string) => {
          Text(this.getTabLabel(tab)).fontSize(12)
            .fontColor(this.currentTab === tab ? '#FF6B35' : '#999')
            .fontWeight(this.currentTab === tab ? FontWeight.Medium : FontWeight.Normal)
            .margin({ top: 6, bottom: 6 })
            .onClick(() => { this.currentTab = tab; })
        })
      }
      .width(80).height('100%').backgroundColor('#FAFAFA')
      .border({ width: { right: 1 }, color: '#E5E5E5' })

      // 主内容区
      Column() {
        if (this.currentTab === 'providers') { ProviderPage({ currentApp: this.currentApp }) }
        else if (this.currentTab === 'settings') { SettingsPage() }
        else if (this.currentTab === 'prompts') { PromptPage({ currentApp: this.currentApp }) }
        else if (this.currentTab === 'mcp') { McpPage() }
        else if (this.currentTab === 'skills') { SkillsPage() }
        else if (this.currentTab === 'sessions') { SessionsPage({ currentApp: this.currentApp }) }
      }.layoutWeight(1).height('100%')
    }
    .width('100%').height('100%').backgroundColor('#F5F5F5')
  }

  private getTabLabel(tab: string): string {
    const m: Record<string, string> = {
      providers: '提供商', prompts: '提示词', mcp: 'MCP',
      skills: '技能', sessions: '会话', settings: '设置'
    };
    return m[tab] || tab;
  }
}
