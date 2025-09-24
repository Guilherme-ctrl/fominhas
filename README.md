# ⚽ Fominhas - Indoor Football Management App

> **Sistema completo de gestão de torneios de futebol indoor desenvolvido em Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-Private-red.svg)]()

## 📱 Sobre o Projeto

**Fominhas** é uma aplicação móvel completa para gerenciamento de torneios de futebol indoor, oferecendo uma experiência completa desde o cadastro de jogadores até a finalização de campeonatos com captura de fotos dos vencedores.

### 🎯 Principais Funcionalidades

- **👥 Gestão de Jogadores**: Cadastro completo com posições, estatísticas e informações de contato
- **🏆 Torneios**: Criação, gerenciamento e acompanhamento de campeonatos
- **⚽ Partidas**: Sistema completo de agendamento, resultados e estatísticas
- **📊 Dashboard**: Visão geral de torneios, classificação e estatísticas
- **🔐 Autenticação**: Login integrado com Google e Apple
- **📸 Captura de Momentos**: Sistema de fotos dos times vencedores
- **📱 Interface Moderna**: Design responsivo com Material 3

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture** com as seguintes camadas:

```
lib/
├── core/                  # Componentes centrais
│   ├── errors/           # Tratamento de erros
│   ├── services/         # Serviços compartilhados
│   ├── state/           # Gestão de estado
│   └── theme/           # Temas da aplicação
├── features/            # Módulos por funcionalidade
│   ├── auth/           # Autenticação
│   ├── players/        # Gestão de jogadores
│   ├── matches/        # Sistema de partidas
│   └── tournament/     # Torneios
└── shared/             # Componentes compartilhados
```

### 🎨 Padrões Implementados

- **🏛️ Clean Architecture**: Separação clara de responsabilidades
- **🔄 BLoC Pattern**: Gestão de estado reativa
- **📦 Repository Pattern**: Abstração da camada de dados
- **🎯 Dependency Injection**: Utilizando flutter_modular
- **⚡ Error Handling**: Sistema centralizado de tratamento de erros
- **📝 Logging**: Sistema estruturado de logs com timestamps

## 🛠️ Tecnologias Utilizadas

### Framework & Linguagem
- **Flutter** 3.35.4 (Stable)
- **Dart** 3.9.2

### Backend & Database
- **Firebase Core** - Infraestrutura
- **Cloud Firestore** - Banco de dados NoSQL
- **Firebase Auth** - Autenticação
- **Firebase Storage** - Armazenamento de arquivos
- **Firebase Crashlytics** - Monitoramento de crashes

### Gestão de Estado
- **flutter_bloc** - Implementação do padrão BLoC
- **equatable** - Comparação de objetos

### Autenticação
- **google_sign_in** - Login com Google
- **sign_in_with_apple** - Login com Apple

### Utilitários
- **dartz** - Programação funcional
- **intl** - Internacionalização
- **image_picker** - Captura de imagens
- **share_plus** - Compartilhamento
- **permission_handler** - Gerenciamento de permissões

## 🚀 Começando

### Pré-requisitos

- Flutter SDK 3.35.4+
- Dart SDK 3.9.2+
- Android Studio / VS Code
- Conta Firebase ativa

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/fominhas.git
   cd fominhas
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o Firebase**
   - Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
   - Adicione os arquivos de configuração:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Execute o projeto**
   ```bash
   flutter run
   ```

### 🧪 Executando Testes

```bash
# Executar todos os testes
flutter test

# Executar testes com coverage
flutter test --coverage

# Análise de código
flutter analyze
```

## 📁 Estrutura do Projeto

### Core Components
- **ErrorHandler**: Sistema centralizado de tratamento de erros
- **CubitState**: Estados genéricos para todos os cubits
- **LoggingService**: Sistema de logs estruturados
- **AppTheme**: Sistema de temas com Material 3

### Features
- **Authentication**: Sistema completo de autenticação
- **Players Management**: CRUD completo de jogadores
- **Tournament System**: Gestão completa de torneios
- **Matches Management**: Sistema de partidas e resultados

## 🔐 Autenticação

O sistema suporta múltiplas formas de autenticação:

- **Google Sign-In**: Integração completa com conta Google
- **Apple Sign-In**: Para dispositivos iOS
- **Gerenciamento de Sessão**: Persistência segura de sessões

## 🎨 Design System

- **Material 3**: Design system moderno do Google
- **Tema Escuro**: Interface otimizada para baixa luminosidade
- **Responsividade**: Adaptação automática para diferentes tamanhos de tela
- **Acessibilidade**: Componentes acessíveis por padrão

## 📊 Monitoramento

- **Firebase Crashlytics**: Monitoramento de crashes em tempo real
- **Structured Logging**: Logs estruturados para debugging
- **Error Tracking**: Rastreamento centralizado de erros
- **Performance**: Métricas de performance da aplicação

## 🧪 Testes

O projeto conta com cobertura abrangente de testes:

- **✅ 91 Testes Unitários** passando
- **🧪 BLoC Testing**: Testes de todos os cubits
- **🎯 Repository Testing**: Testes da camada de dados
- **📱 Widget Testing**: Testes de componentes UI

## 🚀 Deploy

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📄 Licença

Este projeto é proprietário e confidencial.

## 👥 Contribuição

Este é um projeto privado. Para contribuições, entre em contato com a equipe de desenvolvimento.

---

**Desenvolvido com ❤️ usando Flutter**
