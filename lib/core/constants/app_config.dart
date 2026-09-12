class AppConfig {
  const AppConfig._();

  static const appName = 'AgroPredict AI';
  static const tagline = 'Smart Farming. Better Decisions. Higher Profits.';
  static const demoMode = true;
  static const aiEndpoint = String.fromEnvironment('AGRO_AI_ENDPOINT');
  static const visionEndpoint = String.fromEnvironment('AGRO_VISION_ENDPOINT');
  static const groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const groqModel = 'openai/gpt-oss-120b';
}
