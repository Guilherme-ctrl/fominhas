#!/bin/bash

# 🚀 Deploy Script para Fominhas
# Este script automatiza o processo de deploy local

set -e # Exit on any error

echo "🚀 Iniciando deploy do Fominhas..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir com cores
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar se estamos na pasta correta
if [ ! -f "pubspec.yaml" ]; then
    print_error "Este script deve ser executado na pasta raiz do projeto Flutter!"
    exit 1
fi

# Verificar se o Fastlane está disponível
if [ ! -f "ios/Gemfile" ]; then
    print_error "Fastlane não configurado. Execute a pipeline do GitHub primeiro."
    exit 1
fi

print_step "Limpando projeto..."
flutter clean
print_success "Projeto limpo"

print_step "Obtendo dependências Flutter..."
flutter pub get
print_success "Dependências Flutter obtidas"

print_step "Executando testes..."
if flutter test; then
    print_success "Todos os testes passaram"
else
    print_warning "Alguns testes falharam, continuando mesmo assim..."
fi

print_step "Executando análise de código..."
if flutter analyze; then
    print_success "Código analisado sem problemas"
else
    print_warning "Análise de código encontrou problemas, continuando mesmo assim..."
fi

print_step "Construindo aplicação iOS..."
flutter build ios --release --no-codesign
print_success "Aplicação iOS construída"

print_step "Instalando dependências do Fastlane..."
cd ios
bundle install
print_success "Dependências do Fastlane instaladas"

print_step "Instalando pods do CocoaPods..."
pod install
print_success "Pods instalados"

print_step "Executando deploy via Fastlane..."
if bundle exec fastlane release_testflight; then
    print_success "🎉 Deploy concluído com sucesso!"
    print_success "📱 Check TestFlight for the new build"
else
    print_error "Deploy falhou. Verifique os logs acima."
    exit 1
fi

cd ..

print_success "🚀 Deploy do Fominhas concluído!"
echo ""
echo "📋 Próximos passos:"
echo "1. Verifique o TestFlight no App Store Connect"
echo "2. Distribua para os testadores conforme necessário"
echo "3. Colete feedback dos usuários"
echo ""
echo "🔗 App Store Connect: https://appstoreconnect.apple.com/"