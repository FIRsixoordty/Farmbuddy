# Farm Buddy

**Teman Bertani, Dari Belajar Sampai Panen.**

Platform edukasi dan komunitas pertanian: belajar budidaya, kalender tanam,
alat pertanian, dan diskusi bersama sesama pegiat pertanian.

## Status

🚧 **Phase 3 — Authentication + Profile.** Register, login, logout, lupa
kata sandi, reset kata sandi, session persistence, protected routes, dan
halaman profil (lihat + edit) sudah berfungsi penuh terhadap Supabase Auth.
Komunitas, kalender, dan friendship masih placeholder. **Baca
`docs/phase-3-auth.md` sebelum deploy** — ada langkah manual wajib di
dashboard Supabase (template email) yang tidak bisa diatur lewat kode.

## Stack

- [Next.js](https://nextjs.org) (App Router) + TypeScript (strict)
- Tailwind CSS v4 + shadcn/ui (komponen ditulis manual, lihat catatan di
  bawah)
- [Supabase](https://supabase.com) — Auth, Postgres, Storage
- [Zod](https://zod.dev) untuk validasi form
- [Lucide React](https://lucide.dev) untuk ikon

## Menjalankan secara lokal

```bash
npm install
cp .env.local.example .env.local
# isi NEXT_PUBLIC_SUPABASE_URL & NEXT_PUBLIC_SUPABASE_ANON_KEY di .env.local
npm run dev
```

Buka [http://localhost:3000](http://localhost:3000).

Sebelum menyambungkan fitur apa pun ke data asli, jalankan
`supabase/schema.sql` lalu `supabase/seed.sql` di SQL Editor project
Supabase kamu — langkah lengkapnya ada di `supabase/README.md`.

Sejak Phase 3, halaman auth/profile/Navbar benar-benar memanggil Supabase
setiap request. `npm run dev`/`npm run build` tetap jalan dengan
`.env.local` kosong atau placeholder (semua kegagalan Supabase ditangani
secara graceful — lihat `docs/phase-3-auth.md`), tapi kamu butuh project
Supabase asli yang sudah dijalankan `schema.sql`+`seed.sql` untuk benar-benar
mencoba register/login.

## Struktur folder

```
app/
  auth/confirm/       Route handler verifikasi tautan email (konfirmasi & reset password)
  reset-password/     Halaman set kata sandi baru
  (routes lain)       App Router, lihat Section 7 master prompt
components/
  ui/           Komponen dasar (button, input, label, alert, sheet, ...) gaya shadcn/ui
  layout/       Navbar (server+client), Footer, Logo, PagePlaceholder
  auth/         Form register/login/forgot-password/reset-password, tombol logout
  profile/      ProfileHeader (tampilan publik), SettingsForm (edit profil sendiri)
  community/    (kosong — Phase 6)
  calendar/     (kosong — Phase 7)
  crops/        (kosong — Phase 8)
  tools/        (kosong — Phase 9)
lib/
  supabase/     Klien Supabase (browser, server, proxy) + helper profile/requireProfile
  actions/      Server actions (auth, profile) + tipe ActionState bersama
  validations/  Skema Zod untuk semua form auth/profile
  nav-links.ts  Sumber tunggal untuk link navigasi
  site-url.ts   Resolusi URL situs untuk tautan email
  utils.ts      Helper cn() + isSafeRedirectPath()
hooks/          (kosong — diisi seiring fitur interaktif)
types/          Tipe TypeScript yang dipakai lintas fitur (termasuk Profile)
supabase/       schema.sql, seed.sql, README.md (lihat di dalamnya)
docs/           Catatan mendalam per fase (mulai phase-3-auth.md)
proxy.ts        Pengganti middleware.ts di Next.js 16 — refresh session Supabase
```

## Catatan penting

- **shadcn/ui**: sandbox pengembangan ini tidak memiliki akses jaringan ke
  `ui.shadcn.com`, sehingga `npx shadcn init`/`add` tidak bisa dijalankan di
  sini. Komponen dasar (`button`, `sheet`, `separator`) ditulis manual
  mengikuti konvensi shadcn/ui (struktur `components.json` sudah ada). Di
  mesin dengan akses internet penuh, `npx shadcn@latest add <komponen>` akan
  berfungsi normal untuk menambah komponen baru.
- **Jangan pernah** menaruh `SUPABASE_SERVICE_ROLE_KEY` di variabel
  `NEXT_PUBLIC_*` atau di kode yang berjalan di browser.
- Data agronomi (komoditas, kalender tanam, modul budidaya, alat & mesin)
  bersumber dari `Data_Website_Edukasi_Farm_Buddy.md` dan sudah di-seed ke
  skema Supabase lewat `supabase/seed.sql` (lihat `supabase/README.md` untuk
  keputusan desain saat source tidak pas 1:1 dengan struktur tabel) — bukan
  di-hardcode di komponen React.
- **Sebelum deploy Phase 3 ke production, baca `docs/phase-3-auth.md`** —
  ada konfigurasi manual wajib di dashboard Supabase (template email untuk
  konfirmasi/reset password) yang tidak bisa diatur lewat kode.
- `components/ui/label.tsx` sengaja berupa elemen `<label>` biasa, bukan
  dibungkus primitive `@radix-ui/react-label` seperti shadcn/ui asli, untuk
  menghindari dependency tambahan yang manfaatnya minim di MVP ini.
