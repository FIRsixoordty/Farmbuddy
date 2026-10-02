-- ============================================================================
-- FARM BUDDY — DATABASE SCHEMA (Phase 2)
-- ============================================================================
-- Run this once against a Supabase project's SQL Editor (or via the
-- Supabase CLI). It is written to be safely re-runnable: tables use
-- `create table if not exists`, policies are dropped and recreated, and the
-- storage bucket insert uses `on conflict`.
--
-- Source of truth for agronomic data: "Data_Website_Edukasi_Farm_Buddy.md".
-- Where that source does not give a specific fact, the corresponding column
-- is left nullable and populated as NULL (never invented) — see
-- supabase/README.md for the full list of what is and isn't covered.
-- ============================================================================

create extension if not exists pgcrypto;

-- ============================================================================
-- 1. PROFILES
-- ============================================================================
-- One row per auth.users row. Created by the app right after sign-up
-- (Phase 3), not by a trigger, so registration can collect username +
-- display_name in the same step per Section 11 of the master prompt.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique check (username ~ '^[a-z0-9_]{3,30}$'),
  display_name text not null check (char_length(display_name) between 1 and 80),
  avatar_url text,
  bio text,
  location text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is
  'Public profile for each authenticated user. username mirrors the Zod rule from Section 25 (lowercase, alphanumeric, underscore).';

-- ============================================================================
-- 2. POSTS + ANSWERS (Community Q&A)
-- ============================================================================

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles (id) on delete cascade,
  title text not null check (char_length(title) >= 5),
  description text not null check (char_length(description) >= 10),
  image_url text,
  category text not null check (
    category in (
      'Padi', 'Jagung', 'Kedelai', 'Cabai', 'Tomat', 'Bawang Merah',
      'Kentang', 'Kakao', 'Karet', 'Kelapa Sawit', 'Tebu',
      'Hama & Penyakit', 'Pupuk', 'Tanah', 'Irigasi', 'Alat & Mesin', 'Umum'
    )
  ),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.posts is
  'Community Q&A posts. category list mirrors Section 13 of the master prompt.';

create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  author_id uuid not null references public.profiles (id) on delete cascade,
  content text not null check (char_length(content) >= 1),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ============================================================================
-- 3. POST LIKES + BOOKMARKS
-- ============================================================================

create table if not exists public.post_likes (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint post_likes_unique_like unique (post_id, user_id)
);

comment on table public.post_likes is
  'unique(post_id, user_id) makes a duplicate like structurally impossible.';

create table if not exists public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  post_id uuid not null references public.posts (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint bookmarks_unique_bookmark unique (user_id, post_id)
);

-- ============================================================================
-- 4. FRIENDSHIPS
-- ============================================================================
-- user_low/user_high normalize the pair regardless of who sent the request,
-- so a unique constraint on them blocks a duplicate friendship in EITHER
-- direction (A->B after B->A already exists), not just an exact repeat.

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles (id) on delete cascade,
  receiver_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'rejected')),
  user_low uuid generated always as (least(requester_id, receiver_id)) stored,
  user_high uuid generated always as (greatest(requester_id, receiver_id)) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint friendships_no_self_friend check (requester_id <> receiver_id),
  constraint friendships_unique_pair unique (user_low, user_high)
);

comment on table public.friendships is
  'unique(user_low, user_high) + the no-self-friend check together make a duplicate or self friendship structurally impossible in either direction.';

-- ============================================================================
-- 5. CROPS + CROP CALENDAR + CROP MODULES
-- ============================================================================

create table if not exists public.crops (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  category text not null check (category in ('pangan', 'hortikultura', 'perkebunan')),
  land_type text,
  season_preference text,
  summary text,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.crops is
  'summary and image_url are intentionally nullable: the source document does not supply a marketing-style summary or any image assets. Left NULL/TODO rather than invented.';

-- One crop can have more than one planting window in a year (e.g. Padi
-- Sawah has MT1 and MT2), so this is a one-crop-to-many-rows table rather
-- than one row per crop.
create table if not exists public.crop_calendar (
  id uuid primary key default gen_random_uuid(),
  crop_id uuid not null references public.crops (id) on delete cascade,
  period_label text,
  plant_start_month smallint check (plant_start_month between 1 and 12),
  plant_end_month smallint check (plant_end_month between 1 and 12),
  planting_note text,
  harvest_start_month smallint check (harvest_start_month between 1 and 12),
  harvest_end_month smallint check (harvest_end_month between 1 and 12),
  harvest_first_after_months_min integer check (harvest_first_after_months_min >= 0),
  harvest_first_after_months_max integer check (harvest_first_after_months_max >= 0),
  harvest_frequency_note text,
  source_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint crop_calendar_first_harvest_range check (
    harvest_first_after_months_min is null
    or harvest_first_after_months_max is null
    or harvest_first_after_months_max >= harvest_first_after_months_min
  )
);

comment on table public.crop_calendar is
  'plant_*/harvest_*_month cover annual crops (Table 1 & 2 of the source). harvest_first_after_months_* + harvest_frequency_note cover perennial estate crops (Table 3), whose harvest is not a fixed annual month window. See supabase/README.md for why both shapes exist in one table.';

create table if not exists public.crop_modules (
  id uuid primary key default gen_random_uuid(),
  crop_id uuid not null references public.crops (id) on delete cascade,
  section text not null check (
    section in (
      'overview', 'kondisi_ideal', 'kebutuhan', 'persiapan_lahan',
      'pembibitan', 'penanaman', 'pemupukan', 'pengairan', 'pemeliharaan',
      'hama_penyakit', 'panen', 'catatan'
    )
  ),
  content text,
  source_available boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint crop_modules_unique_section unique (crop_id, section)
);

comment on table public.crop_modules is
  'content is nullable and source_available defaults to false. A missing row for a (crop, section) pair, or a row with source_available = false, both mean the same thing: the source document has no data for that section — the frontend must show a "belum tersedia" state, never invented agronomic advice.';

-- ============================================================================
-- 6. FARM TOOLS
-- ============================================================================

create table if not exists public.farm_tools (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  category text not null check (
    category in ('pra_panen', 'penanaman', 'perawatan', 'pemanenan', 'pasca_panen')
  ),
  function text,
  mechanism text,
  description text,
  related_module text,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.farm_tools is
  'function/mechanism are split from one combined source paragraph per tool (see supabase/README.md); description holds the fuller combined text for detail-page rendering. No new facts are introduced by the split.';

-- ============================================================================
-- 7. INDEXES
-- ============================================================================
-- Note: columns with a UNIQUE constraint (profiles.username, crops.slug,
-- farm_tools.slug, etc.) already have an implicit unique index from that
-- constraint, so they are not indexed again here.

create index if not exists posts_author_id_idx on public.posts (author_id);
create index if not exists posts_category_idx on public.posts (category);
create index if not exists posts_created_at_idx on public.posts (created_at desc);

create index if not exists answers_post_id_idx on public.answers (post_id);

create index if not exists post_likes_post_id_idx on public.post_likes (post_id);
create index if not exists post_likes_user_id_idx on public.post_likes (user_id);

create index if not exists bookmarks_user_id_idx on public.bookmarks (user_id);

create index if not exists friendships_requester_id_idx on public.friendships (requester_id);
create index if not exists friendships_receiver_id_idx on public.friendships (receiver_id);

create index if not exists crops_category_idx on public.crops (category);

create index if not exists crop_calendar_crop_id_idx on public.crop_calendar (crop_id);
create index if not exists crop_modules_crop_id_idx on public.crop_modules (crop_id);

create index if not exists farm_tools_category_idx on public.farm_tools (category);

-- ============================================================================
-- 8. updated_at TRIGGER
-- ============================================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_updated_at on public.profiles;
create trigger set_updated_at before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.posts;
create trigger set_updated_at before update on public.posts
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.answers;
create trigger set_updated_at before update on public.answers
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.friendships;
create trigger set_updated_at before update on public.friendships
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.crops;
create trigger set_updated_at before update on public.crops
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.crop_calendar;
create trigger set_updated_at before update on public.crop_calendar
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.crop_modules;
create trigger set_updated_at before update on public.crop_modules
  for each row execute function public.set_updated_at();

drop trigger if exists set_updated_at on public.farm_tools;
create trigger set_updated_at before update on public.farm_tools
  for each row execute function public.set_updated_at();

-- ============================================================================
-- 9. ROW LEVEL SECURITY
-- ============================================================================

alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.answers enable row level security;
alter table public.post_likes enable row level security;
alter table public.bookmarks enable row level security;
alter table public.friendships enable row level security;
alter table public.crops enable row level security;
alter table public.crop_calendar enable row level security;
alter table public.crop_modules enable row level security;
alter table public.farm_tools enable row level security;

-- ---- profiles ---------------------------------------------------------
drop policy if exists "Profiles are publicly readable" on public.profiles;
create policy "Profiles are publicly readable"
  on public.profiles for select
  using (true);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---- posts --------------------------------------------------------------
drop policy if exists "Posts are publicly readable" on public.posts;
create policy "Posts are publicly readable"
  on public.posts for select
  using (true);

drop policy if exists "Authenticated users can create posts" on public.posts;
create policy "Authenticated users can create posts"
  on public.posts for insert
  to authenticated
  with check (auth.uid() = author_id);

drop policy if exists "Owners can update their posts" on public.posts;
create policy "Owners can update their posts"
  on public.posts for update
  using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

drop policy if exists "Owners can delete their posts" on public.posts;
create policy "Owners can delete their posts"
  on public.posts for delete
  using (auth.uid() = author_id);

-- ---- answers --------------------------------------------------------------
drop policy if exists "Answers are publicly readable" on public.answers;
create policy "Answers are publicly readable"
  on public.answers for select
  using (true);

drop policy if exists "Authenticated users can answer posts" on public.answers;
create policy "Authenticated users can answer posts"
  on public.answers for insert
  to authenticated
  with check (auth.uid() = author_id);

drop policy if exists "Owners can update their answers" on public.answers;
create policy "Owners can update their answers"
  on public.answers for update
  using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

drop policy if exists "Owners can delete their answers" on public.answers;
create policy "Owners can delete their answers"
  on public.answers for delete
  using (auth.uid() = author_id);

-- ---- post_likes -----------------------------------------------------------
drop policy if exists "Likes are publicly readable" on public.post_likes;
create policy "Likes are publicly readable"
  on public.post_likes for select
  using (true);

drop policy if exists "Authenticated users can like a post" on public.post_likes;
create policy "Authenticated users can like a post"
  on public.post_likes for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can remove their own like" on public.post_likes;
create policy "Users can remove their own like"
  on public.post_likes for delete
  using (auth.uid() = user_id);

-- ---- bookmarks --------------------------------------------------------------
drop policy if exists "Users can view their own bookmarks" on public.bookmarks;
create policy "Users can view their own bookmarks"
  on public.bookmarks for select
  using (auth.uid() = user_id);

drop policy if exists "Users can create their own bookmarks" on public.bookmarks;
create policy "Users can create their own bookmarks"
  on public.bookmarks for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can remove their own bookmarks" on public.bookmarks;
create policy "Users can remove their own bookmarks"
  on public.bookmarks for delete
  using (auth.uid() = user_id);

-- ---- friendships ------------------------------------------------------
drop policy if exists "Users can view friendships involving themselves" on public.friendships;
create policy "Users can view friendships involving themselves"
  on public.friendships for select
  using (auth.uid() = requester_id or auth.uid() = receiver_id);

drop policy if exists "Users can send friend requests" on public.friendships;
create policy "Users can send friend requests"
  on public.friendships for insert
  to authenticated
  with check (auth.uid() = requester_id and receiver_id <> requester_id);

drop policy if exists "Receivers can respond to a friend request" on public.friendships;
create policy "Receivers can respond to a friend request"
  on public.friendships for update
  using (auth.uid() = receiver_id)
  with check (auth.uid() = receiver_id);

drop policy if exists "Either party can remove a friendship" on public.friendships;
create policy "Either party can remove a friendship"
  on public.friendships for delete
  using (auth.uid() = requester_id or auth.uid() = receiver_id);

-- ---- crops / crop_calendar / crop_modules / farm_tools ---------------------
-- Educational reference content: public read-only. No insert/update/delete
-- policy is defined for the `anon`/`authenticated` roles, so only a
-- service-role connection (e.g. this schema/seed file, or a future admin
-- tool) can write to these tables — matching "admin panel is out of scope
-- for the MVP" from Section 6/32 of the master prompt.

drop policy if exists "Crops are publicly readable" on public.crops;
create policy "Crops are publicly readable"
  on public.crops for select
  using (true);

drop policy if exists "Crop calendar is publicly readable" on public.crop_calendar;
create policy "Crop calendar is publicly readable"
  on public.crop_calendar for select
  using (true);

drop policy if exists "Crop modules are publicly readable" on public.crop_modules;
create policy "Crop modules are publicly readable"
  on public.crop_modules for select
  using (true);

drop policy if exists "Farm tools are publicly readable" on public.farm_tools;
create policy "Farm tools are publicly readable"
  on public.farm_tools for select
  using (true);

-- ============================================================================
-- 10. STORAGE BUCKETS
-- ============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('post-images', 'post-images', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Object path convention for both buckets: "{auth.uid()}/<filename>".
-- storage.foldername(name) splits the path and [1] is that first segment,
-- so these policies only let a user write inside their own folder.

drop policy if exists "Avatar images are publicly readable" on storage.objects;
create policy "Avatar images are publicly readable"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "Users can upload their own avatar" on storage.objects;
create policy "Users can upload their own avatar"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name)) [1] = auth.uid()::text
  );

drop policy if exists "Users can update their own avatar" on storage.objects;
create policy "Users can update their own avatar"
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name)) [1] = auth.uid()::text
  );

drop policy if exists "Users can delete their own avatar" on storage.objects;
create policy "Users can delete their own avatar"
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name)) [1] = auth.uid()::text
  );

drop policy if exists "Post images are publicly readable" on storage.objects;
create policy "Post images are publicly readable"
  on storage.objects for select
  using (bucket_id = 'post-images');

drop policy if exists "Users can upload their own post images" on storage.objects;
create policy "Users can upload their own post images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'post-images'
    and (storage.foldername(name)) [1] = auth.uid()::text
  );

drop policy if exists "Users can update their own post images" on storage.objects;
create policy "Users can update their own post images"
  on storage.objects for update
  using (
    bucket_id = 'post-images'
    and (storage.foldername(name)) [1] = auth.uid()::text
  );

drop policy if exists "Users can delete their own post images" on storage.objects;
create policy "Users can delete their own post images"
  on storage.objects for delete
  using (
    bucket_id = 'post-images'
    and (storage.foldername(name)) [1] = auth.uid()::text
  );

-- ============================================================================
-- 11. AUTH TRIGGER — AUTO-CREATE PROFILE ON SIGN-UP (Phase 3)
-- ============================================================================
-- Added in Phase 3. Supersedes the Phase 2 note in supabase/README.md that
-- said profile creation would happen at the app level after sign-up: doing
-- it here instead is more robust, because it works no matter whether the
-- Supabase project requires email confirmation before a session exists (the
-- app can't safely INSERT into public.profiles under RLS without a session,
-- but this trigger runs as SECURITY DEFINER and so is unaffected by RLS).
--
-- The app passes `username` and `display_name` as auth sign-up metadata
-- (`options.data` in supabase-js), which Postgres receives on the new row
-- as `raw_user_meta_data`. If a row is ever inserted without that metadata
-- (e.g. a user created directly from the Supabase dashboard), a random
-- fallback username is generated so sign-up can never be blocked by this
-- trigger.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta_username text;
  meta_display_name text;
begin
  meta_username := new.raw_user_meta_data ->> 'username';
  meta_display_name := new.raw_user_meta_data ->> 'display_name';

  if meta_username is null or meta_username = '' then
    meta_username := 'petani_' || substr(replace(new.id::text, '-', ''), 1, 8);
  end if;

  if meta_display_name is null or meta_display_name = '' then
    meta_display_name := meta_username;
  end if;

  insert into public.profiles (id, username, display_name)
  values (new.id, meta_username, meta_display_name);

  return new;
end;
$$;

comment on function public.handle_new_user is
  'SECURITY DEFINER so it can insert into public.profiles (RLS-protected) from a trigger context that has no authenticated session yet.';

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
