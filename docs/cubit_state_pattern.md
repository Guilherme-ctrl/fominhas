# Padrão CubitState - Guia de Implementação

## Visão Geral

Este documento descreve o padrão CubitState padronizado implementado no projeto Fominhas. O objetivo é unificar o gerenciamento de estado em todos os Cubits, eliminando a necessidade de estados customizados e aproveitando um sistema robusto e consistente.

## Por que padronizar?

### Problemas dos Estados Customizados
- **Duplicação de código**: Cada Cubit criava seus próprios estados (Loading, Success, Error)
- **Inconsistência**: Diferentes implementações de estados similares
- **Manutenção difícil**: Mudanças precisavam ser replicadas em múltiplos arquivos
- **Falta de funcionalidades**: Recursos como pattern matching não eram reutilizados

### Vantagens do CubitState Padronizado
- **Consistência**: Todos os Cubits usam o mesmo padrão de estados
- **Reutilização**: Funcionalidades como pattern matching são compartilhadas
- **Manutenibilidade**: Uma única implementação para manter
- **Logging estruturado**: Integração automática com sistema de logs
- **Type safety**: Melhor tipagem com generics

## Estrutura do CubitState

### Estados Disponíveis

```dart
// Estado vazio - inicial
CubitState.empty()

// Estado de carregamento
CubitState.loading()

// Estado de sucesso com dados
CubitState.success(value: dados)

// Estado de erro com mensagem
CubitState.error(message: "Mensagem de erro")
```

### Tipos de Estado

1. **EmptyCubitState**: Estado inicial, sem dados
2. **LoadingCubitState**: Operação em andamento
3. **SuccessCubitState<T>**: Sucesso com dados tipados
4. **ErrorCubitState**: Erro com mensagem

## Implementação nos Cubits

### Template Base

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/state/cubit_state.dart';
import '../../../../core/extensions/cubit_state_extensions.dart';
import '../../../../core/services/logging_service.dart';

class ExampleCubit extends Cubit<CubitState> with CubitLoggingMixin {
  final IExampleRepository _repository;

  ExampleCubit(this._repository) : super(CubitState.empty());

  Future<void> loadData() async {
    logOperation('loadData');
    emit(CubitState.loading());
    
    try {
      final data = await _repository.getData();
      emit(CubitStateHelper.successList(data));
      
      LoggingService.logStructuredData(
        'data_loaded',
        {'count': data.length},
      );
    } catch (e) {
      logError('loadData', e);
      emit(CubitState.error(message: e.toString()));
      LoggingService.error('Erro ao carregar dados', exception: e);
    }
  }
}
```

### Mixin de Logging

O `CubitLoggingMixin` fornece métodos padronizados para logging:

```dart
mixin CubitLoggingMixin<T extends CubitState> {
  String get cubitName => runtimeType.toString();
  
  void logOperation(String operation, {Map<String, dynamic>? data});
  void logError(String operation, Object error, {StackTrace? stackTrace});
  void logStateChange(T previousState, T newState, {Map<String, dynamic>? context});
}
```

## Extensões e Helpers

### CubitStateExtensions

Fornece métodos convenientes para trabalhar com estados:

```dart
// Verificações de estado
state.isEmpty     // true se EmptyCubitState
state.isLoading   // true se LoadingCubitState
state.isSuccess   // true se SuccessCubitState
state.isError     // true se ErrorCubitState

// Acesso seguro aos dados
final value = state.getSuccessValue<MyType>();
final error = state.getErrorMessage();

// Pattern matching
final result = state.when(
  empty: () => 'Sem dados',
  loading: () => 'Carregando...',
  success: (data) => 'Dados: $data',
  error: (message) => 'Erro: $message',
);

// Pattern matching com fallback
final result = state.maybeWhen(
  success: (data) => 'Sucesso: $data',
  orElse: () => 'Estado padrão',
);
```

### CubitStateHelper

Métodos utilitários para operações comuns:

```dart
// Criar estado de lista vazia
CubitStateHelper.emptyList<Player>()

// Criar estado de sucesso com lista
CubitStateHelper.successList([player1, player2])

// Adicionar item à lista existente
CubitStateHelper.updateListWithNewItem(currentState, newPlayer)

// Remover item da lista
CubitStateHelper.removeItemFromList(
  currentState,
  (player) => player.id == playerId,
)

// Atualizar item na lista
CubitStateHelper.updateItemInList(
  currentState,
  (player) => player.id == playerId,
  (player) => updatedPlayer,
)

// Obter lista de forma segura
final players = CubitStateHelper.getList<Player>(state);
```

## Uso nos Widgets

### BlocBuilder Padrão

```dart
BlocBuilder<PlayersCubit, CubitState>(
  builder: (context, state) {
    return state.when(
      empty: () => const Text('Nenhum jogador'),
      loading: () => const CircularProgressIndicator(),
      success: (data) {
        final players = CubitStateHelper.getList<Player>(state);
        return ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, index) => PlayerCard(players[index]),
        );
      },
      error: (message) => Text('Erro: $message'),
    );
  },
)
```

### BlocListener para Ações

```dart
BlocListener<PlayersCubit, CubitState>(
  listener: (context, state) {
    state.whenError((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  },
  child: MyWidget(),
)
```

### Verificações Condicionais

```dart
BlocBuilder<TournamentCubit, CubitState>(
  builder: (context, state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }
    
    final tournament = state.getSuccessValue<Tournament>();
    if (tournament == null) {
      return const EmptyStateWidget();
    }
    
    return TournamentDetails(tournament);
  },
)
```

## Padrões de Implementação

### 1. Operações CRUD Básicas

```dart
// CREATE
Future<void> createItem(Item item) async {
  logOperation('createItem');
  try {
    final createdItem = await _repository.createItem(item);
    
    if (state.isSuccess) {
      final updatedState = CubitStateHelper.updateListWithNewItem(state, createdItem);
      emit(updatedState);
    } else {
      await loadItems(); // Fallback para recarregar
    }
    
    LoggingService.logStructuredData('item_created', {'id': createdItem.id});
  } catch (e) {
    logError('createItem', e);
    emit(CubitState.error(message: e.toString()));
  }
}

// READ
Future<void> loadItems() async {
  logOperation('loadItems');
  emit(CubitState.loading());
  
  try {
    final items = await _repository.getAll();
    emit(CubitStateHelper.successList(items));
    
    LoggingService.logStructuredData('items_loaded', {'count': items.length});
  } catch (e) {
    logError('loadItems', e);
    emit(CubitState.error(message: e.toString()));
  }
}

// UPDATE
Future<void> updateItem(Item item) async {
  logOperation('updateItem');
  try {
    final updatedItem = await _repository.updateItem(item);
    
    if (state.isSuccess) {
      final updatedState = CubitStateHelper.updateItemInList(
        state,
        (i) => i.id == item.id,
        (i) => updatedItem,
      );
      emit(updatedState);
    }
    
    LoggingService.logStructuredData('item_updated', {'id': item.id});
  } catch (e) {
    logError('updateItem', e);
    emit(CubitState.error(message: e.toString()));
  }
}

// DELETE
Future<void> deleteItem(String id) async {
  logOperation('deleteItem');
  try {
    await _repository.deleteItem(id);
    
    if (state.isSuccess) {
      final updatedState = CubitStateHelper.removeItemFromList(
        state,
        (item) => item.id == id,
      );
      emit(updatedState);
    }
    
    LoggingService.logStructuredData('item_deleted', {'id': id});
  } catch (e) {
    logError('deleteItem', e);
    emit(CubitState.error(message: e.toString()));
  }
}
```

### 2. Operações com Item Único

```dart
Future<void> loadItem(String id) async {
  logOperation('loadItem');
  emit(CubitState.loading());
  
  try {
    final item = await _repository.getItem(id);
    if (item != null) {
      emit(CubitState.success(value: item));
      LoggingService.logStructuredData('item_loaded', {'id': id});
    } else {
      emit(CubitState.error(message: 'Item não encontrado'));
    }
  } catch (e) {
    logError('loadItem', e);
    emit(CubitState.error(message: e.toString()));
  }
}
```

### 3. Operações de Busca

```dart
Future<void> searchItems(String query) async {
  logOperation('searchItems');
  
  if (query.isEmpty) {
    await loadItems(); // Voltar para lista completa
    return;
  }
  
  emit(CubitState.loading());
  
  try {
    final items = await _repository.searchItems(query);
    emit(CubitStateHelper.successList(items));
    
    LoggingService.logStructuredData('items_searched', {
      'query': query,
      'results': items.length,
    });
  } catch (e) {
    logError('searchItems', e);
    emit(CubitState.error(message: e.toString()));
  }
}
```

## Integração com Logging

### Logging Automático

Todos os Cubits que usam `CubitLoggingMixin` automaticamente registram:
- Início de operações
- Erros com stack trace
- Mudanças de estado
- Contexto adicional

### Dados Estruturados

O sistema usa o formato exigido pelo Elastic Search:

```dart
LoggingService.logStructuredData(
  'event_name',
  {'json': actualData}, // Formato requerido
);
```

### Logging de Eventos Específicos

```dart
// Para torneios
LoggingService.logTournamentEvent(
  tournamentId,
  'tournament_created',
  {'teams_count': 4},
);

// Para partidas
LoggingService.logMatchEvent(
  matchId,
  'match_started',
  {'home_team': 'Team A', 'away_team': 'Team B'},
);
```

## Testes

### Testando com CubitState

```dart
group('MyCubit Tests', () {
  test('should emit loading then success', () async {
    // Arrange
    when(() => mockRepository.getData())
        .thenAnswer((_) async => mockData);

    // Act & Assert
    expect(
      cubit.stream,
      emitsInOrder([
        predicate<CubitState>((state) => state.isLoading),
        predicate<CubitState>((state) => state.isSuccess),
      ]),
    );

    await cubit.loadData();
  });

  test('should emit error on failure', () async {
    // Arrange
    when(() => mockRepository.getData())
        .thenThrow(Exception('Test error'));

    // Act & Assert
    expect(
      cubit.stream,
      emitsInOrder([
        predicate<CubitState>((state) => state.isLoading),
        predicate<CubitState>((state) => 
            state.isError && 
            state.getErrorMessage()!.contains('Test error')),
      ]),
    );

    await cubit.loadData();
  });
});
```

## Migração de Estados Customizados

### Antes (Estados Customizados)
```dart
class MyState {}
class MyInitial extends MyState {}
class MyLoading extends MyState {}
class MyLoaded extends MyState {
  final List<Item> items;
  MyLoaded(this.items);
}
class MyError extends MyState {
  final String message;
  MyError(this.message);
}
```

### Depois (CubitState)
```dart
// Estados removidos, usar CubitState diretamente
// Acesso aos dados:
final items = CubitStateHelper.getList<Item>(state);
final errorMessage = state.getErrorMessage();
```

### Migração de Widgets
```dart
// Antes
BlocBuilder<MyCubit, MyState>(
  builder: (context, state) {
    if (state is MyLoading) return LoadingWidget();
    if (state is MyError) return ErrorWidget(state.message);
    if (state is MyLoaded) return ItemList(state.items);
    return EmptyWidget();
  },
)

// Depois
BlocBuilder<MyCubit, CubitState>(
  builder: (context, state) {
    return state.when(
      loading: () => LoadingWidget(),
      error: (message) => ErrorWidget(message),
      success: (data) {
        final items = CubitStateHelper.getList<Item>(state);
        return ItemList(items);
      },
      empty: () => EmptyWidget(),
    );
  },
)
```

## Boas Práticas

### ✅ Do
- Use `CubitStateHelper` para operações com listas
- Implemente `CubitLoggingMixin` em todos os Cubits
- Use pattern matching para renderização condicional
- Log operações importantes com contexto
- Teste todos os estados possíveis

### ❌ Don't
- Não crie estados customizados
- Não acesse dados sem verificação de tipo
- Não ignore erros sem logging
- Não misture diferentes padrões de estado
- Não esqueça de fazer fallback para operações que podem falhar

## Troubleshooting

### Problema: Estado não atualiza
**Solução**: Verifique se está emitindo novos estados, não mutando o atual

### Problema: Type errors ao acessar dados
**Solução**: Use `getSuccessValue<T>()` com o tipo correto

### Problema: Logs não aparecem
**Solução**: Verifique se o `LoggingService` foi inicializado no `main.dart`

### Problema: Testes falhando
**Solução**: Use `predicate<CubitState>()` ao invés de matcher direto de tipo

## Conclusão

O padrão CubitState padronizado oferece:
- **Consistência** em toda a aplicação
- **Funcionalidades robustas** como pattern matching
- **Logging estruturado** integrado
- **Facilidade de teste** e manutenção
- **Type safety** com generics

Siga este guia para manter a consistência e aproveitar ao máximo o sistema de estados padronizado.