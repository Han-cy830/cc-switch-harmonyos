import { Skill } from '../model/Types';
import { dbService } from '../service/DatabaseService';

@Component
export struct SkillsPage {
  @State skills: Skill[] = [];
  @State loading: boolean = true;

  aboutToAppear(): void { this.loadData(); }

  async loadData(): Promise<void> {
    const store = dbService.getStore();
    if (!store) return;
    try {
      const rs = await store.querySql('SELECT * FROM skills ORDER BY name ASC');
      const list: Skill[] = [];
      while (rs.goToNextRow()) {
        const sk = new Skill();
        sk.id = rs.getString(0);
        sk.name = rs.getString(1);
        sk.description = rs.getString(2);
        sk.source = rs.getString(3);
        sk.version = rs.getString(4);
        sk.installedAt = rs.getString(5);
        list.push(sk);
      }
      rs.close();
      this.skills = list;
    } catch (e) {
      console.error('skills load failed: ' + JSON.stringify(e));
    }
    this.loading = false;
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('技能管理').fontSize(22).fontWeight(FontWeight.Bold)
          Text('管理已安装的 AI 技能').fontSize(13).fontColor('#999').margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Button('发现技能').type(ButtonType.Capsule).backgroundColor('#FF6B35').fontColor('#FFF')
      }.width('100%').padding({ left: 24, right: 24, top: 20, bottom: 16 })

      if (this.loading) {
        Column() { LoadingProgress().width(40).height(40) }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.skills.length === 0) {
        Column() {
          Text('暂无已安装技能').fontSize(16).fontColor('#999')
          Text('从 GitHub 仓库发现并安装技能').fontSize(13).fontColor('#BBB').margin({ top: 8 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.skills, (sk: Skill) => {
            ListItem() {
              Row() {
                Column() {
                  Text(sk.name).fontSize(16).fontWeight(FontWeight.Medium)
                  Text(sk.description).fontSize(13).fontColor('#888').margin({ top: 4 }).maxLines(2)
                  Row() {
                    Text(sk.version).fontSize(11).fontColor('#999')
                    if (sk.source.length > 0) {
                      Text(sk.source).fontSize(11).fontColor('#FF6B35').margin({ left: 12 })
                    }
                  }.margin({ top: 6 })
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Button('卸载').type(ButtonType.Capsule).backgroundColor('#FFEBEE').fontColor('#F44336').fontSize(12).height(32)
                  .onClick(async () => {
                    const store = dbService.getStore();
                    if (store) {
                      try {
                        await store.executeSql('DELETE FROM skills WHERE id=?', [sk.id]);
                        await this.loadData();
                      } catch (e) {
                        console.error('delete skill failed');
                      }
                    }
                  })
              }.width('100%').padding(16).backgroundColor('#FFF').borderRadius(12).shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
            }
          })
        }.width('100%').layoutWeight(1).padding({ left: 24, right: 24 })
      }
    }.width('100%').height('100%')
  }
}
