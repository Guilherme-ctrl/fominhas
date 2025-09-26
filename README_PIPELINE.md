# 🚀 Pipeline Automática - Fominhas

Pipeline completa para distribuição automática no TestFlight com controle de versão.

## ⚡ Início Rápido

1. **Configure os Secrets no GitHub** (veja `PIPELINE_SETUP.md`)
2. **Faça push na branch `main`** → Deploy automático
3. **Ou execute manualmente** em GitHub Actions

## 📱 Pipelines Disponíveis

### 🔧 Pipeline Padrão
- **Arquivo**: `.github/workflows/ios-testflight.yml`
- **Tecnologia**: Xcode + xcrun
- **Uso**: Simples, para projetos básicos

### 🚀 Pipeline Fastlane ⭐ **Recomendada**
- **Arquivo**: `.github/workflows/ios-testflight-fastlane.yml`
- **Tecnologia**: Fastlane + Ruby
- **Uso**: Robusta, para projetos profissionais

## 🎯 O que a Pipeline Faz

1. **📈 Incrementa versão automaticamente**
   - `4.1.0+2` → `4.1.1+3`
   - Cria tag git: `v4.1.1+3`

2. **🧪 Executa testes e análise**
   - `flutter test`
   - `flutter analyze`

3. **🏗️ Build iOS Release**
   - `flutter build ios --release`
   - Gera arquivo `.ipa`

4. **📤 Upload para TestFlight**
   - Upload automático via API
   - Disponível em minutos

5. **📋 Cria release no GitHub**
   - Release notes automáticas
   - Tag de versão

## 🚀 Como Usar

### Automático (Recomendado)
```bash
git add .
git commit -m "✨ Nova funcionalidade"
git push origin main
```
→ **Deploy automático!** 🎉

### Manual (GitHub Actions)
1. Vá em **Actions** no GitHub
2. Selecione **🚀 iOS TestFlight**
3. **Run workflow**
4. Escolha tipo de versão: `patch`, `minor`, `major`

### Local (Para Testes)
```bash
./deploy.sh
```

## 📊 Controle de Versão

- **patch**: `4.1.0` → `4.1.1` (bug fixes)
- **minor**: `4.1.0` → `4.2.0` (novas features)
- **major**: `4.1.0` → `5.0.0` (breaking changes)

Build number sempre incrementado: `+1`, `+2`, `+3`...

## 📋 Status da Pipeline

| Etapa | Duração | Descrição |
|-------|---------|-----------|
| Version Bump | ~1 min | Incrementa versão |
| Tests | ~2 min | Flutter test + analyze |
| iOS Build | ~8 min | Build + Archive |
| TestFlight | ~3 min | Upload + Processing |
| **Total** | **~15 min** | **Até aparecer no TestFlight** |

## 🔐 Secrets Necessários

Configure no GitHub **Settings** → **Secrets**:

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_ISSUER_ID` 
- `APP_STORE_CONNECT_API_KEY`
- `IOS_EXPORT_PLIST`

Ver detalhes em `PIPELINE_SETUP.md`

## 📱 Monitoramento

- **GitHub Actions**: Status em tempo real
- **GitHub Releases**: Versões publicadas
- **TestFlight**: Builds disponíveis

## 🚨 Troubleshooting

### Pipeline Falha?
1. Veja logs em **Actions**
2. Verifique **Secrets**
3. Teste build local: `./deploy.sh`

### TestFlight não aparece?
- Aguarde até 30min para processamento
- Verifique App Store Connect

---

🎉 **Pronta para usar!** Push na `main` = TestFlight automático!