# Phase 3 — Authentication + Profile

## Alur ringkas

- **Register** → `supabase.auth.signUp()` dengan `username`/`display_name` dikirim sebagai metadata → trigger `on_auth_user_created` di database (schema.sql, bagian 11) otomatis membuat baris `profiles`. Kalau konfirmasi email aktif di project-mu, tidak ada session dulu → halaman menampilkan pesan "cek email"; kalau tidak aktif, langsung diarahkan ke `/dashboard`.
- **Login** → `signInWithPassword()`, lalu redirect ke `?next=` (kalau ada) atau `/dashboard`.
- **Logout** → tombol di Navbar, submit ke `logoutAction` (`signOut()` lalu redirect ke `/`).
- **Forgot password** → `resetPasswordForEmail()` mengirim email berisi tautan ke `/auth/confirm?...&next=/reset-password`.
- **Reset password** → `/auth/confirm` (route handler) memverifikasi tautan (`verifyOtp`) dan membuka session recovery, lalu redirect ke `/reset-password` yang memanggil `updateUser({ password })`.
- **Session persistence** → ditangani `@supabase/ssr` lewat cookie; `proxy.ts` (nama baru untuk `middleware.ts` di Next.js 16) menyegarkan token di tiap request.
- **Protected routes** → `/dashboard` dan `/pengaturan`. Dilindungi dua lapis: `proxy.ts` melakukan redirect cepat ("optimistic") kalau tidak ada cookie session sama sekali, tapi **pengecekan yang sebenarnya** ada di tiap halaman lewat `requireProfile()` yang memanggil `supabase.auth.getUser()` (bukan `getSession()`, karena `getUser()` benar-benar memvalidasi ke server Supabase Auth, bukan cuma baca cookie lokal).

## ⚠️ Langkah manual yang WAJIB dilakukan di dashboard Supabase

Kode ini tidak bisa mengatur ini lewat SQL/API — harus manual di **Supabase Dashboard → Authentication → Email Templates**:

1. Buka template **"Reset Password"**, pastikan tautan konfirmasinya memakai `{{ .TokenHash }}`, contoh:
   ```
   {{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=recovery&next=/reset-password
   ```
2. Kalau kamu ingin flow "konfirmasi email setelah daftar" juga aktif, template **"Confirm signup"** sebaiknya memakai pola serupa:
   ```
   {{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=email&next=/dashboard
   ```
3. Di **Authentication → URL Configuration**, tambahkan domain deployment kamu (dan `http://localhost:3000` untuk dev) ke **Redirect URLs**, atau Supabase akan menolak redirect ke situ.
4. Putuskan apakah **"Confirm email"** di **Authentication → Providers → Email** ingin diaktifkan atau tidak — kode ini sudah menangani KEDUA kemungkinan (lihat alur Register di atas), jadi tidak ada kode yang perlu diubah, ini murni keputusan produk/keamanan kamu.

## Kenapa desain profil-otomatis lewat trigger, bukan insert dari aplikasi

Lihat `supabase/README.md` bagian "Update Phase 3" — ringkasnya: trigger tetap benar walau project mewajibkan konfirmasi email (saat itu belum ada session, jadi insert dari kode aplikasi akan ditolak RLS), dan sudah diuji atomik (tabrakan username membatalkan seluruh proses signup, tidak menyisakan akun `auth.users` yatim).

## Kenapa `middleware.ts` menjadi `proxy.ts`

Next.js 16 mengganti nama Middleware menjadi **Proxy** (file `proxy.ts` di root, fungsi diekspor bernama `proxy`). `middleware.ts` masih berfungsi untuk kompatibilitas tapi sudah dianggap usang. Project ini langsung memakai konvensi baru. API-nya (NextRequest/NextResponse, `request.cookies`, `response.cookies`) sama persis dengan Middleware lama.

## Yang benar-benar sudah diuji (bukan cuma dibaca)

Sandbox pengembangan ini **tidak** punya akses jaringan ke `*.supabase.co` dan tidak dikoneksikan ke project Supabase asli manapun, jadi login/register sungguhan lewat GoTrue tidak bisa dijalankan end-to-end dari sini. Yang sudah diverifikasi nyata:

1. **Trigger auto-create-profile** (`on_auth_user_created`) — diuji di PostgreSQL lokal: signup dengan metadata → profile benar; signup tanpa metadata → fallback username, tidak gagal; dua signup dengan username sama → transaksi kedua gagal total & atomik, tidak ada baris `auth.users` yatim (detail di `supabase/README.md`).
2. **Proteksi route** — server Next.js dijalankan sungguhan (`next build && next start`) dan dites dengan `curl`:
   - `GET /dashboard` tanpa cookie session → `307` ke `/login?next=%2Fdashboard`
   - `GET /pengaturan` tanpa cookie session → `307` ke `/login?next=%2Fpengaturan`
   - `GET /login?next=%2Fdashboard` → form berisi `<input type="hidden" name="next" value="/dashboard">`
   - `GET /register` → keempat field (`email`, `password`, `username`, `displayName`) ada di HTML
   - `GET /reset-password` tanpa session recovery → menampilkan pesan "tautan tidak valid", bukan form
   - `GET /profil/user-tidak-ada` → `404`
   - Log server tidak menunjukkan error/exception yang tidak tertangani di rute manapun.
3. **Perilaku gagal-aman terhadap Supabase yang tak terjangkau** — diverifikasi langsung lewat Node bahwa `supabase-js` (versi yang dipakai project ini) mengembalikan `{ error }` dan bukan `throw` saat fetch gagal, sehingga `loginAction`/`registerAction`/`getCurrentProfile()` tidak pernah crash 500 hanya karena Supabase tidak terjangkau — direspons sebagai pesan error biasa ke pengguna, dan `getCurrentProfile()` secara eksplisit "fail closed" (dianggap belum login) lewat try/catch.

## Yang TIDAK bisa diuji dari sandbox ini — checklist manual untukmu

Setelah kamu isi `.env.local` dengan project Supabase asli (dan sudah menjalankan `supabase/schema.sql` + `seed.sql`), jalankan `npm run dev` lalu tes manual berikut:

- [ ] Daftar dengan email baru → cek apakah langsung masuk atau diminta konfirmasi email (tergantung setting project-mu), dan pastikan baris `profiles` otomatis muncul di Table Editor.
- [ ] Coba daftar dengan **username yang sama** dua kali → harus ditolak dengan pesan "Username sudah digunakan".
- [ ] Login dengan akun yang baru dibuat → berhasil masuk ke `/dashboard`, nama tampil benar.
- [ ] Klik "Keluar" di Navbar → kembali ke Beranda, Navbar kembali menampilkan tombol Masuk/Daftar.
- [ ] Coba akses `/dashboard` setelah logout → diarahkan ke `/login`.
- [ ] Klik "Lupa kata sandi?" → masukkan email terdaftar → cek email masuk (perlu langkah dashboard di atas sudah dilakukan) → klik tautan → berhasil sampai ke `/reset-password` dengan form (bukan pesan error) → set kata sandi baru → berhasil masuk ke `/dashboard`.
- [ ] Buka `/profil/<username-kamu>` saat login → tombol "Edit Profil" muncul; buka punya orang lain → tombol itu tidak muncul.
- [ ] Ubah nama tampilan/bio/lokasi di `/pengaturan` → simpan → cek `/profil/<username>` sudah menampilkan data baru tanpa perlu logout/login ulang.
