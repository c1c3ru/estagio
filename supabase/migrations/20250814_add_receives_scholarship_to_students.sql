-- Adicionar coluna receives_scholarship à tabela students
ALTER TABLE students 
ADD COLUMN receives_scholarship BOOLEAN NOT NULL DEFAULT false;

-- Comentário explicativo
COMMENT ON COLUMN students.receives_scholarship IS 'Indica se o estudante recebe bolsa de estágio';

-- Atualizar a política RLS se necessário (opcional)
-- As políticas existentes já devem cobrir esta nova coluna
