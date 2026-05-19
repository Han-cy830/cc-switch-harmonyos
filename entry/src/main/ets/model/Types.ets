export type AppId = 'claude' | 'codex' | 'gemini' | 'opencode' | 'openclaw' | 'hermes';

export type ProviderCategory = 'official' | 'third_party' | 'aggregator' | 'cloud' | 'custom';

export interface Provider {
  id: string;
  appType: AppId;
  name: string;
  baseUrl: string;
  apiKey: string;
  model: string;
  category: ProviderCategory;
  iconUrl: string;
  color: string;
  isCurrent: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
  maxTokens: number;
  temperature: number;
  topP: number;
  systemPrompt: string;
  customHeaders: Record<string, string>;
  usageScript: string;
}

export interface McpServer {
  id: string;
  name: string;
  transport: 'stdio' | 'http' | 'sse';
  command: string;
  args: string[];
  env: Record<string, string>;
  url: string;
  enabled: boolean;
  appEnabled: Record<string, boolean>;
  createdAt: string;
  updatedAt: string;
}

export interface Prompt {
  id: string;
  appType: AppId;
  name: string;
  content: string;
  enabled: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface AppSettings {
  language: string;
  theme: 'light' | 'dark' | 'system';
  launchOnStartup: boolean;
  silentStartup: boolean;
  minimizeToTray: boolean;
  showInTray: boolean;
  enableLocalProxy: boolean;
  proxyPort: number;
  enableFailover: boolean;
  visibleApps: Record<string, boolean>;
}

export interface Skill {
  id: string;
  name: string;
  description: string;
  source: string;
  version: string;
  installedAt: string;
  appEnabled: Record<string, boolean>;
}

export interface Session {
  id: string;
  appType: AppId;
  title: string;
  startedAt: string;
  endedAt: string;
  messageCount: number;
  totalTokens: number;
}

export interface AppConfig {
  appId: AppId;
  label: string;
  icon: string;
  configPath: string;
  description: string;
}

export const APP_CONFIGS: AppConfig[] = [
  { appId: 'claude', label: 'Claude Code', icon: '\u{1F7E0}', configPath: '~/.claude/settings.json', description: 'Claude Code CLI' },
  { appId: 'codex', label: 'Codex', icon: '\u{1F7E2}', configPath: '~/.codex/config.json', description: 'OpenAI Codex CLI' },
  { appId: 'gemini', label: 'Gemini', icon: '\u{1F535}', configPath: '~/.gemini/settings.json', description: 'Google Gemini CLI' },
  { appId: 'opencode', label: 'OpenCode', icon: '\u{1F7E3}', configPath: '~/.opencode/config.json', description: 'OpenCode CLI' },
  { appId: 'openclaw', label: 'OpenClaw', icon: '\u{1F534}', configPath: '~/.openclaw/openclaw.json', description: 'OpenClaw Agent' },
  { appId: 'hermes', label: 'Hermes', icon: '\u{1F7E1}', configPath: '~/.hermes/config.yaml', description: 'Hermes Agent' }
];
