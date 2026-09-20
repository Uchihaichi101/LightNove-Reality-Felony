-- REALITY: FELONY — Khu Bàn luận + biệt danh + tự xóa sau 30 ngày
-- Chạy toàn bộ đoạn này trong Supabase SQL Editor một lần.

create extension if not exists pgcrypto;

create table if not exists public.discussion_messages (
  id uuid primary key default gen_random_uuid(),
  nickname varchar(30) not null check (char_length(trim(nickname)) between 1 and 30),
  role varchar(10) not null default 'member' check (role in ('member','admin')),
  message varchar(1000) not null check (char_length(trim(message)) between 1 and 1000),
  created_at timestamptz not null default now()
);

create index if not exists discussion_messages_created_at_idx
  on public.discussion_messages(created_at);

alter table public.discussion_messages enable row level security;

-- Mọi người đăng nhập vào website đều có thể đọc cuộc trò chuyện.
drop policy if exists "discussion_read" on public.discussion_messages;
create policy "discussion_read"
on public.discussion_messages
for select
to anon, authenticated
using (true);

-- Member và admin đều có thể gửi tin nhắn.
drop policy if exists "discussion_send" on public.discussion_messages;
create policy "discussion_send"
on public.discussion_messages
for insert
to anon, authenticated
with check (
  char_length(trim(nickname)) between 1 and 30
  and char_length(trim(message)) between 1 and 1000
  and role in ('member','admin')
);

grant select, insert on public.discussion_messages to anon, authenticated;

-- ================================================================
-- TỰ ĐỘNG XÓA BÌNH LUẬN CŨ HƠN 30 NGÀY
-- ================================================================
-- pg_cron sẽ chạy mỗi ngày và xóa các tin đã quá 30 ngày.
create extension if not exists pg_cron;

create or replace function public.delete_expired_discussion_messages()
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.discussion_messages
  where created_at < now() - interval '30 days';
$$;

-- Xóa lịch cũ nếu đã từng chạy SQL này trước đó, rồi tạo lại.
do $$
begin
  if exists (select 1 from cron.job where jobname = 'delete-expired-discussion-messages') then
    perform cron.unschedule('delete-expired-discussion-messages');
  end if;
end $$;

select cron.schedule(
  'delete-expired-discussion-messages',
  '15 3 * * *',
  $$select public.delete_expired_discussion_messages();$$
);

-- Chạy một lần ngay khi thiết lập để dọn các bình luận đã quá hạn (nếu có).
select public.delete_expired_discussion_messages();

-- Không mở UPDATE/DELETE trực tiếp cho người dùng thông thường.
-- Việc xóa định kỳ do pg_cron gọi function bảo mật ở trên thực hiện.
