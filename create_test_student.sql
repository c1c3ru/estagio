-- Script para criar um estudante vinculado ao usuário autenticado atual

-- Primeiro, verificar qual é o usuário atual
SELECT auth.uid() as current_user_id;

-- Inserir um estudante usando o ID do usuário autenticado
-- SUBSTITUA 'SEU_USER_ID_AQUI' pelo ID retornado na query acima
INSERT INTO students (
  id,
  full_name,
  registration_number,
  course,
  advisor_name,
  is_mandatory_internship,
  class_shift,
  internship_shift1,
  birth_date,
  contract_start_date,
  contract_end_date,
  total_hours_required,
  total_hours_completed,
  weekly_hours_target,
  status,
  created_at,
  updated_at
) VALUES (
  auth.uid(), -- Usar o ID do usuário autenticado
  'João Silva Santos',
  '2024001234',
  'Tecnologia em Sistemas para Internet',
  'Prof. Dr. Maria Oliveira',
  true,
  'morning',
  'morning',
  '2000-05-15',
  '2024-01-01',
  '2024-12-31',
  400.0,
  0.0,
  20.0,
  'active',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  registration_number = EXCLUDED.registration_number,
  updated_at = NOW();

-- Verificar se foi inserido corretamente
SELECT 
  auth.uid() as current_user_id,
  CASE WHEN s.id IS NOT NULL THEN 'Is Student' ELSE 'Not Student' END as student_status,
  s.full_name
FROM (SELECT auth.uid() as uid) u
LEFT JOIN students s ON s.id = u.uid;

-- Também criar um supervisor de teste se não existir
INSERT INTO supervisors (
  id,
  full_name,
  department,
  position,
  email,
  phone_number,
  status,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  'Prof. Carlos Silva',
  'Tecnologia da Informação',
  'Coordenador de Estágios',
  'carlos.silva@empresa.com',
  '(11) 99999-9999',
  'active',
  NOW(),
  NOW()
) ON CONFLICT DO NOTHING;