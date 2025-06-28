-- Adiciona a coluna 'supervisor_id' na tabela 'students'
ALTER TABLE students ADD COLUMN supervisor_id UUID REFERENCES supervisors(id); 