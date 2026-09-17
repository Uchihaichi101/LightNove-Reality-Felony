-- REALITY: FELONY shared cloud storage
-- Chạy toàn bộ file này trong Supabase Dashboard -> SQL Editor.
-- Lưu ý: mật khẩu admin 120 được kiểm tra ở database function.

create table if not exists public.site_state (
  id bigint primary key check (id = 1),
  data jsonb,
  updated_at timestamptz not null default now()
);

insert into public.site_state (id, data)
values (1, null)
on conflict (id) do nothing;

alter table public.site_state enable row level security;

-- Không cho trình duyệt truy cập bảng trực tiếp.
revoke all on table public.site_state from anon, authenticated;

create or replace function public.get_site_data()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select data from public.site_state where id = 1;
$$;

create or replace function public.save_site_data(p_password text, p_data jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_password is distinct from '120' then
    raise exception 'Unauthorized';
  end if;

  update public.site_state
     set data = p_data,
         updated_at = now()
   where id = 1;

  return jsonb_build_object('ok', true, 'updated_at', now());
end;
$$;

-- Chỉ hai function được gọi từ website.
revoke execute on function public.get_site_data() from public;
revoke execute on function public.get_site_data() from authenticated;
revoke execute on function public.get_site_data() from anon;
grant execute on function public.get_site_data() to anon;

revoke execute on function public.save_site_data(text, jsonb) from public;
revoke execute on function public.save_site_data(text, jsonb) from authenticated;
revoke execute on function public.save_site_data(text, jsonb) from anon;
grant execute on function public.save_site_data(text, jsonb) to anon;
