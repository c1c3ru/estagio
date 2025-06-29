# Solução para o Erro da Coluna supervisor_id

## Problema
O aplicativo estava apresentando o seguinte erro:
```
PostgrestException(message: Could not find the 'supervisor_id' column of 'students' in the schema cache, code: PGRST204, details: Bad Request, hint: null)
```

E depois:
```
PostgrestException(message: null value in column "birth_date" of relation "students" violates not-null constraint, code: 23502, details: Bad Request, hint: null)
```

## Causa
O código estava tentando criar automaticamente um registro de estudante quando o usuário fazia login, mas:
1. A coluna `supervisor_id` não existia no banco de dados
2. Campos obrigatórios como `birth_date` estavam sendo enviados como `null`

## Solução

### 1. Correção do Fluxo de Login

**Problema identificado**: O método `_ensureUserDataExists` estava criando automaticamente registros de estudante/supervisor quando o usuário fazia login, mesmo que os dados não existissem.

**Solução**: Modificado o método para apenas **verificar** se os dados existem, sem criar automaticamente.

### 2. Alterações no Banco de Dados

Execute no Supabase SQL Editor:

```sql
-- Adiciona a coluna 'supervisor_id' na tabela 'students'
ALTER TABLE students ADD COLUMN IF NOT EXISTS supervisor_id UUID REFERENCES supervisors(id);

-- Permite valores nulos nos campos de data
ALTER TABLE students ALTER COLUMN birth_date DROP NOT NULL;
ALTER TABLE students ALTER COLUMN contract_start_date DROP NOT NULL;
ALTER TABLE students ALTER COLUMN contract_end_date DROP NOT NULL;
```

### 3. Alterações Realizadas no Código

1. **AuthDatasource** (`lib/data/datasources/supabase/auth_datasource.dart`):
   - Modificado `_ensureUserDataExists` para apenas verificar dados, não criar automaticamente
   - Removida criação automática de registros de estudante/supervisor

2. **StudentModel** (`lib/data/models/student_model.dart`):
   - Adicionado campo `supervisorId`
   - Atualizado `fromJson()` e `toJson()`
   - Atualizado `toEntity()`

3. **StudentEntity** (`lib/domain/entities/student_entity.dart`):
   - Adicionado campo `supervisorId`
   - Atualizado `props`, `copyWith()` e `toString()`

### 4. Fluxo Correto

Agora o fluxo funciona assim:

1. **Login**: Usuário faz login com email/senha
2. **Verificação**: Sistema verifica se existem dados completos na tabela correspondente
3. **Redirecionamento**: 
   - Se dados existem → vai para dashboard
   - Se dados não existem → vai para tela de completar cadastro
4. **Cadastro**: Usuário completa os dados necessários
5. **Criação**: Registro é criado apenas quando o usuário submete o formulário completo

### 5. Arquivos Criados/Modificados

- ✅ `fix_supervisor_id_migration.sql` - Script para adicionar coluna
- ✅ `fix_nullable_fields.sql` - Script para permitir valores nulos
- ✅ `supabase/migrations/20250624154510_add_supervisor_id_to_students.sql` - Migração
- ✅ `lib/data/datasources/supabase/auth_datasource.dart` - Fluxo de login corrigido
- ✅ `lib/data/models/student_model.dart` - Modelo atualizado
- ✅ `lib/domain/entities/student_entity.dart` - Entidade atualizada

## Próximos Passos

1. Execute os scripts SQL no Supabase
2. Reinicie o aplicativo Flutter
3. Teste o login novamente

O erro deve ser resolvido e o fluxo de login deve funcionar corretamente, direcionando o usuário para completar o cadastro quando necessário. 