# Supabase — Farm Buddy (Phase 2)

## Cara menjalankan

1. Buka project Supabase kamu → **SQL Editor**.
2. Jalankan `schema.sql` lebih dulu (buat tabel, index, trigger, RLS, bucket storage). Aman dijalankan berkali-kali — semua `create table`/`policy`/dsb memakai `if not exists` / `drop ... if exists` sehingga idempotent.
3. Jalankan `seed.sql` setelah `schema.sql` berhasil. Juga aman dijalankan berkali-kali (upsert untuk `crops`/`farm_tools`, delete-lalu-insert untuk `crop_calendar`/`crop_modules`).
4. Isi `.env.local` di root project dengan `NEXT_PUBLIC_SUPABASE_URL` dan `NEXT_PUBLIC_SUPABASE_ANON_KEY` dari **Project Settings → API**.

Alternatif via Supabase CLI, dari root project:

```bash
supabase link --project-ref <project-ref>
supabase db push        # atau jalankan langsung:
psql "$DATABASE_URL" -f supabase/schema.sql
psql "$DATABASE_URL" -f supabase/seed.sql
```

## Cara ini sudah diverifikasi

Kedua file ini **benar-benar dijalankan** (bukan cuma ditulis) terhadap PostgreSQL 16 lokal dengan stub minimal skema `auth`/`storage` milik Supabase (role `anon`/`authenticated`/`service_role`, `auth.uid()`, `storage.objects`, `storage.buckets`, `storage.foldername()`), untuk memastikan sintaksnya benar-benar valid, bukan sekadar terlihat benar. Yang sudah diuji dan lolos:

- `schema.sql` apply bersih (exit code 0, tanpa error) dari database kosong.
- `seed.sql` apply bersih, dan **idempoten** — dijalankan dua kali berturut-turut tetap menghasilkan jumlah baris yang sama (15 crops, 17 crop_calendar, 31 crop_modules, 12 farm_tools).
- Like duplikat pada post yang sama oleh user yang sama → ditolak (`unique(post_id, user_id)`).
- Self-friendship → ditolak (`check (requester_id <> receiver_id)`).
- Friend request duplikat searah **maupun** kebalikan arah (B→A saat A→B masih pending) → sama-sama ditolak (`unique(user_low, user_high)`).
- RLS `bookmarks`: user B tidak bisa melihat bookmark user A; user A bisa melihat bookmarknya sendiri.
- RLS `crops`: `anon` bisa membaca; `authenticated` biasa **tidak** bisa insert (tidak ada policy insert untuk role itu).
- `crop_modules` menolak dua baris untuk section yang sama pada crop yang sama (`unique(crop_id, section)`).

## Tabel yang sengaja TIDAK di-seed

`profiles`, `posts`, `answers`, `friendships`, `post_likes`, `bookmarks` — semuanya butuh baris `auth.users` yang nyata atau aktivitas komunitas yang nyata. Membuat akun/diskusi palsu untuk isi awal bertentangan dengan instruksi "jangan membuat fake backend" (Section 38 master prompt). Tabel-tabel ini akan mulai terisi begitu Phase 3 (Auth) dan Phase 6 (Komunitas) berjalan.

## Keputusan desain saat source tidak pas 1:1 dengan struktur tabel

### 1. Bayam/Kangkung dan Cabai Rawit/Cabai Keriting dipisah jadi crop tersendiri, walau di source digabung satu baris

Source Tabel 2 menggabungkan "Sayuran Daun (Bayam, Kangkung)" jadi satu baris, dan "Cabai Rawit & Keriting" jadi satu baris juga. Tapi Section 17 master prompt secara eksplisit meminta keduanya sebagai crop terpisah (masing-masing harus punya halaman `/komoditas/[slug]` sendiri). Solusinya: 4 baris `crops` terpisah, tapi `crop_calendar` untuk pasangan masing-masing **identik** (data kalendernya memang tidak dibedakan di source). Untuk Cabai, hanya **Cabai Rawit** yang punya paragraf SOP budidaya rinci di source (jarak tanam, dosis pupuk) — jadi hanya Cabai Rawit yang punya baris `crop_modules`; Cabai Keriting kalendernya terisi tapi modul budidayanya kosong (bukan bug, memang tidak ada datanya).

### 2. `crop_calendar` punya dua "bentuk" data sekaligus: tanaman semusim vs. tanaman tahunan

Tabel 1 & 2 source (pangan, hortikultura) punya jendela tanam/panen berbasis **bulan spesifik** (`plant_start_month` ... `harvest_end_month`) — ini bagian yang lurus dipetakan.

Tabel 3 (perkebunan: Kakao, Karet, Kelapa Sawit, Tebu) punya bentuk data yang sama sekali berbeda: bukan "panen bulan sekian", tapi "mulai panen X tahun/bulan setelah tanam, lalu berulang tiap sekian minggu/hari". Memaksa data ini ke kolom `harvest_start_month`/`harvest_end_month` akan mengarang bulan panen yang tidak ada di source. Karena itu saya menambahkan kolom lain yang tetap nullable: `harvest_first_after_months_min/max` (jarak tanam→panen pertama, dalam bulan) dan `harvest_frequency_note` (frekuensi panen berkala). Untuk keempat komoditas ini, `harvest_start_month`/`harvest_end_month` sengaja dibiarkan `NULL`.

Untuk `plant_start_month`/`plant_end_month` pada Tabel 3: hanya diisi kalau source memang menyebut bulan spesifik (Karet: Okt-Nov, Tebu: Okt-Des). Kakao ("Sepanjang tahun, awal musim hujan") dan Kelapa Sawit ("Awal Musim Hujan") tidak punya bulan spesifik di source — jadi kolom bulan dibiarkan `NULL` dan keterangannya disimpan apa adanya di `planting_note`.

### 3. `farm_tools.function` dan `farm_tools.mechanism` adalah hasil pemisahan satu paragraf sumber

Section 21 master prompt eksplisit meminta kolom `function`, `mechanism`, dan `description` terpisah. Tapi Tabel 4 source menulis satu paragraf gabungan ("Prinsip Mekanika dan Fungsi Agronomis") untuk tiap alat, tidak dipisah jadi 3 atribut. Saya memenuhi struktur yang diminta dengan memisah paragraf itu menjadi kalimat "untuk apa alat ini" (`function`) dan "bagaimana cara kerjanya" (`mechanism`), lalu `description` menyimpan versi gabungan yang lebih lengkap untuk halaman detail. Tidak ada fakta baru yang ditambahkan — hanya reorganisasi kalimat yang sudah ada di source.

### 4. Rice Miller & Polisher dipisah jadi dua `farm_tools`, walau source menulisnya satu baris

Sama seperti kasus #1: source Tabel 4 menulis "Mesin Penggiling (Rice Miller) dan Polisher" sebagai satu baris, tapi Section 21 master prompt memintanya sebagai dua item terpisah. Saya pisah jadi dua baris (`rice-miller`, `polisher`), masing-masing mengambil bagian kalimat yang relevan dari paragraf sumber.

### 5. `crops.summary` dan `crops.image_url` sengaja `NULL` untuk semua baris

Source tidak memberikan ringkasan singkat bergaya pemasaran atau aset gambar untuk komoditas apa pun. Daripada mengarang deskripsi atau memakai gambar generik yang terkesan seperti data asli, kedua kolom ini dibiarkan `NULL` (TODO) di semua 15 baris `crops`, juga di semua `farm_tools.image_url`.

### 6. `crop_modules` yang tidak ada datanya tidak diberi baris kosong

Daripada insert 12 section × 15 crop = 180 baris yang isinya kebanyakan `NULL`, `seed.sql` hanya insert baris untuk section yang benar-benar punya isi di source (`source_available = true`). **Tidak adanya baris** untuk kombinasi (crop, section) tertentu punya arti yang sama dengan baris ber-`content = NULL`: source belum membahasnya. Frontend harus menampilkan status "belum tersedia", bukan menganggapnya bug. Daftar section per crop yang tersedia bisa dilihat langsung di komentar `seed.sql`.

### 7. `posts.category` adalah daftar tetap (check constraint), bukan tabel `categories` terpisah

Section 13 master prompt sudah memberi daftar kategori komunitas secara eksplisit (Padi, Jagung, ..., Umum). Karena ini keputusan taksonomi produk yang sudah diberikan langsung (bukan data agronomi yang perlu digali dari source Markdown), saya implementasikan sebagai `check constraint` di kolom `posts.category` — sederhana dan cukup untuk MVP. Kalau nanti kategori perlu dikelola dinamis lewat admin panel, ini best dimigrasikan ke tabel `categories` tersendiri (di luar cakupan Phase 2).

## Storage

Bucket `avatars` dan `post-images`: `public = true`, `file_size_limit = 5 MB`, `allowed_mime_types` dibatasi ke jpeg/png/webp langsung di level bucket (bukan hanya divalidasi di client). Konvensi path objek: `{auth.uid()}/nama-file.ext` — policy storage hanya mengizinkan user menulis ke dalam folder miliknya sendiri, memakai `storage.foldername(name)[1]`.

## Yang belum ada (menyusul di phase selanjutnya)

- Generated TypeScript types (`supabase gen types typescript`) — jalankan setelah schema ini diterapkan ke project Supabase asli, lalu lengkapi `TODO` di `lib/supabase/client.ts` dan `server.ts`.

> **Update Phase 3:** trigger `on_auth_user_created` (bagian 11 di `schema.sql`) kini otomatis membuat baris `profiles` begitu ada baris baru di `auth.users`, memakai metadata `username`/`display_name` yang dikirim saat `supabase.auth.signUp()`. Ini menggantikan rencana awal di atas ("insert profile dari app setelah register") karena pendekatan trigger tetap benar walau project mewajibkan konfirmasi email (saat itu belum ada session, sehingga insert dari app akan ditolak RLS). Trigger berjalan sebagai `SECURITY DEFINER` sehingga tidak terpengaruh RLS. Sudah diuji di Postgres lokal: signup dengan metadata, signup tanpa metadata (fallback username), dan tabrakan username (transaksi gagal atomik, tidak ada akun `auth.users` yatim) — detail di `docs/phase-3-auth.md`.
