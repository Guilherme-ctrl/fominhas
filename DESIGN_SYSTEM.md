# 🎨 Fominhas Design System

## 📋 Benchmark & Inspiração

Baseado na análise dos melhores apps de esportes:
- **ESPN** - Dark mode elegante
- **Nike Training** - Gradientes e tipografia forte  
- **Strava** - Interface limpa e focada em dados
- **FotMob** - Excelente hierarquia visual
- **TheScore** - Dark theme premium

## 🎭 Paleta de Cores

### Core Colors
- **Primary**: `#00D4AA` (Teal vibrante)
- **Primary Dark**: `#00B894` (Teal escuro)
- **Secondary**: `#6C5CE7` (Roxo moderno)

### Background Colors
- **Background**: `#0D1117` (Azul muito escuro)
- **Surface**: `#161B22` (Superficie escura)
- **Card**: `#21262D` (Fundo dos cards)

### Text Colors
- **Primary Text**: `#E6EDF3` (Texto principal)
- **Secondary Text**: `#8B949E` (Texto secundário)
- **Tertiary Text**: `#656D76` (Texto terciário)

### Status Colors
- **Success**: `#2EA043` (Verde)
- **Warning**: `#D29922` (Laranja)
- **Error**: `#DA3633` (Vermelho)
- **Info**: `#1F6FEB` (Azul)

### Sport Specific
- **Home Team**: `#1F6FEB` (Azul para time da casa)
- **Away Team**: `#DA3633` (Vermelho para time visitante)
- **Goal**: `#2EA043` (Verde para gols)
- **Assist**: `#D29922` (Laranja para assistências)

## 📝 Tipografia

### Headlines
- **Large**: 32px, Weight 700, Height 1.2
- **Medium**: 28px, Weight 600, Height 1.3
- **Small**: 24px, Weight 600, Height 1.3

### Titles
- **Large**: 20px, Weight 600, Height 1.4
- **Medium**: 16px, Weight 600, Height 1.4
- **Small**: 14px, Weight 600, Height 1.4

### Body
- **Large**: 16px, Weight 400, Height 1.5
- **Medium**: 14px, Weight 400, Height 1.5
- **Small**: 12px, Weight 400, Height 1.4

### Labels
- **Large**: 14px, Weight 600, Height 1.4
- **Medium**: 12px, Weight 600, Height 1.4
- **Small**: 11px, Weight 500, Height 1.4

## 🏗️ Componentes

### SportCard
Card principal com gradiente opcional e sombras modernas
```dart
SportCard(
  useGradient: true,
  onTap: () {},
  child: Text('Conteúdo'),
)
```

### StatusBadge
Badges de status inteligentes para torneios e partidas
```dart
StatusBadge.tournament('Em Andamento')
StatusBadge.match('Finalizada')
```

### TeamScore
Display de pontuação com cores por time
```dart
TeamScore(
  teamName: 'Time Azul',
  score: 3,
  isHome: true,
)
```

### PositionBadge
Indicador de posição para jogadores
```dart
PositionBadge.fromPlayerPosition('Goleiro')
```

### SportActionButton
Botões de ação temáticos
```dart
SportActionButton(
  label: 'Criar Torneio',
  icon: Icons.add,
  onPressed: () {},
  isExpanded: true,
)
```

### StatCard
Cards de estatísticas com ícones
```dart
StatCard(
  title: 'Gols',
  value: '15',
  icon: Icons.sports_soccer,
  color: AppTheme.goalColor,
)
```

## 🌈 Gradientes

### Primary Gradient
```dart
LinearGradient(
  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Card Gradient
```dart
LinearGradient(
  colors: [AppTheme.cardDark, AppTheme.surfaceDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

## 📏 Espaçamento

### Padrão de Espaçamento
- **XS**: 4px
- **SM**: 8px
- **MD**: 16px
- **LG**: 24px
- **XL**: 32px

### Border Radius
- **Pequeno**: 8px
- **Médio**: 12px
- **Grande**: 16px
- **Circular**: 50%

## 🎯 Princípios de UX

### Hierarquia Visual
1. **Cores vibrantes** para elementos importantes
2. **Contraste alto** para legibilidade
3. **Espaçamento generoso** para respiração
4. **Tipografia escalonada** para hierarquia clara

### Feedback Visual
- **Animações sutis** nos botões e cards
- **Estados hover/pressed** bem definidos
- **Loading states** com skeleton screens
- **Confirmações visuais** para ações importantes

### Acessibilidade
- **Contraste mínimo** de 4.5:1 para texto
- **Tamanhos de toque** mínimos de 44px
- **Focus indicators** visíveis
- **Textos alternativos** para ícones importantes

## 💡 Boas Práticas

### Uso de Cores
- Use **primary** para ações principais
- Use **secondary** para destaques especiais
- Use **success/error/warning** para feedback de status
- Use cores específicas do esporte para contexto

### Componentes
- Prefira **SportCard** para containers
- Use **StatusBadge** para indicadores de estado
- Implemente **loading states** em todas as operações
- Mantenha **consistência** nos ícones e spacing

### Performance
- Use **const constructors** sempre que possível
- Implemente **lazy loading** para listas grandes
- Otimize **imagens** e **gradientes**
- Evite **rebuilds** desnecessários

## 🚀 Implementação

O tema é aplicado globalmente através do `AppTheme.darkTheme` no `MaterialApp`. Todos os componentes herdam automaticamente as configurações do tema.

Para usar as cores e estilos:
```dart
// Cores
AppTheme.primaryColor
AppTheme.textPrimary

// Extension methods
context.colorScheme.primary
context.textTheme.headlineMedium
```

Este design system garante **consistência visual**, **excelente UX** e **fácil manutenção** em todo o aplicativo.