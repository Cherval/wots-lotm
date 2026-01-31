-- =============================================================================
-- WHISPER OF THE SHADOW - FULL DATABASE INITIALIZATION
-- =============================================================================
-- This script sets up the entire database schema, triggers, and policies.
-- Run this in the Supabase SQL Editor to initialize a fresh project.
-- =============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. TABLE DEFINITIONS
-- =============================================================================

create table public.brewing_sessions (
  id uuid not null default gen_random_uuid (),
  player_id uuid null,
  recipe_id uuid null,
  status character varying(50) null default 'in_progress'::character varying,
  started_at timestamp with time zone null default now(),
  completed_at timestamp with time zone null,
  player_steps jsonb null default '[]'::jsonb,
  accuracy_score numeric(5, 2) null,
  result_message text null,
  constraint brewing_sessions_pkey primary key (id)
) TABLESPACE pg_default;

create table public.enemies (
  id uuid not null default uuid_generate_v4 (),
  character_name text null,
  nationality text null,
  sex text null,
  pathways text null,
  sequence text null,
  str integer null default 10,
  str_mod integer null default 0,
  agi integer null default 10,
  agi_mod integer null default 0,
  int_stat integer null default 10,
  int_mod integer null default 0,
  dex integer null default 10,
  dex_mod integer null default 0,
  con integer null default 10,
  con_mod integer null default 0,
  wis integer null default 10,
  wis_mod integer null default 0,
  cha integer null default 10,
  cha_mod integer null default 0,
  hp integer null default 10,
  character_img_url text null,
  status text null default 'active'::text,
  atk integer null default 0,
  ac integer null default 10,
  dc integer null default 10,
  constraint enemies_pkey primary key (id)
) TABLESPACE pg_default;

create table public.enemy_skills (
  enemy_id uuid not null,
  athletics integer null default 0,
  acrobatics integer null default 0,
  sleight_of_hand integer null default 0,
  stealth integer null default 0,
  arcana integer null default 0,
  history integer null default 0,
  investigation integer null default 0,
  nature integer null default 0,
  religion integer null default 0,
  animal_handling integer null default 0,
  insight integer null default 0,
  medicine integer null default 0,
  perception integer null default 0,
  survival integer null default 0,
  deception integer null default 0,
  intimidation integer null default 0,
  performance integer null default 0,
  persuasion integer null default 0,
  constraint enemy_skills_pkey primary key (enemy_id)
) TABLESPACE pg_default;

create table public.inventory (
  id uuid not null default uuid_generate_v4 (),
  player_id uuid not null,
  item_id uuid not null,
  quantity integer null default 1,
  is_equipped boolean null default false,
  updated_at timestamp with time zone null default timezone ('utc'::text, now()),
  grid_x integer null default 0,
  grid_y integer null default 0,
  constraint inventory_pkey primary key (id),
  constraint inventory_quantity_check check ((quantity >= 0))
) TABLESPACE pg_default;

create table public.items (
  id uuid not null default uuid_generate_v4 (),
  name text not null,
  description text null,
  type text not null,
  price_buy integer null default 0,
  price_sell integer null default 0,
  image_url text null default 'https://via.placeholder.com/100?text=Item'::text,
  effects jsonb null default '{}'::jsonb,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  slot_type text null,
  grid_width integer null default 1,
  grid_height integer null default 1,
  shop_category character varying(50) null default 'market'::character varying,
  recipe_id uuid null,
  constraint items_pkey primary key (id),
  constraint items_type_check check (
    (
      type = any (
        array[
          'consumable'::text,
          'equipment'::text,
          'material'::text,
          'special'::text,
          'recipe'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create table public.map_positions (
  id uuid not null default uuid_generate_v4 (),
  map_id uuid not null,
  player_id uuid null,
  enemy_id uuid null,
  pos_x numeric not null,
  pos_y numeric not null,
  updated_at timestamp with time zone null default timezone ('utc'::text, now()),
  pos_x_percent double precision null default '50'::double precision,
  pos_y_percent double precision null default '50'::double precision,
  constraint map_positions_pkey primary key (id),
  constraint unique_player_location unique (player_id),
  constraint check_entity check (
    (
      (
        (player_id is not null)
        and (enemy_id is null)
      )
      or (
        (player_id is null)
        and (enemy_id is not null)
      )
    )
  )
) TABLESPACE pg_default;

create table public.maps (
  id uuid not null default uuid_generate_v4 (),
  name text not null,
  description text null,
  image_url text not null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  is_locked boolean null default false,
  constraint maps_pkey primary key (id)
) TABLESPACE pg_default;

create table public.pathways (
  id uuid not null default uuid_generate_v4 (),
  name text not null,
  goo_group text null,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  constraint pathways_pkey primary key (id),
  constraint pathways_name_key unique (name)
) TABLESPACE pg_default;

create table public.player_skills (
  player_id uuid not null,
  athletics integer null default 0,
  acrobatics integer null default 0,
  sleight_of_hand integer null default 0,
  stealth integer null default 0,
  arcana integer null default 0,
  history integer null default 0,
  investigation integer null default 0,
  nature integer null default 0,
  religion integer null default 0,
  animal_handling integer null default 0,
  insight integer null default 0,
  medicine integer null default 0,
  perception integer null default 0,
  survival integer null default 0,
  deception integer null default 0,
  intimidation integer null default 0,
  performance integer null default 0,
  persuasion integer null default 0,
  constraint player_skills_pkey primary key (player_id)
) TABLESPACE pg_default;

create table public.players (
  id uuid not null default uuid_generate_v4 (),
  auth_id uuid null,
  name text null,
  character_name text null,
  nationality text null,
  sex text null,
  pathways text null,
  sequence text null,
  str integer null default 10,
  str_mod integer null default 0,
  agi integer null default 10,
  agi_mod integer null default 0,
  int_stat integer null default 10,
  int_mod integer null default 0,
  dex integer null default 10,
  dex_mod integer null default 0,
  con integer null default 10,
  con_mod integer null default 0,
  wis integer null default 10,
  wis_mod integer null default 0,
  cha integer null default 10,
  cha_mod integer null default 0,
  hp integer null default 10,
  character_img_url text null,
  source_url text null,
  role text null default 'player'::text,
  status text null default 'active'::text,
  created_at timestamp with time zone null default timezone ('utc'::text, now()),
  skill_points integer null default 0,
  money integer null default 0,
  bank_balance integer null default 0,
  atk integer null default 0,
  ac integer null default 10,
  move_token integer null default 0,
  constraint players_pkey primary key (id),
  constraint players_auth_id_fkey foreign KEY (auth_id) references auth.users (id)
) TABLESPACE pg_default;

create table public.recipe_steps (
  id uuid not null default gen_random_uuid (),
  recipe_id uuid null,
  step_order integer not null,
  step_type character varying(50) not null,
  fire_level integer null,
  item_id uuid null,
  amount numeric(10, 2) null,
  unit character varying(20) null,
  duration_seconds integer null,
  description text null,
  created_at timestamp with time zone null default now(),
  constraint recipe_steps_pkey primary key (id),
  constraint recipe_steps_item_id_fkey foreign KEY (item_id) references items (id),
  constraint recipe_steps_fire_level_check check (
    (
      (fire_level >= 0)
      and (fire_level <= 3)
    )
  )
) TABLESPACE pg_default;

create table public.recipes (
  id uuid not null default gen_random_uuid (),
  name character varying(255) not null,
  description text null,
  image_url text null,
  result_item_id uuid null,
  result_quantity integer null default 1,
  difficulty character varying(50) null default 'normal'::character varying,
  tolerance_percent numeric(5, 2) null default 10.00,
  created_at timestamp with time zone null default now(),
  updated_at timestamp with time zone null default now(),
  created_by uuid null,
  constraint recipes_pkey primary key (id),
  constraint recipes_created_by_fkey foreign KEY (created_by) references auth.users (id),
  constraint recipes_result_item_id_fkey foreign KEY (result_item_id) references items (id)
) TABLESPACE pg_default;

create table public.sequences (
  id uuid not null default uuid_generate_v4 (),
  pathway_id uuid not null,
  seq_number integer not null,
  title text not null,
  rank_group text null,
  constraint sequences_pkey primary key (id),
  constraint sequences_pathway_id_fkey foreign KEY (pathway_id) references pathways (id) on delete CASCADE
) TABLESPACE pg_default;

create table public.transaction_logs (
  id uuid not null default gen_random_uuid (),
  created_at timestamp with time zone not null default now(),
  action_type text not null,
  actor_id uuid not null,
  target_id uuid null,
  item_id uuid null,
  amount numeric null,
  details jsonb null default '{}'::jsonb,
  actor_name text null,
  target_name text null,
  item_name text null,
  constraint transaction_logs_pkey primary key (id),
  constraint transaction_logs_actor_id_fkey foreign KEY (actor_id) references players (id) on delete CASCADE,
  constraint transaction_logs_item_id_fkey foreign KEY (item_id) references items (id) on delete set null,
  constraint transaction_logs_target_id_fkey foreign KEY (target_id) references players (id) on delete set null
) TABLESPACE pg_default;

-- =============================================================================
-- 2. FOREIGN KEY CONSTRAINTS (Circular dependencies usually require these separate)
-- =============================================================================

ALTER TABLE public.brewing_sessions ADD CONSTRAINT brewing_sessions_player_id_fkey foreign KEY (player_id) references players (id) on delete CASCADE;
ALTER TABLE public.brewing_sessions ADD CONSTRAINT brewing_sessions_recipe_id_fkey foreign KEY (recipe_id) references recipes (id);

ALTER TABLE public.enemy_skills ADD CONSTRAINT enemy_skills_enemy_id_fkey foreign KEY (enemy_id) references enemies (id);

ALTER TABLE public.inventory ADD CONSTRAINT inventory_item_id_fkey foreign KEY (item_id) references items (id) on delete CASCADE;
ALTER TABLE public.inventory ADD CONSTRAINT inventory_player_id_fkey foreign KEY (player_id) references players (id) on delete CASCADE;

ALTER TABLE public.items ADD CONSTRAINT items_recipe_id_fkey foreign KEY (recipe_id) references recipes (id);

ALTER TABLE public.map_positions ADD CONSTRAINT map_positions_enemy_id_fkey foreign KEY (enemy_id) references enemies (id) on delete CASCADE;
ALTER TABLE public.map_positions ADD CONSTRAINT map_positions_map_id_fkey foreign KEY (map_id) references maps (id) on delete CASCADE;
ALTER TABLE public.map_positions ADD CONSTRAINT map_positions_player_id_fkey foreign KEY (player_id) references players (id) on delete CASCADE;

ALTER TABLE public.player_skills ADD CONSTRAINT player_skills_player_id_fkey foreign KEY (player_id) references players (id);

ALTER TABLE public.recipe_steps ADD CONSTRAINT recipe_steps_recipe_id_fkey foreign KEY (recipe_id) references recipes (id) on delete CASCADE;

-- =============================================================================
-- 3. INDEXES
-- =============================================================================

create index IF not exists idx_brewing_sessions_player on public.brewing_sessions using btree (player_id) TABLESPACE pg_default;
create index IF not exists idx_brewing_sessions_status on public.brewing_sessions using btree (status) TABLESPACE pg_default;
create index IF not exists idx_items_shop_category on public.items using btree (shop_category) TABLESPACE pg_default;
create index IF not exists idx_items_recipe_id on public.items using btree (recipe_id) TABLESPACE pg_default;
create index IF not exists idx_recipe_steps_recipe_id on public.recipe_steps using btree (recipe_id) TABLESPACE pg_default;
create index IF not exists idx_recipe_steps_order on public.recipe_steps using btree (recipe_id, step_order) TABLESPACE pg_default;
create index IF not exists idx_logs_actor on public.transaction_logs using btree (actor_id) TABLESPACE pg_default;
create index IF not exists idx_logs_target on public.transaction_logs using btree (target_id) TABLESPACE pg_default;
create index IF not exists idx_logs_action on public.transaction_logs using btree (action_type) TABLESPACE pg_default;
create index IF not exists idx_logs_created on public.transaction_logs using btree (created_at desc) TABLESPACE pg_default;

-- =============================================================================
-- 4. TRIGGERS & FUNCTIONS
-- =============================================================================

-- Auto Create Player on Auth Sign Up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    new_player_id UUID;
    user_display_name TEXT;
BEGIN
    user_display_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        NEW.raw_user_meta_data->>'username',
        split_part(NEW.email, '@', 1)
    );

    INSERT INTO public.players (
        auth_id,
        name,
        role,
        status,
        move_token
    ) VALUES (
        NEW.id,
        user_display_name,
        'player',
        'active',
        0
    )
    RETURNING id INTO new_player_id;

    INSERT INTO public.player_skills (player_id)
    VALUES (new_player_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- 5. POLICIES (RLS)
-- =============================================================================

ALTER TABLE public.players ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can update their own profile" 
ON public.players 
FOR UPDATE 
TO authenticated 
USING (auth_id = auth.uid())
WITH CHECK (auth_id = auth.uid());

CREATE POLICY "Everyone can view profiles"
ON public.players
FOR SELECT
TO authenticated, anon
USING (true);

-- =============================================================================
-- END OF INITIALIZATION
-- =============================================================================
