-- Script para inserir dados de teste no banco de dados
-- Execute este script no Supabase SQL Editor

-- ========================================
-- ESTRUTURA DAS TABELAS (para referência)
-- ========================================

/*
TABELA: users
- id (uuid, PK)
- email (varchar)
- role (varchar: student, supervisor, admin)
- is_active (boolean)
- matricula (varchar)
- created_at, updated_at

TABELA: students
- id (uuid, PK, FK para users.id)
- full_name (varchar)
- registration_number (varchar, unique)
- course (varchar)
- advisor_name (varchar)
- is_mandatory_internship (boolean)
- class_shift (varchar: morning, afternoon, evening, full_time, ead)
- internship_shift_1 (varchar: morning, afternoon, evening)
- internship_shift_2 (varchar: morning, afternoon, evening)
- birth_date (date)
- contract_start_date (date)
- contract_end_date (date)
- total_hours_required (numeric)
- total_hours_completed (numeric)
- weekly_hours_target (numeric)
- profile_picture_url (text)
- phone_number (varchar)
- created_at, updated_at
- status (TEXT)
- supervisor_id (uuid, FK para supervisors.id)

TABELA: supervisors
- id (uuid, PK, FK para users.id)
- full_name (varchar)
- department (varchar)
- position (varchar)
- job_code (varchar)
- profile_picture_url (text)
- phone_number (varchar)
- created_at, updated_at

TABELA: contracts
- id (uuid, PK)
- student_id (uuid, FK para students.id)
- supervisor_id (uuid, FK para supervisors.id)
- contract_type (varchar, default 'internship')
- status (varchar: active, pending_approval, expired, terminated, completed)
- start_date (date)
- end_date (date)
- description (text)
- document_url (text)
- created_by (uuid, FK para auth.users)
- created_at, updated_at

TABELA: time_logs
- id (uuid, PK)
- student_id (uuid, FK para students.id)
- log_date (date)
- check_in_time (time)
- check_out_time (time)
- hours_logged (numeric)
- description (text)
- approved (boolean)
- supervisor_id (uuid, FK para supervisors.id)
- approved_at (timestamp)
- created_at, updated_at
*/

-- ========================================
-- DADOS DE TESTE
-- ========================================

-- Primeiro, vamos verificar se o usuário já existe e inserir se necessário
INSERT INTO public.users (id, email, role, is_active, created_at, updated_at, matricula)
VALUES (
  '4ac134e0-494e-41d6-9972-1d7fc1af0cb1', -- ID do usuário autenticado
  'cicerosilva.ifce@gmail.com',
  'student',
  true,
  NOW(),
  NOW(),
  '202300123456'
)
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  role = EXCLUDED.role,
  is_active = EXCLUDED.is_active,
  updated_at = NOW(),
  matricula = EXCLUDED.matricula;

-- Inserir dados do estudante (se não existir)
INSERT INTO public.students (
  id,
  full_name,
  registration_number,
  course,
  advisor_name,
  is_mandatory_internship,
  class_shift,
  internship_shift_1,
  internship_shift_2,
  birth_date,
  contract_start_date,
  contract_end_date,
  total_hours_required,
  total_hours_completed,
  weekly_hours_target,
  created_at,
  updated_at,
  status,
  supervisor_id
)
VALUES (
  '4ac134e0-494e-41d6-9972-1d7fc1af0cb1', -- Mesmo ID do usuário
  'Cicero Silva',
  '202300123456',
  'Tecnologia em Sistemas para Internet',
  'Dr. Maria Santos',
  true,
  'morning',
  'morning',
  'afternoon',
  '2000-01-01',
  '2024-02-01',
  '2024-12-31',
  300.0,
  120.0,
  20.0,
  NOW(),
  NOW(),
  'active',
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  registration_number = EXCLUDED.registration_number,
  course = EXCLUDED.course,
  advisor_name = EXCLUDED.advisor_name,
  is_mandatory_internship = EXCLUDED.is_mandatory_internship,
  class_shift = EXCLUDED.class_shift,
  internship_shift_1 = EXCLUDED.internship_shift_1,
  internship_shift_2 = EXCLUDED.internship_shift_2,
  birth_date = EXCLUDED.birth_date,
  contract_start_date = EXCLUDED.contract_start_date,
  contract_end_date = EXCLUDED.contract_end_date,
  total_hours_required = EXCLUDED.total_hours_required,
  total_hours_completed = EXCLUDED.total_hours_completed,
  weekly_hours_target = EXCLUDED.weekly_hours_target,
  updated_at = NOW(),
  status = EXCLUDED.status;

-- Inserir logs de tempo de exemplo (apenas se não existirem)
INSERT INTO public.time_logs (
  id,
  student_id,
  log_date,
  check_in_time,
  check_out_time,
  hours_logged,
  description,
  approved,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  '4ac134e0-494e-41d6-9972-1d7fc1af0cb1',
  CURRENT_DATE - INTERVAL '3 days',
  '08:00:00',
  '12:00:00',
  4.0,
  'Reunião com supervisor',
  true,
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.time_logs 
  WHERE student_id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1' 
  AND log_date = CURRENT_DATE - INTERVAL '3 days'
);

-- Inserir um log ativo (sem check_out_time) para teste (apenas se não existir)
INSERT INTO public.time_logs (
  id,
  student_id,
  log_date,
  check_in_time,
  hours_logged,
  description,
  approved,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  '4ac134e0-494e-41d6-9972-1d7fc1af0cb1',
  CURRENT_DATE,
  '08:00:00',
  0.0,
  'Trabalhando no projeto',
  false,
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.time_logs 
  WHERE student_id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1' 
  AND log_date = CURRENT_DATE 
  AND check_out_time IS NULL
);

-- Inserir um contrato ativo (apenas se não existir)
INSERT INTO public.contracts (
  id,
  student_id,
  contract_type,
  status,
  start_date,
  end_date,
  description,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  '4ac134e0-494e-41d6-9972-1d7fc1af0cb1',
  'internship',
  'active',
  '2024-02-01',
  '2024-12-31',
  'Estágio obrigatório em desenvolvimento web',
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.contracts 
  WHERE student_id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1' 
  AND status = 'active'
);

-- Verificar se os dados foram inseridos corretamente
SELECT 
  'Usuário' as tipo,
  id,
  email,
  role,
  matricula
FROM public.users 
WHERE id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1'

UNION ALL

SELECT 
  'Estudante' as tipo,
  id,
  full_name as email,
  class_shift as role,
  registration_number as matricula
FROM public.students 
WHERE id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1'

UNION ALL

SELECT 
  'Contrato' as tipo,
  id,
  contract_type as email,
  status as role,
  description as matricula
FROM public.contracts 
WHERE student_id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1'

UNION ALL

SELECT 
  'Time Log' as tipo,
  id,
  log_date::text as email,
  approved::text as role,
  description as matricula
FROM public.time_logs 
WHERE student_id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1';

-- ========================================
-- INSTRUÇÕES PARA TESTAR NOVOS USUÁRIOS
-- ========================================

/*
Para testar se novos usuários aparecem na lista de colegas online:

1. Execute este script SQL no Supabase para criar os dados de teste
2. No aplicativo Flutter:
   - Vá para a tela de registro
   - Crie uma nova conta de estudante
   - Faça login com a nova conta
   - Verifique se aparece na lista de colegas online

3. Para testar com usuários existentes:
   - Faça login com qualquer conta de estudante
   - O sistema deve automaticamente criar os dados na tabela students
   - Verifique se aparece na lista de colegas online

4. Para verificar os dados no Supabase:
   - Vá para o painel do Supabase
   - Acesse a tabela 'students'
   - Verifique se os novos usuários foram criados automaticamente

5. Se um usuário não aparecer na lista:
   - Verifique se ele tem status 'active' na tabela students
   - Verifique se o user_id está correto
   - Verifique os logs do aplicativo para erros
*/

-- Inserir um usuário supervisor de teste (apenas se não existir)
INSERT INTO public.users (
  id,
  email,
  role,
  full_name,
  matricula,
  created_at,
  updated_at
)
SELECT 
  '5bd245f1-5a5f-42e7-9a8b-2e8fc2bf1dc2', -- ID único para o supervisor
  'supervisor@ifce.edu.br',
  'supervisor',
  'Dr. João Silva',
  'SIAPE123456',
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.users 
  WHERE id = '5bd245f1-5a5f-42e7-9a8b-2e8fc2bf1dc2'
);

-- Inserir dados do supervisor (apenas se não existir)
INSERT INTO public.supervisors (
  id,
  full_name,
  department,
  position,
  job_code,
  created_at,
  updated_at
)
SELECT 
  '5bd245f1-5a5f-42e7-9a8b-2e8fc2bf1dc2', -- Mesmo ID do usuário
  'Dr. João Silva',
  'Tecnologia da Informação',
  'Professor Coordenador',
  'SIAPE123456',
  NOW(),
  NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM public.supervisors 
  WHERE id = '5bd245f1-5a5f-42e7-9a8b-2e8fc2bf1dc2'
);

-- Atualizar o estudante para ter o supervisor
UPDATE public.students 
SET supervisor_id = '5bd245f1-5a5f-42e7-9a8b-2e8fc2bf1dc2'
WHERE id = '4ac134e0-494e-41d6-9972-1d7fc1af0cb1';

-- Inserir um usuário estudante de teste (apenas se não existir) 