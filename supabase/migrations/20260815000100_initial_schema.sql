-- Pushpa Family Chit Fund - Supabase foundation
-- Migration: 20260815000100_initial_schema
--
-- Security model:
-- * RLS is enabled on every exposed application table.
-- * Member access is scoped to the authenticated user's membership.
-- * Privileged state transitions happen through tightly-scoped database functions.
-- * Payment destination details are not directly readable by other members.

create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;

create type public.user_role as enum ('agent', 'member');
create type public.chit_status as enum ('draft', 'active', 'completed', 'cancelled');
create type public.membership_status as enum ('active', 'inactive', 'removed');
create type public.installment_status as enum ('scheduled', 'draw_pending', 'collection_open', 'completed', 'cancelled');
create type public.draw_status as enum ('finalized', 'cancelled');
create type public.payment_status as enum ('pending', 'submitted', 'verified', 'rejected');
create type public.payment_method as enum ('upi', 'bank_transfer', 'cash');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null check (length(trim(full_name)) between 1 and 120),
  phone text,
  role public.user_role not null default 'member',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.chits (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 160),
  monthly_contribution numeric(12,2) not null default 15000 check (monthly_contribution > 0),
  total_members integer not null default 20 check (total_members between 1 and 1000),
  total_months integer not null default 21 check (total_months between 1 and 120),
  allow_repeat_winners boolean not null default false,
  status public.chit_status not null default 'draft',
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.chit_members (
  id uuid primary key default gen_random_uuid(),
  chit_id uuid not null references public.chits(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete restrict,
  member_number integer not null check (member_number > 0),
  status public.membership_status not null default 'active',
  joined_at timestamptz not null default now(),
  unique (chit_id, user_id),
  unique (chit_id, member_number)
);

create table public.payment_destinations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  upi_id text check (upi_id is null or length(trim(upi_id)) between 3 and 120),
  account_holder_name text,
  bank_name text,
  account_number text,
  ifsc_code text,
  updated_at timestamptz not null default now(),
  check (upi_id is not null or (account_number is not null and ifsc_code is not null))
);

create table public.installments (
  id uuid primary key default gen_random_uuid(),
  chit_id uuid not null references public.chits(id) on delete cascade,
  month_number integer not null check (month_number > 0),
  due_date date not null,
  contribution_amount numeric(12,2) not null check (contribution_amount > 0),
  prize_amount numeric(12,2),
  status public.installment_status not null default 'scheduled',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (chit_id, month_number),
  check (month_number <= 120),
  check (prize_amount is null or prize_amount > 0)
);

create table public.draws (
  id uuid primary key default gen_random_uuid(),
  installment_id uuid not null unique references public.installments(id) on delete restrict,
  status public.draw_status not null default 'finalized',
  participant_count integer not null check (participant_count > 0),
  participant_snapshot jsonb not null,
  winner_user_id uuid not null references public.profiles(id) on delete restrict,
  random_algorithm text not null default 'pgcrypto-gen_random_bytes-rejection-sampling-v1',
  created_by uuid not null references public.profiles(id) on delete restrict,
  finalized_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  check (jsonb_typeof(participant_snapshot) = 'array')
);

create table public.draw_participants (
  draw_id uuid not null references public.draws(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete restrict,
  member_number integer not null,
  primary key (draw_id, user_id)
);

create table public.payment_obligations (
  id uuid primary key default gen_random_uuid(),
  installment_id uuid not null references public.installments(id) on delete restrict,
  member_user_id uuid not null references public.profiles(id) on delete restrict,
  recipient_user_id uuid not null references public.profiles(id) on delete restrict,
  amount numeric(12,2) not null check (amount > 0),
  status public.payment_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (installment_id, member_user_id),
  check (member_user_id <> recipient_user_id)
);

create table public.payment_submissions (
  id uuid primary key default gen_random_uuid(),
  obligation_id uuid not null unique references public.payment_obligations(id) on delete restrict,
  submitted_by uuid not null references public.profiles(id) on delete restrict,
  amount numeric(12,2) not null check (amount > 0),
  method public.payment_method not null,
  transaction_reference text,
  proof_path text,
  note text,
  status public.payment_status not null default 'submitted',
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles(id) on delete restrict,
  rejection_reason text,
  check (status <> 'verified' or reviewed_by is not null),
  check (status <> 'rejected' or rejection_reason is not null)
);

create table public.receipts (
  id uuid primary key default gen_random_uuid(),
  obligation_id uuid not null unique references public.payment_obligations(id) on delete restrict,
  receipt_number text not null unique,
  amount numeric(12,2) not null check (amount > 0),
  issued_to uuid not null references public.profiles(id) on delete restrict,
  issued_at timestamptz not null default now(),
  storage_path text
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (length(trim(title)) between 1 and 160),
  body text not null check (length(trim(body)) between 1 and 2000),
  data jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_user_id uuid references public.profiles(id) on delete restrict,
  action text not null check (length(trim(action)) between 1 and 100),
  entity_type text not null check (length(trim(entity_type)) between 1 and 100),
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

-- Indexes for foreign keys and RLS predicates.
create index chit_members_user_idx on public.chit_members(user_id);
create index chit_members_chit_status_idx on public.chit_members(chit_id, status);
create index installments_chit_status_idx on public.installments(chit_id, status);
create index draws_winner_idx on public.draws(winner_user_id);
create index payment_obligations_member_idx on public.payment_obligations(member_user_id, status);
create index payment_obligations_installment_idx on public.payment_obligations(installment_id, status);
create index payment_submissions_submitter_idx on public.payment_submissions(submitted_by, status);
create index notifications_user_created_idx on public.notifications(user_id, created_at desc);

-- Updated-at trigger.
create or replace function private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at before update on public.profiles
for each row execute function private.set_updated_at();
create trigger chits_set_updated_at before update on public.chits
for each row execute function private.set_updated_at();
create trigger payment_destinations_set_updated_at before update on public.payment_destinations
for each row execute function private.set_updated_at();
create trigger installments_set_updated_at before update on public.installments
for each row execute function private.set_updated_at();
create trigger payment_obligations_set_updated_at before update on public.payment_obligations
for each row execute function private.set_updated_at();

-- Security-definer helpers live outside the exposed API schema.
create or replace function private.is_agent()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'agent'::public.user_role
  );
$$;

create or replace function private.is_chit_member(p_chit_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.chit_members cm
    where cm.chit_id = p_chit_id
      and cm.user_id = (select auth.uid())
      and cm.status = 'active'::public.membership_status
  );
$$;

create or replace function private.is_chit_agent(p_chit_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.chits c
    where c.id = p_chit_id
      and c.created_by = (select auth.uid())
      and private.is_agent()
  );
$$;

revoke all on function private.is_agent() from public;
revoke all on function private.is_chit_member(uuid) from public;
revoke all on function private.is_chit_agent(uuid) from public;

-- RLS.
alter table public.profiles enable row level security;
alter table public.chits enable row level security;
alter table public.chit_members enable row level security;
alter table public.payment_destinations enable row level security;
alter table public.installments enable row level security;
alter table public.draws enable row level security;
alter table public.draw_participants enable row level security;
alter table public.payment_obligations enable row level security;
alter table public.payment_submissions enable row level security;
alter table public.receipts enable row level security;
alter table public.notifications enable row level security;
alter table public.audit_logs enable row level security;

-- Profiles: members can read/update their own profile; Agent can manage all profiles.
create policy profiles_select_own_or_agent on public.profiles
for select to authenticated
using ((select auth.uid()) = id or (select private.is_agent()));

create policy profiles_update_own_or_agent on public.profiles
for update to authenticated
using ((select auth.uid()) = id or (select private.is_agent()))
with check ((select auth.uid()) = id or (select private.is_agent()));

-- Chits: Agent manages; members can read chits they belong to.
create policy chits_select_member_or_agent on public.chits
for select to authenticated
using ((select private.is_chit_agent(id)) or (select private.is_chit_member(id)));

create policy chits_insert_agent on public.chits
for insert to authenticated
with check ((select private.is_agent()) and created_by = (select auth.uid()));

create policy chits_update_agent on public.chits
for update to authenticated
using ((select private.is_chit_agent(id)))
with check ((select private.is_chit_agent(id)));

-- Memberships: Agent manages; members read only their own membership.
create policy chit_members_select on public.chit_members
for select to authenticated
using (user_id = (select auth.uid()) or (select private.is_chit_agent(chit_id)));

create policy chit_members_insert_agent on public.chit_members
for insert to authenticated
with check ((select private.is_chit_agent(chit_id)));

create policy chit_members_update_agent on public.chit_members
for update to authenticated
using ((select private.is_chit_agent(chit_id)))
with check ((select private.is_chit_agent(chit_id)));

-- Payment destinations: owner and Agent only. Winner details are exposed through a controlled RPC below.
create policy payment_destinations_select on public.payment_destinations
for select to authenticated
using (user_id = (select auth.uid()) or (select private.is_agent()));

create policy payment_destinations_insert_own_or_agent on public.payment_destinations
for insert to authenticated
with check (user_id = (select auth.uid()) or (select private.is_agent()));

create policy payment_destinations_update_own_or_agent on public.payment_destinations
for update to authenticated
using (user_id = (select auth.uid()) or (select private.is_agent()))
with check (user_id = (select auth.uid()) or (select private.is_agent()));

-- Installments: members can see the schedule; Agent can manage it.
create policy installments_select on public.installments
for select to authenticated
using ((select private.is_chit_member(chit_id)) or (select private.is_chit_agent(chit_id)));

create policy installments_insert_agent on public.installments
for insert to authenticated
with check ((select private.is_chit_agent(chit_id)));

create policy installments_update_agent on public.installments
for update to authenticated
using ((select private.is_chit_agent(chit_id)))
with check ((select private.is_chit_agent(chit_id)));

-- Draws: finalized draw metadata is visible to chit members; writes are blocked for normal clients.
create policy draws_select on public.draws
for select to authenticated
using (
  exists (
    select 1 from public.installments i
    where i.id = installment_id
      and ((select private.is_chit_member(i.chit_id)) or (select private.is_chit_agent(i.chit_id)))
  )
);

create policy draw_participants_select on public.draw_participants
for select to authenticated
using (
  exists (
    select 1
    from public.draws d
    join public.installments i on i.id = d.installment_id
    where d.id = draw_id
      and ((select private.is_chit_member(i.chit_id)) or (select private.is_chit_agent(i.chit_id)))
  )
);

-- Payment obligations: member sees only own obligation; Agent sees all for their chit.
create policy payment_obligations_select on public.payment_obligations
for select to authenticated
using (
  member_user_id = (select auth.uid())
  or exists (
    select 1
    from public.installments i
    where i.id = installment_id and (select private.is_chit_agent(i.chit_id))
  )
);

-- No direct member INSERT/UPDATE/DELETE. Creation and state transitions are server-side functions.
create policy payment_obligations_agent_manage on public.payment_obligations
for all to authenticated
using (
  exists (
    select 1 from public.installments i
    where i.id = installment_id and (select private.is_chit_agent(i.chit_id))
  )
)
with check (
  exists (
    select 1 from public.installments i
    where i.id = installment_id and (select private.is_chit_agent(i.chit_id))
  )
);

-- Payment submissions: member may insert their own pending submission; Agent may review.
create policy payment_submissions_select on public.payment_submissions
for select to authenticated
using (
  submitted_by = (select auth.uid())
  or exists (
    select 1
    from public.payment_obligations po
    join public.installments i on i.id = po.installment_id
    where po.id = obligation_id and (select private.is_chit_agent(i.chit_id))
  )
);

create policy payment_submissions_insert_member on public.payment_submissions
for insert to authenticated
with check (
  submitted_by = (select auth.uid())
  and status = 'submitted'::public.payment_status
  and exists (
    select 1
    from public.payment_obligations po
    join public.installments i on i.id = po.installment_id
    where po.id = obligation_id
      and po.member_user_id = (select auth.uid())
      and po.status in ('pending'::public.payment_status, 'rejected'::public.payment_status)
      and (select private.is_chit_member(i.chit_id))
  )
);

-- No UPDATE/DELETE policies for submissions: state transitions are RPC-only.

create policy receipts_select on public.receipts
for select to authenticated
using (
  issued_to = (select auth.uid())
  or exists (
    select 1
    from public.payment_obligations po
    join public.installments i on i.id = po.installment_id
    where po.id = obligation_id and (select private.is_chit_agent(i.chit_id))
  )
);

create policy notifications_select on public.notifications
for select to authenticated
using (user_id = (select auth.uid()) or (select private.is_agent()));

create policy notifications_update_own on public.notifications
for update to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy audit_logs_select_agent on public.audit_logs
for select to authenticated
using ((select private.is_agent()));

-- Audit logs have no INSERT/UPDATE/DELETE policy for authenticated clients.

-- Secure uniform random integer in [1, p_max] using rejection sampling.
create or replace function private.secure_random_index(p_max integer)
returns integer
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  raw bytea;
  value bigint;
  limit_value bigint;
begin
  if p_max < 1 then
    raise exception 'p_max must be >= 1';
  end if;

  limit_value := (4294967296 / p_max) * p_max;

  loop
    raw := extensions.gen_random_bytes(4);
    value := get_byte(raw, 0)::bigint * 16777216
           + get_byte(raw, 1)::bigint * 65536
           + get_byte(raw, 2)::bigint * 256
           + get_byte(raw, 3)::bigint;
    if value < limit_value then
      return (value % p_max)::integer + 1;
    end if;
  end loop;
end;
$$;

revoke all on function private.secure_random_index(integer) from public;

-- Finalize one Lucky Dip atomically. The caller supplies only the installment ID.
create or replace function public.finalize_lucky_draw(p_installment_id uuid)
returns table (draw_id uuid, winner_user_id uuid, participant_count integer)
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_installment public.installments%rowtype;
  v_draw_id uuid;
  v_winner uuid;
  v_count integer;
  v_index integer;
  v_candidate_ids uuid[];
  v_snapshot jsonb;
  v_chit public.chits%rowtype;
  v_created_by uuid := (select auth.uid());
begin
  if not (select private.is_agent()) then
    raise exception 'Only an Agent can finalize a Lucky Dip';
  end if;

  select * into v_installment
  from public.installments
  where id = p_installment_id
  for update;

  if not found then
    raise exception 'Installment not found';
  end if;

  select * into v_chit from public.chits where id = v_installment.chit_id;

  if v_chit.created_by <> v_created_by then
    raise exception 'Agent does not own this chit';
  end if;

  if exists (select 1 from public.draws d where d.installment_id = p_installment_id) then
    raise exception 'Lucky Dip already finalized for this installment';
  end if;

  -- Build the exact eligibility snapshot before selection.
  select array_agg(cm.user_id order by cm.member_number), count(*)
    into v_candidate_ids, v_count
  from public.chit_members cm
  where cm.chit_id = v_installment.chit_id
    and cm.status = 'active'::public.membership_status
    and (
      v_chit.allow_repeat_winners
      or not exists (
        select 1
        from public.draws prior_d
        join public.installments prior_i on prior_i.id = prior_d.installment_id
        where prior_i.chit_id = v_installment.chit_id
          and prior_d.winner_user_id = cm.user_id
          and prior_d.status = 'finalized'::public.draw_status
      )
    );

  if coalesce(v_count, 0) = 0 then
    raise exception 'No eligible members remain for this Lucky Dip';
  end if;

  v_index := private.secure_random_index(v_count);
  v_winner := v_candidate_ids[v_index];

  select coalesce(jsonb_agg(
    jsonb_build_object('user_id', cm.user_id, 'member_number', cm.member_number)
    order by cm.member_number
  ), '[]'::jsonb)
    into v_snapshot
  from public.chit_members cm
  where cm.user_id = any(v_candidate_ids);

  insert into public.draws (
    installment_id,
    participant_count,
    participant_snapshot,
    winner_user_id,
    created_by
  ) values (
    p_installment_id,
    v_count,
    v_snapshot,
    v_winner,
    v_created_by
  ) returning id into v_draw_id;

  insert into public.draw_participants (draw_id, user_id, member_number)
  select v_draw_id, cm.user_id, cm.member_number
  from public.chit_members cm
  where cm.user_id = any(v_candidate_ids);

  insert into public.payment_obligations (
    installment_id, member_user_id, recipient_user_id, amount
  )
  select p_installment_id, cm.user_id, v_winner, v_installment.contribution_amount
  from public.chit_members cm
  where cm.chit_id = v_installment.chit_id
    and cm.status = 'active'::public.membership_status
    and cm.user_id <> v_winner;

  update public.installments
  set status = 'collection_open', updated_at = now()
  where id = p_installment_id;

  insert into public.audit_logs (actor_user_id, action, entity_type, entity_id, metadata)
  values (
    v_created_by,
    'LUCKY_DIP_FINALIZED',
    'draw',
    v_draw_id,
    jsonb_build_object(
      'installment_id', p_installment_id,
      'winner_user_id', v_winner,
      'participant_count', v_count,
      'algorithm', 'pgcrypto-gen_random_bytes-rejection-sampling-v1'
    )
  );

  return query select v_draw_id, v_winner, v_count;
end;
$$;

revoke all on function public.finalize_lucky_draw(uuid) from public, anon, authenticated;
grant execute on function public.finalize_lucky_draw(uuid) to authenticated;

-- Return only the current winner's payment destination to a member who owes the installment.
create or replace function public.get_payment_destination(p_installment_id uuid)
returns table (
  winner_user_id uuid,
  winner_name text,
  upi_id text,
  account_holder_name text,
  bank_name text,
  account_number text,
  ifsc_code text
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_chit_id uuid;
  v_winner_id uuid;
  v_is_member boolean;
begin
  select i.chit_id into v_chit_id
  from public.installments i
  where i.id = p_installment_id;

  if v_chit_id is null then
    raise exception 'Installment not found';
  end if;

  v_is_member := private.is_chit_member(v_chit_id);
  if not v_is_member and not (select private.is_chit_agent(v_chit_id)) then
    raise exception 'Not authorized for this chit';
  end if;

  if not (select private.is_chit_agent(v_chit_id)) and not exists (
    select 1 from public.payment_obligations po
    where po.installment_id = p_installment_id
      and po.member_user_id = (select auth.uid())
  ) then
    raise exception 'No payment obligation exists for this member';
  end if;

  select d.winner_user_id into v_winner_id
  from public.draws d
  where d.installment_id = p_installment_id
    and d.status = 'finalized'::public.draw_status;

  if v_winner_id is null then
    raise exception 'Lucky Dip has not been finalized';
  end if;

  return query
  select
    p.id,
    p.full_name,
    pd.upi_id,
    pd.account_holder_name,
    pd.bank_name,
    pd.account_number,
    pd.ifsc_code
  from public.profiles p
  left join public.payment_destinations pd on pd.user_id = p.id
  where p.id = v_winner_id;
end;
$$;

revoke all on function public.get_payment_destination(uuid) from public, anon;
grant execute on function public.get_payment_destination(uuid) to authenticated;

-- Agent-only payment verification transition. It is intentionally RPC-only.
create or replace function public.verify_payment(p_submission_id uuid, p_approve boolean, p_rejection_reason text default null)
returns public.receipts
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_submission public.payment_submissions%rowtype;
  v_obligation public.payment_obligations%rowtype;
  v_installment public.installments%rowtype;
  v_receipt public.receipts%rowtype;
  v_agent uuid := (select auth.uid());
  v_receipt_number text;
begin
  if not (select private.is_agent()) then
    raise exception 'Only an Agent can verify payments';
  end if;

  select ps.* into v_submission
  from public.payment_submissions ps
  where ps.id = p_submission_id
  for update;

  if not found then
    raise exception 'Payment submission not found';
  end if;

  if v_submission.status <> 'submitted'::public.payment_status then
    raise exception 'Only submitted payments can be reviewed';
  end if;

  select po.* into v_obligation
  from public.payment_obligations po
  where po.id = v_submission.obligation_id
  for update;

  select i.* into v_installment
  from public.installments i
  where i.id = v_obligation.installment_id;

  if not (select private.is_chit_agent(v_installment.chit_id)) then
    raise exception 'Agent does not own this chit';
  end if;

  if p_approve then
    if v_submission.amount <> v_obligation.amount then
      raise exception 'Submitted amount does not match the obligation';
    end if;

    update public.payment_submissions
    set status = 'verified', reviewed_at = now(), reviewed_by = v_agent, rejection_reason = null
    where id = p_submission_id;

    update public.payment_obligations
    set status = 'verified', updated_at = now()
    where id = v_obligation.id;

    v_receipt_number := 'REC-PF-' || to_char(current_date, 'YYYYMMDD') || '-' || lpad(v_obligation.id::text, 8, '0');

    insert into public.receipts (obligation_id, receipt_number, amount, issued_to)
    values (v_obligation.id, v_receipt_number, v_obligation.amount, v_obligation.member_user_id)
    returning * into v_receipt;

    insert into public.audit_logs (actor_user_id, action, entity_type, entity_id, metadata)
    values (
      v_agent,
      'PAYMENT_VERIFIED',
      'payment_submission',
      p_submission_id,
      jsonb_build_object('obligation_id', v_obligation.id, 'receipt_id', v_receipt.id)
    );

    return v_receipt;
  else
    if nullif(trim(coalesce(p_rejection_reason, '')), '') is null then
      raise exception 'A rejection reason is required';
    end if;

    update public.payment_submissions
    set status = 'rejected', reviewed_at = now(), reviewed_by = v_agent, rejection_reason = trim(p_rejection_reason)
    where id = p_submission_id;

    update public.payment_obligations
    set status = 'rejected', updated_at = now()
    where id = v_obligation.id;

    insert into public.audit_logs (actor_user_id, action, entity_type, entity_id, metadata)
    values (
      v_agent,
      'PAYMENT_REJECTED',
      'payment_submission',
      p_submission_id,
      jsonb_build_object('obligation_id', v_obligation.id, 'reason', trim(p_rejection_reason))
    );

    return null;
  end if;
end;
$$;

revoke all on function public.verify_payment(uuid, boolean, text) from public, anon, authenticated;
grant execute on function public.verify_payment(uuid, boolean, text) to authenticated;

-- Explicit grants: Data API access is opt-in and still constrained by RLS.
grant select on public.profiles, public.chits, public.chit_members, public.payment_destinations,
  public.installments, public.draws, public.draw_participants, public.payment_obligations,
  public.payment_submissions, public.receipts, public.notifications, public.audit_logs
  to authenticated;

grant insert, update on public.profiles to authenticated;
grant insert, update on public.chits to authenticated;
grant insert, update on public.chit_members to authenticated;
grant insert, update on public.payment_destinations to authenticated;
grant insert, update on public.installments to authenticated;
grant insert on public.payment_submissions to authenticated;
grant update on public.notifications to authenticated;

-- No direct grants for draw writes, obligation writes, receipt writes, or audit writes.
-- They are controlled by the RPC functions above.
