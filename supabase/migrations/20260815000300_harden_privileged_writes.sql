-- Harden direct Data API writes after the initial foundation migration.

-- Members must not be able to escalate their profile role through a normal update.
create or replace function private.prevent_role_escalation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if old.role is distinct from new.role and not (select private.is_agent()) then
    raise exception 'Only an Agent can change user roles';
  end if;
  return new;
end;
$$;

revoke all on function private.prevent_role_escalation() from public;

drop trigger if exists profiles_prevent_role_escalation on public.profiles;
create trigger profiles_prevent_role_escalation
before update on public.profiles
for each row execute function private.prevent_role_escalation();

-- Draws, obligations, receipts and audit records are created/transitioned by
-- privileged database functions. Agents still have SELECT access through RLS.
drop policy if exists payment_obligations_agent_manage on public.payment_obligations;

-- Members do not need raw draw participant snapshots. They receive the current
-- winner/payment destination through get_payment_destination().
drop policy if exists draws_select on public.draws;
create policy draws_select_agent_only on public.draws
for select to authenticated
using (
  exists (
    select 1
    from public.installments i
    where i.id = installment_id
      and (select private.is_chit_agent(i.chit_id))
  )
);

drop policy if exists draw_participants_select on public.draw_participants;
create policy draw_participants_select_agent_only on public.draw_participants
for select to authenticated
using (
  exists (
    select 1
    from public.draws d
    join public.installments i on i.id = d.installment_id
    where d.id = draw_id
      and (select private.is_chit_agent(i.chit_id))
  )
);

-- Do not expose draw or participant writes through the Data API.
revoke insert, update, delete on public.draws, public.draw_participants from authenticated;
revoke insert, update, delete on public.payment_obligations, public.receipts, public.audit_logs from authenticated;
