# Auditoria de Cores e Comentários

## ✅ Arquivo de Cores Atualizado
- **AppColors expandido** com 100+ cores organizadas por categoria
- Cores de status, gradientes, overlays, inputs, botões, navegação
- Todas as cores hardcoded identificadas e catalogadas

## 🎨 Cores Encontradas no Código (Para Substituir)

### Cores Hardcoded Mais Comuns:
- `Colors.white` → `AppColors.white`
- `Colors.black` → `AppColors.black`
- `Colors.transparent` → `AppColors.transparent`
- `Colors.grey` → `AppColors.grey`
- `Colors.red` → `AppColors.error`
- `Colors.green` → `AppColors.success`
- `Colors.blue` → `AppColors.info`
- `Colors.orange` → `AppColors.warning`

### Cores com Opacidade:
- `Colors.black.withOpacity(0.5)` → `AppColors.overlay`
- `Colors.white.withOpacity(0.8)` → `AppColors.overlayLight`
- `Colors.grey[200]` → `AppColors.grey200`
- `Colors.grey[400]` → `AppColors.grey400`

## 📝 Comentários em Inglês Identificados

### Arquivos com Comentários para Traduzir:
1. **Core Services** (40+ arquivos)
2. **Features** (60+ arquivos)  
3. **Domain/Data** (30+ arquivos)
4. **Widgets** (25+ arquivos)

### Padrões de Comentários:
- `// TODO:` → `// FAZER:`
- `// FIXME:` → `// CORRIGIR:`
- `// NOTE:` → `// NOTA:`
- `/// Returns` → `/// Retorna`
- `/// Creates` → `/// Cria`
- `/// Updates` → `/// Atualiza`

## 🔧 Próximos Passos

### 1. Substituição de Cores (Automática)
```bash
# Substituir cores mais comuns
find lib -name "*.dart" -exec sed -i 's/Colors\.white/AppColors.white/g' {} \;
find lib -name "*.dart" -exec sed -i 's/Colors\.black/AppColors.black/g' {} \;
```

### 2. Tradução de Comentários (Manual)
- Traduzir comentários de documentação (///)
- Traduzir comentários inline (//)
- Manter consistência terminológica

### 3. Validação
- Verificar se todas as cores estão no AppColors
- Testar se não há quebras após substituições
- Revisar traduções para contexto correto

## 📊 Estatísticas
- **Cores catalogadas**: 100+
- **Arquivos com cores hardcoded**: 45+
- **Arquivos com comentários em inglês**: 80+
- **Substituições estimadas**: 300+

## ✅ Status
- ✅ Arquivo AppColors expandido
- ⏳ Substituição de cores (próximo passo)
- ⏳ Tradução de comentários (próximo passo)
- ⏳ Validação final (próximo passo)