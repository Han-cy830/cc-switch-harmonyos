import { AppId, AppConfig, getAppConfigs } from '../model/Types';
import { ProviderPage } from './ProviderPage';
import { SettingsPage } from './SettingsPage';
import { PromptPage } from './PromptPage';
import { McpPage } from './McpPage';
import { SkillsPage } from './SkillsPage';
import { SessionsPage } from './SessionsPage';

@Entry
@Component
struct Index {
  @State currentTab: string = 'providers';
  @State currentApp: AppId = 'claude';
  private appConfigs: AppConfig[] = getAppConfigs();

  build() {
    Row() {
      Column() {
        Text('CC').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FF6B35').margin({ top: 24, bottom: 16 })
        Divider().color('#E5E5E5').margin({ bottom: 8 })
        ForEach(this.appConfigs, (app: AppConfig) => {
          Column() {
            Text(app.icon).fontSize(20)
            Text(app.label).fontSize(10)
              .fontColor(this.currentApp === app.appId ? '#FF6B35' : '#666')
              .margin({ top: 2 })
          }
          .width(64)
          .padding({ top: 8, bottom: 8 })
          .alignItems(HorizontalAlign.Center)
          .backgroundColor(this.currentApp === app.appId ? '#FFF3ED' : 'transparent')
          .borderRadius(8)
          .margin({ bottom: 4 })
          .onClick(() => {
            this.currentApp = app.appId;
          })
        })
        Blank()
        this.NavItem('providers', '提供商')
        this.NavItem('prompts', '提示词')
        this.NavItem('mcp', 'MCP')
        this.NavItem('skills', '技能')
        this.NavItem('sessions', '会话')
        this.NavItem('settings', '设置')
      }
      .width(80)
      .height('100%')
      .backgroundColor('#FAFAFA')
      .border({ width: { right: 1 }, color: '#E5E5E5' })

      Column() {
        if (this.currentTab === 'providers') {
          ProviderPage({ currentApp: this.currentApp })
        } else if (this.currentTab === 'settings') {
          SettingsPage()
        } else if (this.currentTab === 'prompts') {
          PromptPage({ currentApp: this.currentApp })
        } else if (this.currentTab === 'mcp') {
          McpPage()
        } else if (this.currentTab === 'skills') {
          SkillsPage()
        } else if (this.currentTab === 'sessions') {
          SessionsPage({ currentApp: this.currentApp })
        }
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  NavItem(tab: string, label: string) {
    Text(label)
      .fontSize(12)
      .fontColor(this.currentTab === tab ? '#FF6B35' : '#999')
      .fontWeight(this.currentTab === tab ? FontWeight.Medium : FontWeight.Normal)
      .margin({ top: 6, bottom: 6 })
      .onClick(() => {
        this.currentTab = tab;
      })
  }
}
