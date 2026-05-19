import { McpServer } from '../model/Types';
import { mcpService } from '../service/McpService';

@Component
export struct McpPage {
  @State servers: McpServer[] = [];
  @State showDialog: boolean = false;
  @State editName: string = '';
  @State editTransport: string = 'stdio';
  @State editCommand: string = '';
  @State editUrl: string = '';
  @State isEdit: boolean = false;
  @State editId: string = '';

  aboutToAppear(): void { this.loadData(); }
  async loadData(): Promise<void> { this.servers = await mcpService.getAll(); }

  build() {
    Column() {
      Row() {
        Column() {
          Text('MCP 服务管理').fontSize(22).fontWeight(FontWeight.Bold)
          Text('管理 Model Context Protocol 服务器').fontSize(13).fontColor('#999').margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Button('+ 添加 MCP').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF')
          .onClick(() => { this.isEdit = false; this.editName = ''; this.editTransport = 'stdio'; this.editCommand = ''; this.editUrl = ''; this.showDialog = true; })
      }.width('100%').padding({ left: 24, right: 24, top: 20, bottom: 16 })

      if (this.servers.length === 0) {
        Column() { Text('暂无 MCP 服务').fontSize(16).fontColor('#999') }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.servers, (s: McpServer) => {
            ListItem() {
              Row() {
                Column() {
                  Row() {
                    Text(s.name).fontSize(16).fontWeight(FontWeight.Medium)
                    Text(s.transport.toUpperCase()).fontSize(11).fontColor('#FF6B35').backgroundColor('#FFF3ED').borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 }).margin({ left: 8 })
                  }
                  Text(s.transport === 'stdio' ? s.command : s.url).fontSize(13).fontColor('#888').margin({ top: 6 }).maxLines(1)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Row({ space: 8 }) {
                  Toggle({ type: ToggleType.Switch, isOn: s.enabled }).onChange(async () => { await mcpService.toggle(s.id); await this.loadData(); })
                  Button('编辑').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').fontSize(12).height(32)
                    .onClick(() => { this.isEdit = true; this.editId = s.id; this.editName = s.name; this.editTransport = s.transport; this.editCommand = s.command; this.editUrl = s.url; this.showDialog = true; })
                  Button('删除').type(ButtonType.Capsule).backgroundColor('#FFEBEE').fontColor('#F44336').fontSize(12).height(32)
                    .onClick(async () => { await mcpService.delete(s.id); await this.loadData(); })
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

  @Builder
  DialogContent() {
    Column() {
      Column() {
        Text(this.isEdit ? '编辑 MCP' : '添加 MCP').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 20 })
        Text('名称').fontSize(14).fontColor('#666').margin({ bottom: 6 })
        TextInput({ text: this.editName, placeholder: '服务名称' }).width('100%').height(44).onChange((v: string) => { this.editName = v; })
        Text('传输类型').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
        Select([{ value: 'stdio' }, { value: 'http' }, { value: 'sse' }])
          .value(this.editTransport)
          .onSelect((_i: number, v: string) => { this.editTransport = v; })
          .width('100%')
        if (this.editTransport === 'stdio') {
          Text('命令').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
          TextInput({ text: this.editCommand, placeholder: 'npx, node...' }).width('100%').height(44).onChange((v: string) => { this.editCommand = v; })
        } else {
          Text('URL').fontSize(14).fontColor('#666').margin({ top: 12, bottom: 6 })
          TextInput({ text: this.editUrl, placeholder: 'http://localhost:3000' }).width('100%').height(44).onChange((v: string) => { this.editUrl = v; })
        }
        Row({ space: 12 }) {
          Button('取消').type(ButtonType.Capsule).backgroundColor('#F0F0F0').fontColor('#666').layoutWeight(1).onClick(() => { this.showDialog = false; })
          Button('保存').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF').layoutWeight(1)
            .onClick(async () => {
              if (this.editName.length === 0) return;
              if (this.isEdit) {
                const s = new McpServer();
                s.id = this.editId;
                s.name = this.editName;
                s.transport = this.editTransport;
                s.command = this.editCommand;
                s.url = this.editUrl;
                await mcpService.update(s);
              } else {
                const s = new McpServer();
                s.id = 'mcp-' + Date.now().toString();
                s.name = this.editName;
                s.transport = this.editTransport;
                s.command = this.editCommand;
                s.url = this.editUrl;
                await mcpService.add(s);
              }
              this.showDialog = false;
              await this.loadData();
            })
        }.width('100%').margin({ top: 20 })
      }.width(480).padding(24).backgroundColor('#FFF').borderRadius(16)
    }.width('100%').height('100%').backgroundColor('#00000060').justifyContent(FlexAlign.Center).onClick(() => { this.showDialog = false; })
  }
}
