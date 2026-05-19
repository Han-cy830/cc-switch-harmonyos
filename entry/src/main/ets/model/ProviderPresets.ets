import { Provider, AppId, ProviderCategory } from './Types';

export class ProviderPreset {
  id: string = '';
  name: string = '';
  appType: AppId = 'claude';
  baseUrl: string = '';
  model: string = '';
  category: ProviderCategory = 'third_party';
  iconUrl: string = '';
  color: string = '';
  description: string = '';
}

function makePreset(id: string, name: string, appType: AppId, baseUrl: string, model: string, category: ProviderCategory, color: string, desc: string): ProviderPreset {
  const p = new ProviderPreset();
  p.id = id;
  p.name = name;
  p.appType = appType;
  p.baseUrl = baseUrl;
  p.model = model;
  p.category = category;
  p.color = color;
  p.description = desc;
  return p;
}

export function getClaudePresets(): ProviderPreset[] {
  const list: ProviderPreset[] = [];
  list.push(makePreset('claude-official', 'Claude Official', 'claude', 'https://api.anthropic.com', 'claude-sonnet-4-20250514', 'official', '#FF6B35', 'Anthropic 官方 API'));
  list.push(makePreset('claude-shengsuanyun', '胜算云', 'claude', 'https://api.shengsuanyun.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#6366F1', '胜算云中转'));
  list.push(makePreset('claude-pateway', 'PatewayAI', 'claude', 'https://api.pateway.ai/v1', 'claude-sonnet-4-20250514', 'aggregator', '#8B5CF6', 'PatewayAI 中转'));
  list.push(makePreset('claude-volcengine', '火山 Agentplan', 'claude', 'https://ark.cn-beijing.volces.com/api/v3', 'claude-sonnet-4-20250514', 'cloud', '#FF4500', '火山方舟 Agent Plan'));
  list.push(makePreset('claude-byteplus', 'BytePlus', 'claude', 'https://ark.ap-southeast.bytepluses.com/api/v3', 'claude-sonnet-4-20250514', 'cloud', '#00D4AA', 'BytePlus ModelArk'));
  list.push(makePreset('claude-doubao', 'DouBao Seed', 'claude', 'https://ark.cn-beijing.volces.com/api/v3', 'doubao-seed', 'cloud', '#FF6B35', '豆包 Seed'));
  list.push(makePreset('claude-deepseek', 'DeepSeek', 'claude', 'https://api.deepseek.com/v1', 'deepseek-chat', 'third_party', '#0066FF', 'DeepSeek API'));
  list.push(makePreset('claude-zhipu', 'Zhipu GLM', 'claude', 'https://open.bigmodel.cn/api/paas/v4', 'glm-4-plus', 'third_party', '#7C3AED', '智谱 GLM'));
  list.push(makePreset('claude-zhipu-en', 'Zhipu GLM en', 'claude', 'https://open.bigmodel.cn/api/paas/v4', 'glm-4-plus', 'third_party', '#7C3AED', '智谱 GLM (英文)'));
  list.push(makePreset('claude-baidu', 'Baidu Qianfan Coding Plan', 'claude', 'https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop', 'ernie-4.0-8k', 'cloud', '#2319DC', '百度千帆 Coding Plan'));
  list.push(makePreset('claude-bailian', 'Bailian', 'claude', 'https://dashscope.aliyuncs.com/compatible-mode/v1', 'qwen-max', 'cloud', '#FF6A00', '阿里百炼'));
  list.push(makePreset('claude-bailian-coding', 'Bailian For Coding', 'claude', 'https://dashscope.aliyuncs.com/compatible-mode/v1', 'qwen-coder-plus', 'cloud', '#FF6A00', '阿里百炼 Coding'));
  list.push(makePreset('claude-kimi', 'Kimi', 'claude', 'https://api.moonshot.cn/v1', 'moonshot-v1-128k', 'third_party', '#000000', 'Kimi API'));
  list.push(makePreset('claude-kimi-coding', 'Kimi For Coding', 'claude', 'https://api.moonshot.cn/v1', 'moonshot-v1-128k', 'third_party', '#000000', 'Kimi Coding Plan'));
  list.push(makePreset('claude-stepfun', 'StepFun', 'claude', 'https://api.stepfun.com/v1', 'step-2-16k', 'third_party', '#FF4D6A', '阶跃星辰'));
  list.push(makePreset('claude-stepfun-en', 'StepFun en', 'claude', 'https://api.stepfun.com/v1', 'step-2-16k', 'third_party', '#FF4D6A', '阶跃星辰 (英文)'));
  list.push(makePreset('claude-modelscope', 'ModelScope', 'claude', 'https://api-inference.modelscope.cn/v1', 'Qwen/Qwen2.5-72B-Instruct', 'aggregator', '#6C47FF', '魔搭社区'));
  list.push(makePreset('claude-katcoder', 'KAT-Coder', 'claude', 'https://api.kat-coder.com/v1', 'kat-coder', 'third_party', '#FF8C00', 'KAT-Coder'));
  list.push(makePreset('claude-longcat', 'Longcat', 'claude', 'https://api.longcat.chat/v1', 'longcat-chat', 'third_party', '#1E90FF', 'Longcat'));
  list.push(makePreset('claude-minimax', 'MiniMax', 'claude', 'https://api.minimax.chat/v1', 'MiniMax-Text-01', 'third_party', '#00C8FF', 'MiniMax API'));
  list.push(makePreset('claude-minimax-en', 'MiniMax en', 'claude', 'https://api.minimax.chat/v1', 'MiniMax-Text-01', 'third_party', '#00C8FF', 'MiniMax (英文)'));
  list.push(makePreset('claude-bailing', 'BaiLing', 'claude', 'https://api.bailing.ai/v1', 'bailing-chat', 'third_party', '#FF2D55', '百灵'));
  list.push(makePreset('claude-aihubmix', 'AiHubMix', 'claude', 'https://aihubmix.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF6B35', 'AiHubMix 中转'));
  list.push(makePreset('claude-siliconflow', 'SiliconFlow', 'claude', 'https://api.siliconflow.cn/v1', 'deepseek-ai/DeepSeek-V3', 'aggregator', '#6366F1', '硅基流动'));
  list.push(makePreset('claude-siliconflow-en', 'SiliconFlow en', 'claude', 'https://api.siliconflow.cn/v1', 'deepseek-ai/DeepSeek-V3', 'aggregator', '#6366F1', '硅基流动 (英文)'));
  list.push(makePreset('claude-dmxapi', 'DMXAPI', 'claude', 'https://www.dmxapi.cn/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF4500', 'DMXAPI 中转'));
  list.push(makePreset('claude-packycode', 'PackyCode', 'claude', 'https://api.packyapi.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#8B5CF6', 'PackyCode 中转'));
  list.push(makePreset('claude-claudeapi', 'ClaudeAPI', 'claude', 'https://api.claudeapi.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF6B35', 'ClaudeAPI 中转'));
  list.push(makePreset('claude-claudecn', 'ClaudeCN', 'claude', 'https://api.claudecn.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF6B35', 'ClaudeCN 中转'));
  list.push(makePreset('claude-runapi', 'RunAPI', 'claude', 'https://api.runapi.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#00CC66', 'RunAPI 中转'));
  list.push(makePreset('claude-relaxycode', 'RelaxyCode', 'claude', 'https://api.relaxycode.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF69B4', 'RelaxyCode 中转'));
  list.push(makePreset('claude-cubence', 'Cubence', 'claude', 'https://api.cubence.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#20B2AA', 'Cubence 中转'));
  list.push(makePreset('claude-aigocode', 'AIGoCode', 'claude', 'https://api.aigocode.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF8C00', 'AIGoCode 中转'));
  list.push(makePreset('claude-rightcode', 'RightCode', 'claude', 'https://api.right.codes/v1', 'claude-sonnet-4-20250514', 'aggregator', '#4169E1', 'RightCode 中转'));
  list.push(makePreset('claude-aicodemirror', 'AICodeMirror', 'claude', 'https://api.aicodemirror.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#9370DB', 'AICodeMirror 中转'));
  list.push(makePreset('claude-aicoding', 'AICoding', 'claude', 'https://api.aicoding.sh/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF6347', 'AICoding 中转'));
  list.push(makePreset('claude-crazyrouter', 'CrazyRouter', 'claude', 'https://api.crazyrouter.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF1493', 'CrazyRouter 中转'));
  list.push(makePreset('claude-ssaicode', 'SSSAiCode', 'claude', 'https://api.sssaicode.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#32CD32', 'SSSAiCode 中转'));
  list.push(makePreset('claude-youyun', '优云智算', 'claude', 'https://api.youyun.com/v1', 'claude-sonnet-4-20250514', 'cloud', '#00BFFF', '优云智算'));
  list.push(makePreset('claude-youyun-coding', '优云智算 Coding Plan', 'claude', 'https://api.youyun.com/v1', 'claude-sonnet-4-20250514', 'cloud', '#00BFFF', '优云智算 Coding Plan'));
  list.push(makePreset('claude-micu', 'Micu', 'claude', 'https://api.micu.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF4500', 'Micu 中转'));
  list.push(makePreset('claude-ctok', 'CTok.ai', 'claude', 'https://api.ctok.ai/v1', 'claude-sonnet-4-20250514', 'aggregator', '#8A2BE2', 'CTok.ai 中转'));
  list.push(makePreset('claude-eflowcode', 'E-FlowCode', 'claude', 'https://api.eflowcode.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#20B2AA', 'E-FlowCode 中转'));
  list.push(makePreset('claude-lionccapi', 'LionCCAPI', 'claude', 'https://api.lionccapi.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#DAA520', 'LionCCAPI 中转'));
  list.push(makePreset('claude-openrouter', 'OpenRouter', 'claude', 'https://openrouter.ai/api/v1', 'anthropic/claude-sonnet-4-20250514', 'aggregator', '#627EEA', 'OpenRouter'));
  list.push(makePreset('claude-therouter', 'TheRouter', 'claude', 'https://api.therouter.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF6B35', 'TheRouter 中转'));
  list.push(makePreset('claude-novita', 'Novita AI', 'claude', 'https://api.novita.ai/v3', 'claude-sonnet-4-20250514', 'aggregator', '#7B68EE', 'Novita AI'));
  list.push(makePreset('claude-copilot', 'GitHub Copilot', 'claude', 'https://api.githubcopilot.com', 'claude-sonnet-4-20250514', 'official', '#238636', 'GitHub Copilot'));
  list.push(makePreset('claude-lemondata', 'LemonData', 'claude', 'https://api.lemondata.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FFD700', 'LemonData 中转'));
  list.push(makePreset('claude-nvidia', 'Nvidia', 'claude', 'https://integrate.api.nvidia.com/v1', 'claude-sonnet-4-20250514', 'cloud', '#76B900', 'Nvidia API'));
  list.push(makePreset('claude-pipellm', 'PIPELLM', 'claude', 'https://api.pipellm.com/v1', 'claude-sonnet-4-20250514', 'aggregator', '#FF6B35', 'PIPELLM 中转'));
  list.push(makePreset('claude-xiaomi', 'Xiaomi MiMo', 'claude', 'https://api.mimo.xiaomi.com/v1', 'mimo-chat', 'cloud', '#FF6900', '小米 MiMo'));
  list.push(makePreset('claude-bedrock', 'AWS Bedrock (AKSK)', 'claude', 'https://bedrock-runtime.us-east-1.amazonaws.com', 'anthropic.claude-sonnet-4-20250514-v1:0', 'cloud', '#FF9900', 'AWS Bedrock AKSK'));
  list.push(makePreset('claude-bedrock-key', 'AWS Bedrock (API Key)', 'claude', 'https://bedrock-runtime.us-east-1.amazonaws.com', 'anthropic.claude-sonnet-4-20250514-v1:0', 'cloud', '#FF9900', 'AWS Bedrock API Key'));
  return list;
}

export function getCodexPresets(): ProviderPreset[] {
  const list: ProviderPreset[] = [];
  list.push(makePreset('codex-official', 'Codex Official', 'codex', 'https://api.openai.com/v1', 'codex-mini', 'official', '#10A37F', 'OpenAI 官方'));
  list.push(makePreset('codex-copilot', 'GitHub Copilot', 'codex', 'https://api.githubcopilot.com', 'codex-mini', 'official', '#238636', 'GitHub Copilot'));
  return list;
}

export function getGeminiPresets(): ProviderPreset[] {
  const list: ProviderPreset[] = [];
  list.push(makePreset('gemini-official', 'Gemini Official', 'gemini', 'https://generativelanguage.googleapis.com/v1beta', 'gemini-2.5-flash', 'official', '#4285F4', 'Google 官方'));
  list.push(makePreset('gemini-siliconflow', 'SiliconFlow', 'gemini', 'https://api.siliconflow.cn/v1', 'gemini-2.5-flash', 'aggregator', '#6366F1', '硅基流动'));
  return list;
}

export function getAllPresets(): ProviderPreset[] {
  const all: ProviderPreset[] = [];
  const claude = getClaudePresets();
  for (let i = 0; i < claude.length; i++) {
    all.push(claude[i]);
  }
  const codex = getCodexPresets();
  for (let i = 0; i < codex.length; i++) {
    all.push(codex[i]);
  }
  const gemini = getGeminiPresets();
  for (let i = 0; i < gemini.length; i++) {
    all.push(gemini[i]);
  }
  return all;
}

export function getPresetsForApp(appType: AppId): ProviderPreset[] {
  if (appType === 'claude') return getClaudePresets();
  if (appType === 'codex') return getCodexPresets();
  if (appType === 'gemini') return getGeminiPresets();
  const empty: ProviderPreset[] = [];
  return empty;
}
