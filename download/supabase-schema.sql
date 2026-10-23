-- ============================================================
-- GO An Nahl — Supabase Schema
-- Matches the Prisma schema used by the app (12 tables)
--
-- HOW TO USE:
--   1. Open https://supabase.com/dashboard/project/kciglknjiosjbxfmtqjo/sql/new
--   2. Paste this entire file into the SQL editor
--   3. Click "Run" (Ctrl+Enter)
--   4. After successful execution, return to the GO An Nahl app,
--      open "Koneksi Supabase" → click "Tandai Sudah Diinisialisasi"
-- ============================================================

-- Extensions
create extension if not exists "pgcrypto";

-- ============= USERS =============
create table if not exists "User" (
  id         text primary key default gen_random_uuid()::text,
  username   text unique not null,
  password   text not null,
  name       text not null,
  role       text not null default 'pengelola',
  email      text,
  phone      text,
  avatar     text,
  active     boolean not null default true,
  "lastLogin" timestamptz,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

-- ============= USTAZ =============
create table if not exists "Ustaz" (
  id            text primary key default gen_random_uuid()::text,
  nip           text,
  nama          text not null,
  "jenisKelamin" text not null default 'L',
  "tempatLahir"  text,
  "tanggalLahir" timestamptz,
  alamat        text,
  "noHp"        text,
  email         text,
  spesialisasi  text,
  "tanggalMasuk" timestamptz not null default now(),
  status        text not null default 'aktif',
  catatan       text,
  "createdAt"   timestamptz not null default now(),
  "updatedAt"   timestamptz not null default now()
);

-- ============= KELAS =============
create table if not exists "Kelas" (
  id          text primary key default gen_random_uuid()::text,
  nama        text unique not null,
  tingkat     text not null default 'Tahsin',
  "ustazId"   text references "Ustaz"(id) on delete set null,
  kapasitas   integer not null default 20,
  keterangan  text,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

-- ============= SANTRI =============
create table if not exists "Santri" (
  id            text primary key default gen_random_uuid()::text,
  nis           text unique not null,
  nama          text not null,
  "jenisKelamin" text not null default 'L',
  "tempatLahir"  text,
  "tanggalLahir" timestamptz,
  alamat        text,
  "namaAyah"    text,
  "namaIbu"     text,
  "noHpOrtu"    text,
  "kelasId"     text references "Kelas"(id) on delete set null,
  "tanggalMasuk" timestamptz not null default now(),
  status        text not null default 'aktif',
  catatan       text,
  "sppBulanan"  integer not null default 150000,
  "createdAt"   timestamptz not null default now(),
  "updatedAt"   timestamptz not null default now()
);

-- ============= KELOMPOK BELAJAR =============
create table if not exists "KelompokBelajar" (
  id              text primary key default gen_random_uuid()::text,
  nama            text not null,
  "ustazId"       text references "Ustaz"(id) on delete set null,
  "mataPelajaran" text not null default 'Tahfidz',
  ruangan         text,
  kapasitas       integer not null default 10,
  catatan         text,
  status          text not null default 'aktif',
  "createdAt"     timestamptz not null default now(),
  "updatedAt"     timestamptz not null default now()
);

-- ============= JADWAL KELOMPOK =============
create table if not exists "JadwalKelompok" (
  id           text primary key default gen_random_uuid()::text,
  "kelompokId" text not null references "KelompokBelajar"(id) on delete cascade,
  hari         text not null,
  "jamMulai"   text not null,
  "jamSelesai" text not null,
  "createdAt"  timestamptz not null default now()
);

-- ============= ANGGOTA KELOMPOK =============
create table if not exists "AnggotaKelompok" (
  id            text primary key default gen_random_uuid()::text,
  "kelompokId"  text not null references "KelompokBelajar"(id) on delete cascade,
  "santriId"    text not null references "Santri"(id) on delete cascade,
  "tanggalGabung" timestamptz not null default now(),
  "createdAt"    timestamptz not null default now(),
  unique ("kelompokId", "santriId")
);

-- ============= PEMBAYARAN SPP =============
create table if not exists "PembayaranSPP" (
  id                  text primary key default gen_random_uuid()::text,
  "noPembayaran"      text unique not null,
  "santriId"          text not null references "Santri"(id) on delete cascade,
  bulan               text not null,
  jumlah              integer not null,
  "tanggalBayar"      timestamptz not null default now(),
  "metodePembayaran"  text not null default 'tunai',
  status              text not null default 'lunas',
  keterangan          text,
  "diterimaOleh"      text,
  "createdAt"         timestamptz not null default now(),
  "updatedAt"         timestamptz not null default now()
);
create index if not exists "idx_pembayaran_santriId" on "PembayaranSPP"("santriId");
create index if not exists "idx_pembayaran_bulan" on "PembayaranSPP"(bulan);
create index if not exists "idx_pembayaran_tanggalBayar" on "PembayaranSPP"("tanggalBayar");

-- ============= PENGATURAN =============
create table if not exists "Pengaturan" (
  id    text primary key default 'singleton',
  key   text unique not null,
  value text
);

-- ============= PESAN TEMPLATE =============
create table if not exists "PesanTemplate" (
  id        text primary key default gen_random_uuid()::text,
  kode      text unique not null,
  nama      text not null,
  isi       text not null,
  kategori  text not null default 'umum',
  aktif     boolean not null default true,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

-- ============= PESAN LOG =============
create table if not exists "PesanLog" (
  id            text primary key default gen_random_uuid()::text,
  penerima      text not null,
  "namaPenerima" text,
  pesan         text not null,
  kategori      text not null default 'umum',
  status        text not null default 'terkirim',
  mode          text not null default 'manual',
  "refId"       text,
  "refType"     text,
  error         text,
  "durationMs"  integer not null default 0,
  "createdAt"   timestamptz not null default now()
);
create index if not exists "idx_pesanlog_kategori" on "PesanLog"(kategori);
create index if not exists "idx_pesanlog_createdAt" on "PesanLog"("createdAt");

-- ============= SUPABASE CONFIG =============
create table if not exists "SupabaseConfig" (
  id                text primary key default 'singleton',
  url               text,
  "publishableKey"  text,
  "serviceRoleKey"  text,
  configured        boolean not null default false,
  "configuredAt"    timestamptz,
  initialized       boolean not null default false,
  "initializedAt"   timestamptz,
  "updatedAt"       timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- Demo: allow anon role full access to all tables.
-- IN PRODUCTION: tighten these policies per role.
-- ============================================================
alter table "User"            enable row level security;
alter table "Ustaz"           enable row level security;
alter table "Kelas"           enable row level security;
alter table "Santri"          enable row level security;
alter table "KelompokBelajar" enable row level security;
alter table "JadwalKelompok"  enable row level security;
alter table "AnggotaKelompok" enable row level security;
alter table "PembayaranSPP"   enable row level security;
alter table "Pengaturan"      enable row level security;
alter table "PesanTemplate"   enable row level security;
alter table "PesanLog"        enable row level security;
alter table "SupabaseConfig"  enable row level security;

do $$
declare t text;
begin
  foreach t in array array[
    'User','Ustaz','Kelas','Santri','KelompokBelajar','JadwalKelompok',
    'AnggotaKelompok','PembayaranSPP','Pengaturan','PesanTemplate','PesanLog','SupabaseConfig'
  ]
  loop
    execute format('drop policy if exists "anon_all_%s" on %I', t, t);
    execute format('create policy "anon_all_%s" on %I for all to anon using (true) with check (true)', t, t);
  end loop;
end$$;

-- ============================================================
-- Seed: demo admin user (so you can test login from the app)
-- ============================================================
insert into "User" (username, password, name, role, email, "active")
values ('admin', 'admin123', 'Administrator', 'admin', 'admin@annahl.sch.id', true)
on conflict (username) do nothing;

-- Done. Verify:
--   select count(*) from "User";          -- should return 1
--   select table_name from information_schema.tables where table_schema='public';
