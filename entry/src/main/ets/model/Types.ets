export type AppId = 'claude' | 'codex' | 'gemini' | 'opencode' | 'openclaw' | 'hermes';

export type ProviderCategory = 'official' | 'third_party' | 'aggregator' | 'cloud' | 'custom';

export class Provider {
  id: string = '';
  appType: AppId = 'claude';
  name: string = '';
  baseUrl: string = '';
  apiKey: string = '';
  model: string = '';
  category: ProviderCategory = 'custom';
  iconUrl: string = '';
  color: string = '';
  isCurrent: boolean = false;
  sortOrder: number = 0;
  createdAt: string = '';
  updatedAt: string = '';
  maxTokens: number = 4096;
  temperature: number = 1.0;
  topP: number = 1.0;
  systemPrompt: string = '';
  customHeaders: string = '{}';
  usageScript: string = '';
}

export class McpServer {
  id: string = '';
  name: string = '';
  transport: string = 'stdio';
  command: string = '';
  argsStr: string = '[]';
  envStr: string = '{}';
  url: string = '';
  enabled: boolean = true;
  appEnabledStr: string = '{}';
  createdAt: string = '';
  updatedAt: string = '';
}

export class Prompt {
  id: string = '';
  appType: AppId = 'claude';
  name: string = '';
  content: string = '';
  enabled: boolean = true;
  sortOrder: number = 0;
  createdAt: string = '';
  updatedAt: string = '';
}

export class AppSettings {
  language: string = 'zh';
  theme: string = 'system';
  launchOnStartup: boolean = false;
  silentStartup: boolean = false;
  minimizeToTray: boolean = true;
  showInTray: boolean = true;
  enableLocalProxy: boolean = false;
  proxyPort: number = 15721;
  enableFailover: boolean = false;
}

export class Skill {
  id: string = '';
  name: string = '';
  description: string = '';
  source: string = '';
  version: string = '';
  installedAt: string = '';
}

export class AppConfig {
  appId: AppId = 'claude';
  label: string = '';
  icon: string = '';
  description: string = '';
}

export function getAppConfigs(): AppConfig[] {
  const configs: AppConfig[] = [];
  const c1: AppConfig = new AppConfig();
  c1.appId = 'claude'; c1.label = 'Claude Code'; c1.icon = '🟠'; c1.description = 'Claude Code CLI';
  configs.push(c1);
  const c2: AppConfig = new AppConfig();
  c2.appId = 'codex'; c2.label = 'Codex'; c2.icon = '🟢'; c2.description = 'OpenAI Codex CLI';
  configs.push(c2);
  const c3: AppConfig = new AppConfig();
  c3.appId = 'gemini'; c3.label = 'Gemini'; c3.icon = '🔵'; c3.description = 'Google Gemini CLI';
  configs.push(c3);
  const c4: AppConfig = new AppConfig();
  c4.appId = 'opencode'; c4.label = 'OpenCode'; c4.icon = '🟣'; c4.description = 'OpenCode CLI';
  configs.push(c4);
  const c5: AppConfig = new AppConfig();
  c5.appId = 'openclaw'; c5.label = 'OpenClaw'; c5.icon = '🔴'; c5.description = 'OpenClaw Agent';
  configs.push(c5);
  const c6: AppConfig = new AppConfig();
  c6.appId = 'hermes'; c6.label = 'Hermes'; c6.icon = '🟡'; c6.description = 'Hermes Agent';
  configs.push(c6);
  return configs;
}
