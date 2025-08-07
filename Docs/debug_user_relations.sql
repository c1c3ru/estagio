-- Script para verificar relações entre usuários autenticados e estudantes/supervisores

-- Verificar usuários autenticados
SELECT id, email, created_at FROM auth.users ORDER BY created_at DESC LIMIT 5;

-- Verificar estudantes e suas relações com usuários
SELECT s.id, s.full_name, s.created_at, 
       CASE WHEN u.id IS NOT NULL THEN 'Linked' ELSE 'Not Linked' END as auth_status
FROM students s
LEFT JOIN auth.users u ON s.id = u.id
ORDER BY s.created_at DESC LIMIT 5;

-- Verificar supervisores e suas relações com usuários
SELECT s.id, s.full_name, s.created_at,
       CASE WHEN u.id IS NOT NULL THEN 'Linked' ELSE 'Not Linked' END as auth_status
FROM supervisors s
LEFT JOIN auth.users u ON s.id = u.id
ORDER BY s.created_at DESC LIMIT 5;

-- Verificar se o usuário atual tem registro como estudante
-- (Execute este comando logado no app para ver o resultado)
SELECT 
  auth.uid() as current_user_id,
  CASE WHEN s.id IS NOT NULL THEN 'Is Student' ELSE 'Not Student' END as student_status,
  CASE WHEN sup.id IS NOT NULL THEN 'Is Supervisor' ELSE 'Not Supervisor' END as supervisor_status
FROM (SELECT auth.uid() as uid) u
LEFT JOIN students s ON s.id = u.uid
LEFT JOIN supervisors sup ON sup.id = u.uid;