import { AppId, APP_CONFIGS } from '../model/Types';

@Component
export struct SessionsPage {
  @Prop currentApp: AppId = 'claude';
  @State searchQuery: string = '';

  build() {
    Column() {
      Row() {
        Column() { Text('会话管理').fontSize(22).fontWeight(FontWeight.Bold); Text(`浏览 ${APP_CONFIGS.find((a) => a.appId === this.currentApp)?.label || ''} 的会话历史`).fontSize(13).fontColor('#999').margin({ top: 4 }) }.alignItems(HorizontalAlign.Start)
        Blank()
        TextInput({ text: this.searchQuery, placeholder: '搜索会话...' }).width(240).height(40).onChange((v: string) => this.searchQuery = v)
      }.width('100%').padding({ left: 24, right: 24, top: 20, bottom: 16 })

      Column() {
        Text('暂无会话记录').fontSize(16).fontColor('#999')
        Text('会话记录将在此处显示').fontSize(13).fontColor('#BBB').margin({ top: 8 })
      }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
    }.width('100%').height('100%')
  }
}
