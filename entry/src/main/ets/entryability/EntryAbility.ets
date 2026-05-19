import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { dbService } from '../service/DatabaseService';
import { settingsService } from '../service/SettingsService';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0001, 'CCSwitch', 'onCreate');
    await dbService.init(this.context);
    await settingsService.load();
  }

  onDestroy(): void { hilog.info(0x0001, 'CCSwitch', 'onDestroy'); }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) { hilog.error(0x0001, 'CCSwitch', 'Load failed: %{public}s', JSON.stringify(err)); return; }
    });
  }

  onWindowStageDestroy(): void {}
  onForeground(): void {}
  onBackground(): void {}
}
