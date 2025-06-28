-- Script para corrigir o erro da coluna supervisor_id
-- Execute este script no Supabase SQL Editor

-- Adiciona a coluna 'supervisor_id' na tabela 'students'
ALTER TABLE students ADD COLUMN IF NOT EXISTS supervisor_id UUID REFERENCES supervisors(id);

-- Verifica se a coluna foi criada corretamente
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'students' AND column_name = 'supervisor_id'; 