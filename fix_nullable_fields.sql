-- Script para permitir valores nulos nos campos de data da tabela students
-- Execute este script no Supabase SQL Editor

-- Permite valores nulos nos campos de data
ALTER TABLE students ALTER COLUMN birth_date DROP NOT NULL;
ALTER TABLE students ALTER COLUMN contract_start_date DROP NOT NULL;
ALTER TABLE students ALTER COLUMN contract_end_date DROP NOT NULL;

-- Verifica as alterações
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'students' 
AND column_name IN ('birth_date', 'contract_start_date', 'contract_end_date'); 