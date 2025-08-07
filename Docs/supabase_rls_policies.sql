-- Políticas RLS para permitir operações nas tabelas

-- Habilitar RLS nas tabelas (se não estiver habilitado)
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_logs ENABLE ROW LEVEL SECURITY;

-- Políticas para tabela CONTRACTS
-- Permitir que usuários autenticados vejam contratos onde são estudantes ou supervisores
CREATE POLICY "Users can view their own contracts" ON contracts
FOR SELECT USING (
  auth.uid() IN (
    SELECT id FROM students WHERE id = contracts.student_id
    UNION
    SELECT id FROM supervisors WHERE id = contracts.supervisor_id
  )
);

-- Permitir que estudantes criem contratos para si mesmos
CREATE POLICY "Students can create their own contracts" ON contracts
FOR INSERT WITH CHECK (
  auth.uid() IN (SELECT id FROM students WHERE id = contracts.student_id)
);

-- Permitir que usuários atualizem contratos onde são estudantes ou supervisores
CREATE POLICY "Users can update their own contracts" ON contracts
FOR UPDATE USING (
  auth.uid() IN (
    SELECT id FROM students WHERE id = contracts.student_id
    UNION
    SELECT id FROM supervisors WHERE id = contracts.supervisor_id
  )
);

-- Permitir que usuários deletem contratos onde são estudantes ou supervisores
CREATE POLICY "Users can delete their own contracts" ON contracts
FOR DELETE USING (
  auth.uid() IN (
    SELECT id FROM students WHERE id = contracts.student_id
    UNION
    SELECT id FROM supervisors WHERE id = contracts.supervisor_id
  )
);

-- Políticas para tabela TIME_LOGS
-- Permitir que usuários vejam time logs onde são estudantes ou supervisores
CREATE POLICY "Users can view their own time logs" ON time_logs
FOR SELECT USING (
  auth.uid() IN (
    SELECT id FROM students WHERE id = time_logs.student_id
    UNION
    SELECT id FROM supervisors WHERE id = time_logs.supervisor_id
  )
);

-- Permitir que estudantes criem time logs para si mesmos
CREATE POLICY "Students can create their own time logs" ON time_logs
FOR INSERT WITH CHECK (
  auth.uid() IN (SELECT id FROM students WHERE id = time_logs.student_id)
);

-- Permitir que usuários atualizem time logs onde são estudantes ou supervisores
CREATE POLICY "Users can update their own time logs" ON time_logs
FOR UPDATE USING (
  auth.uid() IN (
    SELECT id FROM students WHERE id = time_logs.student_id
    UNION
    SELECT id FROM supervisors WHERE id = time_logs.supervisor_id
  )
);

-- Permitir que usuários deletem time logs onde são estudantes
CREATE POLICY "Students can delete their own time logs" ON time_logs
FOR DELETE USING (
  auth.uid() IN (SELECT id FROM students WHERE id = time_logs.student_id)
);

-- Política alternativa mais permissiva para desenvolvimento (REMOVER EM PRODUÇÃO)
-- Descomente apenas se as políticas acima não funcionarem

-- DROP POLICY IF EXISTS "Allow all for authenticated users" ON contracts;
-- CREATE POLICY "Allow all for authenticated users" ON contracts
-- FOR ALL USING (auth.role() = 'authenticated');

-- DROP POLICY IF EXISTS "Allow all for authenticated users" ON time_logs;
-- CREATE POLICY "Allow all for authenticated users" ON time_logs
-- FOR ALL USING (auth.role() = 'authenticated');