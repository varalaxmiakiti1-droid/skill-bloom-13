CREATE TYPE public.skill_direction AS ENUM ('teaching', 'learning');
CREATE TYPE public.exchange_status AS ENUM ('pending', 'accepted', 'rejected', 'completed');
CREATE TYPE public.progress_stage AS ENUM ('not_started', 'in_progress', 'completed');
CREATE TYPE public.notification_type AS ENUM ('new_request', 'request_accepted', 'request_rejected', 'exchange_completed');

CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,
  full_name text NOT NULL DEFAULT '',
  college text NOT NULL DEFAULT '',
  department text NOT NULL DEFAULT '',
  study_year smallint CHECK (study_year BETWEEN 1 AND 8),
  bio text NOT NULL DEFAULT '' CHECK (char_length(bio) <= 500),
  avatar_path text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated students can view profiles" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "Students can create own profile" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "Students can update own profile" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE TABLE public.skills (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (char_length(name) BETWEEN 1 AND 80),
  category text NOT NULL CHECK (category IN ('Programming','Web Development','AI & ML','Data Science','Design','Communication','Languages','Academics','Other')),
  normalized_name text GENERATED ALWAYS AS (lower(trim(name))) STORED,
  created_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (normalized_name, category)
);
GRANT SELECT, INSERT ON public.skills TO authenticated;
GRANT ALL ON public.skills TO service_role;
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated students can view skills" ON public.skills FOR SELECT TO authenticated USING (true);
CREATE POLICY "Students can create skills" ON public.skills FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

CREATE TABLE public.profile_skills (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  skill_id uuid NOT NULL REFERENCES public.skills(id) ON DELETE CASCADE,
  direction public.skill_direction NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (profile_id, skill_id, direction)
);
GRANT SELECT, INSERT, DELETE ON public.profile_skills TO authenticated;
GRANT ALL ON public.profile_skills TO service_role;
ALTER TABLE public.profile_skills ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated students can view profile skills" ON public.profile_skills FOR SELECT TO authenticated USING (true);
CREATE POLICY "Students can add own skills" ON public.profile_skills FOR INSERT TO authenticated WITH CHECK (auth.uid() = profile_id);
CREATE POLICY "Students can remove own skills" ON public.profile_skills FOR DELETE TO authenticated USING (auth.uid() = profile_id);

CREATE TABLE public.exchange_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  recipient_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  requested_skill_id uuid NOT NULL REFERENCES public.skills(id) ON DELETE RESTRICT,
  offered_skill_id uuid REFERENCES public.skills(id) ON DELETE SET NULL,
  message text NOT NULL DEFAULT '' CHECK (char_length(message) <= 500),
  status public.exchange_status NOT NULL DEFAULT 'pending',
  progress smallint NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
  progress_stage public.progress_stage NOT NULL DEFAULT 'not_started',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (requester_id <> recipient_id)
);
GRANT SELECT, INSERT, UPDATE ON public.exchange_requests TO authenticated;
GRANT ALL ON public.exchange_requests TO service_role;
ALTER TABLE public.exchange_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Participants can view requests" ON public.exchange_requests FOR SELECT TO authenticated USING (auth.uid() = requester_id OR auth.uid() = recipient_id);
CREATE POLICY "Students can send requests" ON public.exchange_requests FOR INSERT TO authenticated WITH CHECK (auth.uid() = requester_id AND status = 'pending' AND progress = 0 AND progress_stage = 'not_started');
CREATE POLICY "Participants can update requests" ON public.exchange_requests FOR UPDATE TO authenticated USING (auth.uid() = requester_id OR auth.uid() = recipient_id) WITH CHECK (auth.uid() = requester_id OR auth.uid() = recipient_id);
CREATE UNIQUE INDEX exchange_active_unique ON public.exchange_requests (LEAST(requester_id, recipient_id), GREATEST(requester_id, recipient_id), requested_skill_id) WHERE status IN ('pending', 'accepted');
CREATE INDEX exchange_requester_idx ON public.exchange_requests(requester_id, created_at DESC);
CREATE INDEX exchange_recipient_idx ON public.exchange_requests(recipient_id, created_at DESC);

CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  actor_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  exchange_id uuid REFERENCES public.exchange_requests(id) ON DELETE CASCADE,
  type public.notification_type NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, UPDATE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Students can view own notifications" ON public.notifications FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Students can mark own notifications read" ON public.notifications FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE INDEX notifications_user_idx ON public.notifications(user_id, created_at DESC);

CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data ->> 'full_name', ''))
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_profile();

CREATE OR REPLACE FUNCTION public.enforce_exchange_transition()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  NEW.updated_at := now();
  IF NEW.requester_id <> OLD.requester_id OR NEW.recipient_id <> OLD.recipient_id OR NEW.requested_skill_id <> OLD.requested_skill_id OR NEW.offered_skill_id IS DISTINCT FROM OLD.offered_skill_id THEN
    RAISE EXCEPTION 'Exchange participants and skills cannot be changed';
  END IF;
  IF OLD.status = 'pending' THEN
    IF NEW.status NOT IN ('pending','accepted','rejected') THEN RAISE EXCEPTION 'Invalid request status transition'; END IF;
    IF NEW.status IN ('accepted','rejected') AND auth.uid() <> OLD.recipient_id THEN RAISE EXCEPTION 'Only the recipient can respond'; END IF;
  ELSIF OLD.status = 'accepted' THEN
    IF NEW.status NOT IN ('accepted','completed') THEN RAISE EXCEPTION 'Invalid accepted exchange transition'; END IF;
    IF auth.uid() NOT IN (OLD.requester_id, OLD.recipient_id) THEN RAISE EXCEPTION 'Only participants can update progress'; END IF;
  ELSE
    IF NEW IS DISTINCT FROM OLD THEN RAISE EXCEPTION 'Finalized requests cannot be changed'; END IF;
  END IF;
  IF NEW.status = 'pending' AND (NEW.progress <> 0 OR NEW.progress_stage <> 'not_started') THEN RAISE EXCEPTION 'Pending requests cannot have progress'; END IF;
  IF NEW.status = 'rejected' AND (NEW.progress <> 0 OR NEW.progress_stage <> 'not_started') THEN RAISE EXCEPTION 'Rejected requests cannot have progress'; END IF;
  IF NEW.progress = 100 THEN NEW.progress_stage := 'completed'; NEW.status := 'completed';
  ELSIF NEW.progress > 0 THEN NEW.progress_stage := 'in_progress';
  ELSIF NEW.status = 'accepted' THEN NEW.progress_stage := 'not_started';
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER enforce_exchange_transition_before_update BEFORE UPDATE ON public.exchange_requests FOR EACH ROW EXECUTE FUNCTION public.enforce_exchange_transition();

CREATE OR REPLACE FUNCTION public.create_exchange_notification()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE actor_name text;
BEGIN
  SELECT COALESCE(NULLIF(full_name,''), 'A student') INTO actor_name FROM public.profiles WHERE id = auth.uid();
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.notifications (user_id, actor_id, exchange_id, type, title, body)
    VALUES (NEW.recipient_id, NEW.requester_id, NEW.id, 'new_request', 'New skill exchange request', actor_name || ' sent you a skill exchange request.');
  ELSIF OLD.status IS DISTINCT FROM NEW.status THEN
    IF NEW.status = 'accepted' THEN
      INSERT INTO public.notifications (user_id, actor_id, exchange_id, type, title, body)
      VALUES (NEW.requester_id, NEW.recipient_id, NEW.id, 'request_accepted', 'Request accepted', actor_name || ' accepted your skill exchange request.');
    ELSIF NEW.status = 'rejected' THEN
      INSERT INTO public.notifications (user_id, actor_id, exchange_id, type, title, body)
      VALUES (NEW.requester_id, NEW.recipient_id, NEW.id, 'request_rejected', 'Request rejected', actor_name || ' could not accept your request.');
    ELSIF NEW.status = 'completed' THEN
      INSERT INTO public.notifications (user_id, actor_id, exchange_id, type, title, body)
      SELECT participant, auth.uid(), NEW.id, 'exchange_completed', 'Exchange completed', 'Your skill exchange is complete.'
      FROM (VALUES (NEW.requester_id), (NEW.recipient_id)) AS participants(participant)
      WHERE participant <> auth.uid();
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
CREATE TRIGGER create_exchange_notification_after_insert AFTER INSERT ON public.exchange_requests FOR EACH ROW EXECUTE FUNCTION public.create_exchange_notification();
CREATE TRIGGER create_exchange_notification_after_update AFTER UPDATE ON public.exchange_requests FOR EACH ROW EXECUTE FUNCTION public.create_exchange_notification();

CREATE OR REPLACE FUNCTION public.touch_profile_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at := now(); RETURN NEW; END; $$;
CREATE TRIGGER touch_profile_before_update BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.touch_profile_updated_at();

CREATE POLICY "Students can upload own avatars" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'profile-avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "Students can view avatars" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'profile-avatars');
CREATE POLICY "Students can update own avatars" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id = 'profile-avatars' AND (storage.foldername(name))[1] = auth.uid()::text) WITH CHECK (bucket_id = 'profile-avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "Students can delete own avatars" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'profile-avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.exchange_requests;