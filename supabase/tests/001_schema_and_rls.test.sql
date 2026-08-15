begin;

create extension if not exists pgtap with schema extensions;

select plan(20);

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'chits', 'chits table exists');
select has_table('public', 'chit_members', 'chit_members table exists');
select has_table('public', 'installments', 'installments table exists');
select has_table('public', 'draws', 'draws table exists');
select has_table('public', 'draw_participants', 'draw_participants table exists');
select has_table('public', 'payment_obligations', 'payment_obligations table exists');
select has_table('public', 'payment_submissions', 'payment_submissions table exists');
select has_table('public', 'receipts', 'receipts table exists');
select has_table('public', 'audit_logs', 'audit_logs table exists');

select col_is_pk('public', 'profiles', 'id', 'profile id is primary key');
select col_is_pk('public', 'chits', 'id', 'chit id is primary key');
select col_is_pk('public', 'installments', 'id', 'installment id is primary key');
select has_index('public', 'chit_members', 'chit_members_user_idx', 'member user index exists');
select has_index('public', 'payment_obligations', 'payment_obligations_member_idx', 'obligation member index exists');
select has_index('public', 'payment_submissions', 'payment_submissions_one_active_per_obligation_idx', 'one active payment submission index exists');

select policies_are(
  'public',
  'profiles',
  ARRAY['profiles_select_own_or_agent', 'profiles_update_own_or_agent'],
  'profiles exposes only owner/Agent policies'
);

select policies_are(
  'public',
  'chits',
  ARRAY['chits_select_member_or_agent', 'chits_insert_agent', 'chits_update_agent'],
  'chits exposes only member/Agent policies'
);

select policies_are(
  'public',
  'payment_submissions',
  ARRAY['payment_submissions_select', 'payment_submissions_insert_member'],
  'payment submissions expose only read/submit policies'
);

select results_eq(
  $$select count(*)::integer from pg_class where relname in ('profiles','chits','chit_members','payment_destinations','installments','draws','draw_participants','payment_obligations','payment_submissions','receipts','notifications','audit_logs') and relrowsecurity$$,
  $$values (12)$$,
  'all application tables have RLS enabled'
);

select * from finish();
rollback;
