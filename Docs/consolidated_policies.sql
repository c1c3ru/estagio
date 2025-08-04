-- =========================
-- TABELA contracts
-- =========================

DROP POLICY IF EXISTS "Acesso contratos estudante/supervisor" ON public.contracts;
CREATE POLICY "Acesso contratos estudante/supervisor"
ON public.contracts
FOR SELECT
USING (
  (student_id = (select auth.uid()))
  OR
  (EXISTS (SELECT 1 FROM public.supervisors s WHERE s.id = (select auth.uid())))
);

-- =========================
-- TABELA students
-- =========================

DROP POLICY IF EXISTS "Insert students (autenticado ou supervisor)" ON public.students;
CREATE POLICY "Insert students (autenticado ou supervisor)"
ON public.students
FOR INSERT
WITH CHECK (
  ((select auth.role()) = 'authenticated' AND (select auth.uid()) = id)
  OR
  (EXISTS (SELECT 1 FROM public.supervisors s WHERE s.id = (select auth.uid())))
);

DROP POLICY IF EXISTS "Visualizar estudantes (próprio ou supervisor)" ON public.students;
CREATE POLICY "Visualizar estudantes (próprio ou supervisor)"
ON public.students
FOR SELECT
USING (
  (id = (select auth.uid()))
  OR
  (EXISTS (SELECT 1 FROM public.supervisors s WHERE s.id = (select auth.uid())))
);

DROP POLICY IF EXISTS "Atualizar estudantes (próprio ou supervisor)" ON public.students;
CREATE POLICY "Atualizar estudantes (próprio ou supervisor)"
ON public.students
FOR UPDATE
USING (
  (id = (select auth.uid()))
  OR
  (EXISTS (SELECT 1 FROM public.supervisors s WHERE s.id = (select auth.uid())))
);

-- =========================
-- TABELA supervisors
-- =========================

DROP POLICY IF EXISTS "Insert supervisors autenticado" ON public.supervisors;
CREATE POLICY "Insert supervisors autenticado"
ON public.supervisors
FOR INSERT
WITH CHECK ((select auth.role()) = 'authenticated');

DROP POLICY IF EXISTS "Visualizar supervisor (próprio ou todos)" ON public.supervisors;
CREATE POLICY "Visualizar supervisor (próprio ou todos)"
ON public.supervisors
FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Atualizar supervisor próprio" ON public.supervisors;
CREATE POLICY "Atualizar supervisor próprio"
ON public.supervisors
FOR UPDATE
USING ((id = (select auth.uid())));

DROP POLICY IF EXISTS "Deletar supervisor próprio" ON public.supervisors;
CREATE POLICY "Deletar supervisor próprio"
ON public.supervisors
FOR DELETE
USING ((id = (select auth.uid())));

-- =========================
-- TABELA time_logs
-- =========================

DROP POLICY IF EXISTS "Gerenciar time_logs (próprio estudante ou supervisor)" ON public.time_logs;
CREATE POLICY "Gerenciar time_logs (próprio estudante ou supervisor)"
ON public.time_logs
FOR ALL
USING (
  (student_id = (select auth.uid()))
  OR
  (EXISTS (SELECT 1 FROM public.supervisors s WHERE s.id = (select auth.uid())))
);

-- =========================
-- TABELA users
-- =========================

DROP POLICY IF EXISTS "Atualizar usuário próprio" ON public.users;
CREATE POLICY "Atualizar usuário próprio"
ON public.users
FOR UPDATE
USING ((id = (select auth.uid())));

DROP POLICY IF EXISTS "Visualizar usuário próprio" ON public.users;
CREATE POLICY "Visualizar usuário próprio"
ON public.users
FOR SELECT
USING ((id = (select auth.uid()))); 