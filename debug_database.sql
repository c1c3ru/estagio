-- Script para verificar se os dados estão sendo inseridos corretamente

-- Verificar estrutura das tabelas
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'contracts' 
ORDER BY ordinal_position;

SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'time_logs' 
ORDER BY ordinal_position;

-- Verificar dados existentes
SELECT COUNT(*) as total_contracts FROM contracts;
SELECT COUNT(*) as total_time_logs FROM time_logs;

-- Verificar últimos registros inseridos
SELECT * FROM contracts ORDER BY created_at DESC LIMIT 5;
SELECT * FROM time_logs ORDER BY created_at DESC LIMIT 5;

-- Verificar se existem estudantes e supervisores
SELECT COUNT(*) as total_students FROM students;
SELECT COUNT(*) as total_supervisors FROM supervisors;

-- Verificar últimos estudantes e supervisores
SELECT id, full_name FROM students ORDER BY created_at DESC LIMIT 3;
SELECT id, full_name FROM supervisors ORDER BY created_at DESC LIMIT 3;