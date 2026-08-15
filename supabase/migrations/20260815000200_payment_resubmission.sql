-- Allow a member to resubmit a rejected payment while preventing
-- multiple active/verified submissions for the same obligation.
alter table public.payment_submissions
drop constraint if exists payment_submissions_obligation_id_key;

create unique index payment_submissions_one_active_per_obligation_idx
on public.payment_submissions (obligation_id)
where status in ('submitted'::public.payment_status, 'verified'::public.payment_status);
