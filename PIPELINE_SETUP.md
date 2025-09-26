# 🚀 Pipeline CI/CD - Configuração

Este guia explica como configurar a pipeline automática para distribuição no TestFlight.

## 📋 Pré-requisitos

1. **Conta Apple Developer** ativa
2. **App Store Connect** configurado
3. **Certificados e Provisioning Profiles** configurados no Xcode
4. **Repositório GitHub** com permissões de push

## 🔐 Secrets Necessários

Configure os seguintes secrets no GitHub:

### 1. App Store Connect API

Vá para [App Store Connect > Users and Access > Integrations > App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api):

- **`APP_STORE_CONNECT_API_KEY_ID`**: ID da chave API
- **`APP_STORE_CONNECT_API_ISSUER_ID`**: Issuer ID 
- **`APP_STORE_CONNECT_API_KEY`**: Conteúdo do arquivo `.p8` (incluindo `-----BEGIN PRIVATE KEY-----`)

### 2. Configuração de Exportação iOS

- **`IOS_EXPORT_PLIST`**: Conteúdo do arquivo `export_options.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>destination</key>
    <string>upload</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>teamID</key>
    <string>SEU_TEAM_ID_AQUI</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.portalsolutions.fominhas</key>
        <string>NOME_DO_PROVISIONING_PROFILE</string>
    </dict>
    <key>manageAppVersionAndBuildNumber</key>
    <false/>
</dict>
</plist>
```

## 📱 Como Configurar no GitHub

### 1. Acessar Secrets

1. Vá para o repositório no GitHub
2. Clique em **Settings** → **Secrets and variables** → **Actions**
3. Clique em **New repository secret**

### 2. Adicionar Secrets

Para cada secret listado acima:
1. **Name**: Nome do secret (ex: `APP_STORE_CONNECT_API_KEY_ID`)
2. **Value**: Valor correspondente
3. Clique em **Add secret**

### 3. Verificar Configuração

- Certifique-se de que todos os 4 secrets estão configurados
- Verifique se os valores estão corretos (sem espaços extras)

## 🔧 Como Obter App Store Connect API

### 1. Criar Chave API

1. Acesse [App Store Connect](https://appstoreconnect.apple.com/)
2. Vá em **Users and Access** → **Integrations** → **App Store Connect API**
3. Clique em **Generate API Key**
4. Preencha:
   - **Name**: `GitHub Actions Fominhas`
   - **Access**: `App Manager` ou `Developer`
5. Clique em **Generate**
6. **Baixe o arquivo `.p8`** (só pode baixar uma vez!)
7. Anote o **Key ID** e **Issuer ID**

### 2. Configurar Team ID

1. No Xcode, abra o projeto `ios/Runner.xcworkspace`
2. Selecione o target **Runner**
3. Na aba **Signing & Capabilities**, anote o **Team ID**
4. Use esse valor no `export_options.plist`

## 🚀 Como Usar a Pipeline

### Automático (Push na Branch Principal)

Toda vez que você fizer push na branch `main` ou `master`:
1. A versão será automaticamente incrementada (patch)
2. Testes serão executados
3. App será buildado e enviado para TestFlight

### Manual (Workflow Dispatch)

1. Vá para **Actions** no GitHub
2. Selecione **🚀 iOS TestFlight Distribution**
3. Clique em **Run workflow**
4. Escolha:
   - **Version increment**: `patch`, `minor`, ou `major`
   - **Skip tests**: Se quiser pular os testes
5. Clique em **Run workflow**

## 📊 Controle de Versão

### Automático

- **Push na main**: Incrementa `patch` (4.1.0 → 4.1.1)
- **Build number**: Sempre incrementado automaticamente

### Manual

- **patch**: 4.1.0 → 4.1.1
- **minor**: 4.1.0 → 4.2.0
- **major**: 4.1.0 → 5.0.0

## 📱 Monitoramento

### GitHub

- **Actions**: Ver status da pipeline
- **Releases**: Ver versões criadas automaticamente
- **Tags**: Ver tags de versão

### TestFlight

- **App Store Connect** → **TestFlight**
- Novas builds aparecerão automaticamente
- Distribua para testers conforme necessário

## 🚨 Troubleshooting

### Erro de Certificado

```
error: No profiles for 'com.portalsolutions.fominhas' were found
```

**Solução**: Abra o Xcode, vá em Signing & Capabilities e refaça o signing automático.

### Erro de API Key

```
error: API key not found
```

**Solução**: Verifique se os secrets `APP_STORE_CONNECT_API_KEY_*` estão configurados corretamente.

### Build Falha

```
error: Build input file cannot be found
```

**Solução**: Execute `flutter clean` e `flutter pub get` localmente, depois faça push novamente.

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs na aba **Actions** do GitHub
2. Confirme que todos os secrets estão configurados
3. Teste o build localmente primeiro: `flutter build ios --release`

---

## 🚀 Opções de Pipeline

Você tem duas opções de pipeline:

### 1. Pipeline Padrão (`ios-testflight.yml`)
- Usa apenas Xcode e xcrun
- Mais simples, sem dependências adicionais
- Requer configuração manual de certificados

### 2. Pipeline com Fastlane (`ios-testflight-fastlane.yml`) ⭐ **Recomendado**
- Usa Fastlane para automação robusta
- Melhor gerenciamento de certificados
- Mais confiável para CI/CD
- Logs mais detalhados

## 📦 Configuração do Fastlane (Recomendado)

Se escolher usar Fastlane:

### 1. Configurar Apple ID no Appfile

Edite o arquivo `ios/fastlane/Appfile` e substitua:
```ruby
apple_id("SEU_APPLE_ID_AQUI@email.com")
team_id("SEU_TEAM_ID_AQUI")
```

### 2. Instalar Fastlane Localmente (Opcional)

```bash
cd ios
bundle install
bundle exec fastlane --help
```

### 3. Testar Localmente

```bash
# Build para teste
bundle exec fastlane build_for_testing

# Upload para TestFlight (após configurar certificados)
bundle exec fastlane release_testflight
```

### 4. Secrets Adicionais para Fastlane

Se usar Match (gerenciamento de certificados):
- **`MATCH_PASSWORD`**: Senha do repositório de certificados
- **`MATCH_GIT_URL`**: URL do repositório Git com certificados

🎉 **Pronto!** Sua pipeline está configurada para distribuição automática no TestFlight!
