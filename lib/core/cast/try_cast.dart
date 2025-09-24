/// Tenta fazer cast de um valor para o tipo T, retornando fallback em caso de erro
T tryCast<T>(dynamic value, T fallback) {
  try {
    if (value == null) return fallback;
    return value as T;
  } catch (e) {
    return fallback;
  }
}

/// Versão que aceita um callback para o fallback
T tryCastWithCallback<T>(dynamic value, T Function() fallbackCallback) {
  try {
    if (value == null) return fallbackCallback();
    return value as T;
  } catch (e) {
    return fallbackCallback();
  }
}
