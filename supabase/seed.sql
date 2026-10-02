-- ============================================================================
-- FARM BUDDY — SEED DATA (Phase 2)
-- ============================================================================
-- Educational reference content only: crops, crop_calendar, crop_modules,
-- farm_tools. Every value here traces back to "Data_Website_Edukasi_Farm_
-- Buddy.md" (see the table-by-table mapping in supabase/README.md).
--
-- Deliberately NOT seeded: profiles, posts, answers, friendships, likes,
-- bookmarks. Those need real auth.users rows and real community activity —
-- inventing fake accounts/discussions would contradict Section 38 of the
-- master prompt ("Jangan membuat fake backend").
--
-- Safe to re-run: crops/farm_tools upsert on their slug; crop_calendar and
-- crop_modules are refreshed by deleting and re-inserting per crop.
-- Run this AFTER schema.sql, using a connection that can bypass RLS
-- (the Supabase SQL Editor, or `service_role`/the Postgres superuser).
-- ============================================================================

-- ============================================================================
-- 1. CROPS
-- ============================================================================
-- summary and image_url are left NULL on purpose: the source document gives
-- neither a marketing-style summary nor any image assets for any commodity.

insert into public.crops (slug, name, category, land_type, season_preference)
values
  -- Tanaman Pangan (source Table 1)
  ('padi-sawah', 'Padi Sawah', 'pangan', 'Irigasi Teknis', null),
  ('padi-tadah-hujan', 'Padi Tadah Hujan', 'pangan', 'Lahan Kering', null),
  ('jagung', 'Jagung', 'pangan', 'Sawah / Lahan Kering', null),
  ('kedelai', 'Kedelai', 'pangan', 'Lahan Bekas Padi', null),

  -- Hortikultura Sayuran (source Table 2)
  -- Bayam & Kangkung are one combined row ("Sayuran Daun") in the source;
  -- split into two crop records here because Section 17 of the master
  -- prompt lists them as separate pages. Both share identical calendar
  -- data below since the source never differentiates them.
  ('bayam', 'Bayam', 'hortikultura', null, 'Musim Hujan'),
  ('kangkung', 'Kangkung', 'hortikultura', null, 'Musim Hujan'),
  ('tomat', 'Tomat', 'hortikultura', null, 'Musim Kemarau'),
  -- Cabai Rawit & Cabai Keriting: same split rationale as Bayam/Kangkung.
  -- Only Cabai Rawit has a dedicated SOP paragraph in the source (see
  -- crop_modules below) — Cabai Keriting's cultivation modules stay TODO.
  ('cabai-rawit', 'Cabai Rawit', 'hortikultura', null, 'Kemarau / Transisi'),
  ('cabai-keriting', 'Cabai Keriting', 'hortikultura', null, 'Kemarau / Transisi'),
  ('bawang-merah', 'Bawang Merah', 'hortikultura', null, 'Kemarau'),
  ('kentang', 'Kentang', 'hortikultura', 'Dataran Tinggi', 'Kemarau'),

  -- Perkebunan (source Table 3)
  ('kakao', 'Kakao', 'perkebunan', null, null),
  ('karet', 'Karet', 'perkebunan', null, null),
  ('kelapa-sawit', 'Kelapa Sawit', 'perkebunan', null, null),
  ('tebu', 'Tebu (Varietas Genjah)', 'perkebunan', null, null)
on conflict (slug) do update set
  name = excluded.name,
  category = excluded.category,
  land_type = excluded.land_type,
  season_preference = excluded.season_preference;

-- ============================================================================
-- 2. CROP CALENDAR
-- ============================================================================
-- Re-seedable: clear existing calendar rows for every crop we're about to
-- insert, then insert fresh ones, so re-running this file never duplicates
-- or leaves stale rows behind.

delete from public.crop_calendar
where crop_id in (select id from public.crops where slug in (
  'padi-sawah', 'padi-tadah-hujan', 'jagung', 'kedelai',
  'bayam', 'kangkung', 'tomat', 'cabai-rawit', 'cabai-keriting',
  'bawang-merah', 'kentang', 'kakao', 'karet', 'kelapa-sawit', 'tebu'
));

-- --- Tanaman Pangan ---------------------------------------------------------

-- Padi Sawah has two planting windows in the source (MT1 and MT2), so it
-- gets two calendar rows.
insert into public.crop_calendar
  (crop_id, period_label, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'padi-sawah'), 'MT1', 10, 11, 2, 3,
   'Membutuhkan ketersediaan air stabil selama masa vegetatif. Diikuti palawija pada MT3.'),
  ((select id from public.crops where slug = 'padi-sawah'), 'MT2', 3, 4, 6, 7,
   'Membutuhkan ketersediaan air stabil selama masa vegetatif. Diikuti palawija pada MT3.');

insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'padi-tadah-hujan'), 11, 12, 3, 4,
   'Tanam dieksekusi pasca hujan stabil (minimal >100 mm/minggu berturut-turut).'),
  ((select id from public.crops where slug = 'jagung'), 10, 11, 1, 2,
   'Siklus panen optimal tercapai pada usia 7-8 minggu; sensitif terhadap kelebihan air saat tongkol muda.');

insert into public.crop_calendar
  (crop_id, period_label, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'kedelai'), 'MT3 (puncak)', 7, 10, 9, 12,
   'Tidak toleran terhadap genangan air (waterlogging). Ditanam segera setelah padi dipanen untuk memanfaatkan sisa kelembaban.');

-- --- Hortikultura Sayuran ----------------------------------------------------

-- Bayam & Kangkung: identical calendar per the source's "Sayuran Daun" row.
insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'bayam'), 1, 3, 2, 4,
   'Memiliki toleransi kelembaban tinggi. Produksi relatif andal pada periode curah hujan lebat.'),
  ((select id from public.crops where slug = 'kangkung'), 1, 3, 2, 4,
   'Memiliki toleransi kelembaban tinggi. Produksi relatif andal pada periode curah hujan lebat.'),
  ((select id from public.crops where slug = 'tomat'), 5, 7, 8, 10,
   'Menghindari fase pembungaan di puncak musim hujan untuk menekan risiko penyakit jamur (blight). Kualitas buah dan harga mencapai optimal.');

-- Cabai Rawit & Cabai Keriting: identical calendar per the source's
-- combined "Cabai Rawit & Keriting" row.
insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'cabai-rawit'), 6, 7, 8, 9,
   'Puncak panen dan ketersediaan terbaik terjadi akhir Juli-September. Harga tertinggi historis terjadi Januari-Maret akibat gagal panen karena hujan ekstrem.'),
  ((select id from public.crops where slug = 'cabai-keriting'), 6, 7, 8, 9,
   'Puncak panen dan ketersediaan terbaik terjadi akhir Juli-September. Harga tertinggi historis terjadi Januari-Maret akibat gagal panen karena hujan ekstrem.');

-- Bawang Merah has two planting windows in the source.
insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'bawang-merah'), 5, 6, 7, 8,
   'Pembentukan umbi sangat sensitif terhadap kelebihan lengas tanah yang memicu patogen Fusarium dan bakteri pembusuk.'),
  ((select id from public.crops where slug = 'bawang-merah'), 8, 9, 10, 11,
   'Pembentukan umbi sangat sensitif terhadap kelebihan lengas tanah yang memicu patogen Fusarium dan bakteri pembusuk.');

insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_start_month, harvest_end_month, source_note)
values
  ((select id from public.crops where slug = 'kentang'), 5, 6, 8, 9,
   'Lahan harus bebas dari genangan air agar umbi dapat melakukan ekspansi pembesaran maksimum.');

-- --- Perkebunan --------------------------------------------------------------
-- These four do not have a fixed annual harvest month window in the source
-- (unlike Table 1 & 2): harvest is described as "months/years after
-- planting, then an ongoing frequency" instead. plant_start_month/
-- plant_end_month are only filled in where the source gives specific
-- months; harvest_start_month/harvest_end_month are left NULL for all four
-- on purpose (see supabase/README.md, decision #2).

insert into public.crop_calendar
  (crop_id, planting_note, harvest_first_after_months_min, harvest_first_after_months_max, harvest_frequency_note, source_note)
values
  ((select id from public.crops where slug = 'kakao'),
   'Sepanjang tahun (awal musim hujan)', 24, 36,
   'Berkala setiap 1-4 minggu (hampir sepanjang tahun) setelah mulai berproduksi.',
   'Buah membutuhkan 5-6 bulan dari fase pembungaan hingga matang sempurna. Umur produktif mencapai 20-30 tahun.');

insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_first_after_months_min, harvest_first_after_months_max, harvest_frequency_note, source_note)
values
  ((select id from public.crops where slug = 'karet'), 10, 11, 60, 60,
   'Penyadapan harian / dua hari sekali setelah matang sadap.',
   'Siap disadap ketika lilit batang mencapai 45 cm pada ketinggian 1 meter dari tanah.');

insert into public.crop_calendar
  (crop_id, planting_note, harvest_first_after_months_min, harvest_first_after_months_max, harvest_frequency_note, source_note)
values
  ((select id from public.crops where slug = 'kelapa-sawit'),
   'Awal Musim Hujan', 31, 31,
   'Rotasi panen berkala setiap 10-14 hari setelah mulai berproduksi.',
   'Membutuhkan ketersediaan lengas tanah yang konstan pada tahun pertama pertumbuhan.');

insert into public.crop_calendar
  (crop_id, plant_start_month, plant_end_month, harvest_first_after_months_min, harvest_first_after_months_max, harvest_frequency_note, source_note)
values
  ((select id from public.crops where slug = 'tebu'), 10, 12, 12, 12,
   'Panen tunggal di akhir siklus.',
   'Memerlukan pasokan air tinggi di awal vegetatif, namun kemarau kering saat menjelang panen untuk akumulasi rendemen sukrosa.');

-- ============================================================================
-- 3. CROP MODULES
-- ============================================================================
-- Only sections with real content in the source are inserted (source_available
-- = true). A crop with no row at all for a given section — or a row with
-- source_available = false — both mean "not covered by the source"; the
-- frontend should render a "belum tersedia" state rather than treat a
-- missing row as a bug. See supabase/README.md, decision #4.

delete from public.crop_modules
where crop_id in (select id from public.crops where slug in (
  'padi-sawah', 'kedelai', 'tomat', 'cabai-rawit', 'bawang-merah', 'kentang',
  'kakao', 'karet', 'kelapa-sawit', 'tebu'
));

-- --- Padi Sawah --------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'padi-sawah'), 'persiapan_lahan',
   'Fase persiapan lahan memerlukan penggenangan air intensif dilanjutkan dengan pembajakan ganda untuk menciptakan struktur tanah melumpur (puddling) yang ideal bagi penetrasi sistem perakaran padi muda.',
   true),
  ((select id from public.crops where slug = 'padi-sawah'), 'pemupukan',
   'Dosis pupuk Nitrogen dikalkulasikan berdasarkan target produktivitas aktual dan status hara tanah. Untuk lahan berproduktivitas rendah (di bawah 5 ton gabah/ha), kebutuhan Urea sekitar 200 kg/ha; untuk lahan intensif berproduktivitas tinggi (di atas 6 ton/ha), dosis Urea 300-400 kg/ha. Pemberian pupuk majemuk NPK 15-15-15 secara rata sebesar 300 kg/ha sering kali tidak efisien untuk sawah yang sudah memiliki cadangan Fosfor dan Kalium sedang-tinggi, karena berisiko memicu akumulasi hara berlebih. Pada tanah dengan pH basa ekstrem (di atas 7), seperti golongan tanah Vertisol di Jawa Tengah bagian timur, Jawa Timur, dan Nusa Tenggara, pupuk ZA (Amonium Sulfat) 100 kg/ha dapat direkomendasikan dan berpotensi menghemat dosis Urea sebesar 50 kg/ha. Gunakan Bagan Warna Daun (BWD) untuk menilai kebutuhan Nitrogen secara visual langsung di lapangan.',
   true);

-- --- Kedelai -------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'kedelai'), 'kondisi_ideal',
   'Kedelai tidak menoleransi kondisi tanah tergenang, namun memiliki kemampuan simbiosis dengan bakteri Rhizobium sp. pada bintil akarnya yang menambat Nitrogen bebas dari atmosfer secara alami.',
   true),
  ((select id from public.crops where slug = 'kedelai'), 'penanaman',
   'Metode Tanpa Olah Tanah (TOT) sangat dianjurkan, terutama saat transisi memasuki Musim Tanam 3 pasca panen padi. Sesaat setelah padi dipotong, benih kedelai dapat segera ditugal tepat pada bekas alur jerami padi, memanfaatkan sisa kelembaban kapiler tanpa membongkar profil tanah. Varietas genjah seperti Kedelai Grobogan dapat mencapai kemasakan fisiologis dalam kurang lebih 76 hari.',
   true),
  ((select id from public.crops where slug = 'kedelai'), 'pemupukan',
   'Aplikasi Pupuk Organik Cair (POC) buatan lokal secara periodik (4 kali semprot) tanpa tambahan pupuk kimia sintetis pernah ditunjukkan mampu mendorong produktivitas hingga 2,5-3 ton per hektar dalam sebuah studi.',
   true);

-- --- Tomat -----------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'tomat'), 'kondisi_ideal',
   'Membutuhkan profil tanah bertekstur liat berpasir yang kaya bahan organik, sirkulasi aerasi optimal, dan tingkat keasaman tanah pada rentang pH 5-6.',
   true),
  ((select id from public.crops where slug = 'tomat'), 'pembibitan',
   'Kebutuhan benih untuk satu hektar berkisar 300-500 gram, dengan viabilitas kecambah di atas 75%. Benih disemai ke pot daun pisang atau polybag kecil berisi media campuran tanah dan pupuk kandang matang (rasio 1:1). Untuk mencegah hama tanah (semut, nematoda) pada fase kritis pembibitan, media semai dapat diaplikasikan pestisida karbofuran (seperti Furadan) dengan dosis sangat rendah: 0,3 gram per pot, atau setara 10 kg/ha.',
   true),
  ((select id from public.crops where slug = 'tomat'), 'persiapan_lahan',
   'Bedengan dibuat dengan lebar 110-120 cm, tinggi 20-30 cm, dan parit drainase antar bedengan selebar 50 cm untuk mencegah asfiksia (kekurangan oksigen) pada zona akar saat hujan lebat.',
   true),
  ((select id from public.crops where slug = 'tomat'), 'penanaman',
   'Jarak tanam dalam barisan 50-60 cm dan antar barisan 40-50 cm.',
   true),
  ((select id from public.crops where slug = 'tomat'), 'pemupukan',
   'Pemupukan dasar: Urea 200 kg/ha, SP-36 250 kg/ha, KCl 100 kg/ha. Setengah dosis Urea dan KCl diberikan sebagai pupuk dasar bersama seluruh dosis SP-36; sisanya diberikan sebagai pupuk susulan pada umur 25-30 hari saat tanaman memasuki transisi vegetatif menuju generatif. Jika SP-36 langka di pasaran, dapat disubstitusi dengan pupuk Fosfat Alam dengan dosis dinaikkan menjadi 300-350 kg/ha, ditebar minimal satu minggu sebelum tanam karena pelepasan unsur Fosfornya lebih lambat.',
   true);

-- --- Cabai Rawit -------------------------------------------------------------
-- Only Cabai Rawit has a dedicated SOP paragraph in the source; Cabai
-- Keriting is only ever mentioned together with it in the calendar table,
-- so Cabai Keriting intentionally has no crop_modules rows here.
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'cabai-rawit'), 'penanaman',
   'Prinsip bedengan mirip tomat. Jarak tanam disesuaikan dengan musim: pada musim hujan direnggangkan menjadi 50x70 cm untuk menekan kelembaban mikro di bawah kanopi daun (yang memicu jamur); pada musim kemarau dirapatkan menjadi 40x60 cm. Populasi tanaman per hektar sekitar 20.000 titik tanam, dengan dua bibit dimasukkan ke dalam satu lubang tanam.',
   true),
  ((select id from public.crops where slug = 'cabai-rawit'), 'pemupukan',
   'Kebutuhan pupuk kandang organik dalam jumlah besar, yakni 10-30 ton/ha, dibenamkan saat pembentukan bedeng, disertai Urea 200-300 kg/ha, SP-36 200-300 kg/ha, dan KCl 150-250 kg/ha. Pemupukan susulan dilakukan dengan teknik kocor (penyiraman langsung ke pangkal akar): 1,5-3 kg pupuk padat dilarutkan ke dalam 100 liter air, lalu diaplikasikan sekitar 150-250 ml larutan per tanaman secara individual.',
   true),
  ((select id from public.crops where slug = 'cabai-rawit'), 'pemeliharaan',
   'Penyiangan gulma harus dilakukan secara mekanis dan disiplin untuk mengeliminasi kompetisi dalam perebutan unsur hara.',
   true);

-- --- Bawang Merah -------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'bawang-merah'), 'persiapan_lahan',
   'Apabila uji lapangan menunjukkan pH di bawah 5,6, prosedur pengapuran menggunakan batuan dolomit dengan dosis 1-2 ton per hektar wajib ditaburkan pada tahap pembajakan pertama, selambat-lambatnya dua minggu sebelum waktu tanam.',
   true),
  ((select id from public.crops where slug = 'bawang-merah'), 'penanaman',
   'Umbi ditanam dengan kerapatan 15x20 cm.',
   true),
  ((select id from public.crops where slug = 'bawang-merah'), 'pemupukan',
   'Aplikasi pupuk SP-36 (100 kg/ha) sebelum tanam, dilanjutkan dengan NPK Phonska majemuk (500 kg/ha), Urea (180 kg/ha), dan KCl (60 kg/ha) yang disebar di atas bedengan saat tanaman berumur 15 dan 30 hari pasca tanam.',
   true),
  ((select id from public.crops where slug = 'bawang-merah'), 'hama_penyakit',
   'Patogen jamur tular tanah Fusarium oxysporum, penyebab kelayuan massal, dicegah secara profilaktik melalui teknik pelapisan benih (seed treatment): 100 kg umbi bawang merah direaksikan dengan 100 gram fungisida berbahan aktif Mankozeb, lalu dikarantina dalam karung plastik selama satu hingga dua hari. Untuk membangun pertahanan biologis di zona rhizosfer, aplikasi agens hayati Trichoderma sp. dengan dosis 50 kg per hektar direkomendasikan, dilarutkan 200 gram biang pekat ke dalam 14 liter air (satu tangki sprayer) dan disemprotkan merata ke tumpukan pupuk kandang sebelum diaduk ke tanah. Pemberantasan hama uret (larva kumbang Holotrichia sp.) dilakukan pada petang hari dengan menaburkan umpan beracun berupa campuran 10 kg dedak halus, 1 kg gula molase, dan 125-250 gram insektisida sistemik di sekitar area perakaran.',
   true);

-- --- Kentang -----------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'kentang'), 'pemupukan',
   'Formulasi pupuk makro dasar berupa pupuk kandang serta campuran Nitrogen 50 kg/ha (setara 110 kg Urea), diiringi 220 kg TSP untuk menyokong perbesaran morfologi jaringan umbi pati di bawah permukaan tanah.',
   true);

-- --- Kakao -----------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'kakao'), 'kondisi_ideal',
   'Bibit kakao tidak mentolerir paparan sinar matahari langsung, sehingga pohon pelindung (naungan) sementara dan naungan permanen harus diintegrasikan ke dalam ekosistem lahan sekurang-kurangnya 12 hingga 18 bulan mendahului jadwal penanaman bibit kakao itu sendiri.',
   true),
  ((select id from public.crops where slug = 'kakao'), 'catatan',
   'Pertumbuhan morfologi buah kakao melintasi dua fase kritis; kecepatan pembesaran sel melesat dan mencapai puncak pada hari ke-75 pasca fertilisasi organ bunga. Proses dari pembungaan menuju buah matang sempurna memakan waktu 5-6 bulan. Pembungaan terjadi secara determinat kontinyu, sehingga pemanenan dapat berlangsung setiap 1-4 minggu, memberikan arus kas yang relatif konsisten bagi rumah tangga petani hingga tanaman berumur lebih dari dua dekade.',
   true);

-- --- Karet -----------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'karet'), 'pembibitan',
   'Bibit yang disemai harus berasal dari pohon induk klon tersertifikasi yang umurnya telah melampaui 10 tahun. Transplantasi ke lahan dilakukan saat akar tunggang telah lurus dan membentuk formasi akar lateral sepanjang 5-10 cm.',
   true),
  ((select id from public.crops where slug = 'karet'), 'penanaman',
   'Kerapatan populasi yang diproyeksikan adalah 550 pohon per hektar, diatur dengan jarak tanam 6x3 meter. Pada kontur tanah dengan kemiringan lebih dari 10 derajat, pembuatan struktur terasering (lebar minimal 1,5 meter) dan rorak resapan air diwajibkan untuk membendung laju erosi top-soil.',
   true),
  ((select id from public.crops where slug = 'karet'), 'pemeliharaan',
   'Masa Tanaman Belum Menghasilkan (TBM) berlangsung kurang lebih 5 tahun, dengan kegiatan pemeliharaan terfokus pada penanaman tanaman penutup tanah kelompok legum (Legume Cover Crops/LCC) pada jalur gawangan, serta pengendalian gulma menggunakan herbisida kontak atau sistemik via knapsack sprayer.',
   true),
  ((select id from public.crops where slug = 'karet'), 'panen',
   'Pohon karet siap disadap ketika lingkar luar batang telah berdiameter minimal 45 sentimeter, diukur pada ketinggian 1 meter dari permukaan tanah. Penyadapan dilakukan harian pada pagi hari (pukul 05.00-06.00), dengan sudut sayatan 30-40 derajat dan kedalaman irisan menyisakan 1-1,5 mm dari lapisan kambium kayu agar regenerasi kulit dapat berlangsung tanpa merusak struktur hidrolik internal pohon.',
   true),
  ((select id from public.crops where slug = 'karet'), 'hama_penyakit',
   'Pengendalian hayati diutamakan: invasi kutu daun (aphids) diredam menggunakan agens hayati Beauveria bassiana (misalnya produk TOP BN), sementara penyakit jamur akar ditekan dengan inokulasi Glio (seperti MOSA GLIO) pada media kompos.',
   true);

-- --- Kelapa Sawit -------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'kelapa-sawit'), 'kondisi_ideal',
   'Siklus panen tandan buah segar (TBS) secara komersial baru dimulai pada kisaran umur 31 bulan pasca penanaman bibit di lapangan, membutuhkan ketersediaan lengas tanah yang tidak terputus pada fase pembentukan struktur batang primer.',
   true),
  ((select id from public.crops where slug = 'kelapa-sawit'), 'pemupukan',
   'Skema pemupukan berpusat pada aplikasi rutin pupuk majemuk NPK 15-15-15 untuk mempertahankan keseimbangan daun dan menekan absisi buah muda.',
   true);

-- --- Tebu -----------------------------------------------------------------
insert into public.crop_modules (crop_id, section, content, source_available) values
  ((select id from public.crops where slug = 'tebu'), 'persiapan_lahan',
   'Sebelum benih diletakkan, tanah galian harus dikeringkan secara termal oleh sinar matahari (diklantang) untuk menetralisir racun anorganik tanah dan memutus mata rantai hidup nematoda hama.',
   true),
  ((select id from public.crops where slug = 'tebu'), 'penanaman',
   'Penanaman stek batang tebu mengadopsi formasi tumpang tindih berkesinambungan (over lapping/end-to-end/nguntu walang) di dalam lubang berkedalaman 35 cm. Titik-titik mata tunas diletakkan secara menyamping, bukan menghadap ke atas, untuk memastikan keseragaman arah tunas anakan.',
   true),
  ((select id from public.crops where slug = 'tebu'), 'pemeliharaan',
   'Perawatan intensif mencakup prosedur pembubunan (hilling up), yaitu menimbun kembali tanah menutupi pangkal rumpun tebu secara progresif pada umur 2 dan 3 bulan, untuk memicu diferensiasi anakan sekunder dan melindungi batang agar tidak rebah (lodging) akibat angin kencang.',
   true),
  ((select id from public.crops where slug = 'tebu'), 'panen',
   'Keputusan waktu penebangan tidak didasarkan pada perkiraan visual, melainkan uji destruktif sampel batang secara periodik setiap dua minggu sekali (mulai tebu berumur 8 bulan) di laboratorium pabrik gula untuk menentukan titik kematangan rendemen sukrosa tertinggi. Batang tebu yang telah ditebang harus diangkut dan masuk ke mesin giling pabrik dalam waktu tidak lebih dari 36 jam, karena keterlambatan mengakibatkan konversi enzimatis sukrosa menjadi gula reduksi yang tidak bernilai.',
   true);

-- ============================================================================
-- 4. FARM TOOLS
-- ============================================================================
-- The source (Table 4) presents "Rice Miller" and "Polisher" as one
-- combined row, but Section 21 of the master prompt lists them as two
-- separate items. Split into two rows here; no facts were added, only
-- reorganized under the two names already used in the master prompt.
--
-- function/mechanism are both derived from splitting the source's single
-- "Prinsip Mekanika dan Fungsi Agronomis" paragraph per tool; description
-- keeps the fuller combined text for a tool's detail page. No new facts are
-- introduced by the split.

insert into public.farm_tools (slug, name, category, function, mechanism, description, related_module)
values
  ('hand-tractor', 'Traktor Tangan Dua Roda (Hand Tractor)', 'pra_panen',
   'Menarik implement pembajak berat untuk mengolah tanah sawah sempit yang tidak dapat diakses traktor roda empat, sekaligus meringankan beban fisik tenaga manusia.',
   'Ditenagai oleh motor bakar diesel kompak beroda dua, didesain untuk bermanuver lincah di lahan sawah sempit.',
   'Ditenagai oleh motor bakar diesel kompak beroda dua, didesain untuk bermanuver lincah di lahan sawah sempit yang tidak dapat diakses traktor roda empat. Fungsi utamanya adalah menarik implement pembajak berat (bajak piring/singkal), secara agresif membongkar kepadatan agregat tanah, dan meringankan beban fisik tenaga manusia.',
   'Modul Pengolahan Tanah'),

  ('rotavator', 'Rotavator (Rotary Tiller)', 'pra_panen',
   'Mencacah gumpalan bongkahan tanah besar, memotong serasah organik gulma menjadi ukuran mikro, dan menyempurnakan struktur porositas udara serta tata letak air di top-soil.',
   'Terpasang sebagai ekstensi daya pada gardan traktor, dengan poros transmisi yang memutar rangkaian bilah pisau melengkung (tines) pada kecepatan RPM tinggi.',
   'Terpasang sebagai ekstensi daya pada gardan traktor. Berbekal poros transmisi yang memutar rangkaian bilah pisau melengkung (tines) dalam kecepatan RPM tinggi, alat ini mengeksekusi operasi sekunder dengan cara mencacah gumpalan bongkahan tanah besar (clod), memotong serasah organik gulma menjadi ukuran mikro, dan menyempurnakan struktur porositas udara serta tata letak air di dalam zona top-soil.',
   'Modul Pengolahan Tanah'),

  ('garu-sisir', 'Garu Sisir (Tooth Harrow)', 'pra_panen',
   'Mengeliminasi sisa akar gulma yang masih menancap dan memastikan permukaan bedengan rata sebelum proses penanaman dieksekusi.',
   'Deretan gigi logam (tooth bar) berselang-seling yang ditarik menyusuri permukaan lumpur sawah atau tanah kering.',
   'Deretan gigi logam (tooth bar) berselang-seling yang ditarik menyusuri permukaan lumpur sawah atau tanah kering. Tujuannya adalah mengeliminasi sisa akar gulma bandel yang masih menancap dan memastikan permukaan bedengan rata ekuilibrium sebelum proses penanaman dieksekusi.',
   'Modul Penyiapan Bedengan'),

  ('seed-metering-planter', 'Alat Tanam Benih (Seed Metering Device / Planter)', 'penanaman',
   'Menyederhanakan siklus penanaman jagung atau padi menjadi satu gerakan translasi maju.',
   'Putaran poros roda menggerakkan piringan distributor benih (seed metering device) di dasar hopper, yang secara simultan mengebor lubang ke tanah, menjatuhkan jumlah kalibrasi butiran benih secara eksak, dan menutup kembali lubang tersebut.',
   'Alat mekanis presisi tinggi yang menyederhanakan siklus penanaman jagung atau padi menjadi satu gerakan translasi maju. Putaran poros roda menggerakkan piringan distributor benih (seed metering device) di dasar hopper. Alat ini secara simultan mengebor lubang ke dalam tanah, menjatuhkan jumlah kalibrasi butiran benih secara eksak, dan menutup kembali lubang tersebut. Inovasi mutakhir mengadopsi saluran kembar yang memisahkan jatuhnya benih dengan letak jatuhnya pupuk starter.',
   'Modul Penanaman Sentral'),

  ('pompa-air-hidrolik', 'Pompa Air Hidrolik', 'perawatan',
   'Menyedot debit air dari sumur bor atau kanal irigasi primer menuju lahan sawah yang berposisi lebih tinggi; krusial mencegah layu permanen padi di Musim Tanam Gadu (MT2 dan MT3).',
   'Menggunakan prinsip konversi daya mekanis menjadi energi tekan kinetik.',
   'Menggunakan prinsip konversi daya mekanis menjadi energi tekan kinetik untuk menyedot volume debit fluida air dari elevasi sumur bor atau kanal irigasi primer menuju ke area lahan sawah yang berposisi lebih tinggi. Sangat krusial untuk mencegah layu permanen padi di Musim Tanam Gadu (MT2 dan MT3).',
   'Modul Irigasi & Tata Air'),

  ('hand-sprayer', 'Hand Sprayer Kinetik', 'perawatan',
   'Menyemprotkan pestisida kimia sintetik atau pupuk biologi cair hingga merekat di area stomata daun tanaman.',
   'Petani secara mekanis memompa tuas udara untuk mengakumulasikan tekanan statis di dalam ruang kompresi tangki; katup pegas pada nosel ujung melepaskan tekanan tersebut dan memecah cairan menjadi partikel kabut halus berskala mikron (droplets).',
   'Instrumen penampung fluida pestisida berbahan kimia sintetik atau pupuk biologi. Petani secara mekanis memompa tuas udara untuk mengakumulasikan energi tekanan statis absolut di dalam ruang kompresi tangki. Katup pegas pada nosel ujung melepaskan tekanan tersebut dan memecah cairan menjadi partikel kabut halus berskala mikron (droplets) yang merekat sempurna di area stomata daun tanaman.',
   'Modul Proteksi Hama'),

  ('combine-harvester', 'Combine Harvester', 'pemanenan',
   'Mengurangi kehilangan bulir tercecer di lumpur (shattering loss) yang biasa terjadi pada panen manual dengan sabit.',
   'Merangkum tiga aktivitas secara simultan dalam satu pass: memotong rumpun batang padi, merontokkan bulir dari malainya, lalu memisahkan sekam kosong/kotoran ringan; beroperasi di sawah berlumpur dengan roda sabuk crawler.',
   'Monster mekanis pasca-panen yang merangkum tiga aktivitas padat karya secara simultan dalam satu pass: pisau cutter bar mendatar memotong rumpun batang padi, poros drum silinder beralur (thresher) merontokkan bulir padi (gabah) secara kasar dari malainya, dan sistem kipas hisap (blower) memisahkan sekam kosong/kotoran ringan. Alat ini beroperasi stabil di sawah berlumpur parah menggunakan roda sabuk crawler, mengurangi kehilangan bulir tercecer di lumpur (shattering loss) yang biasa terjadi pada panen buruh sabit.',
   'Modul Pemanenan Serealia'),

  ('reaper', 'Mesin Pemotong Padi Ringan (Reaper)', 'pemanenan',
   'Alternatif investasi rendah bagi petani bermodal kecil untuk memotong batang tanaman secara cepat sebelum dirontokkan terpisah.',
   'Beroperasi murni untuk memotong batang bawah tanaman gandum atau padi dengan kecepatan tinggi, membiarkan malai utuh tergeletak dalam barisan rapi (windrow).',
   'Alternatif investasi rendah bagi petani bermodal kecil. Mesin beroperasi murni untuk melakukan pemotongan batang bawah tanaman gandum atau padi dengan kecepatan tinggi, membiarkan malai utuh tergeletak dalam barisan rapi (windrow) untuk dipungut dan dirontokkan secara terpisah di luar area sawah.',
   'Modul Panen Skala Mikro'),

  ('thresher', 'Thresher (Mesin Pemipil)', 'pasca_panen',
   'Memisahkan biji bernilai ekonomis (gabah, kedelai, atau jagung) dari matriks struktural tangkai bonggolnya.',
   'Generator rotasi silinder bertabur gerigi baja tumpul untuk operasi statis; petani menyuapkan untaian malai atau bonggol, dan gesekan berkecepatan tinggi merontokkan serta memisahkan bijinya.',
   'Generator rotasi silinder bertabur gerigi baja tumpul, dikhususkan untuk operasi statis. Petani menyuapkan untaian malai atau bonggol, dan gesekan berkecepatan tinggi merontokkan dan memisahkan biji bernilai ekonomis tinggi (gabah, kedelai, atau jagung) dari matriks struktural tangkai bonggolnya.',
   'Modul Pemrosesan Bulir'),

  ('solar-dryer-dome', 'Solar Dryer Dome (Kubah Surya)', 'pasca_panen',
   'Mengakselerasi evaporasi kadar air pada produk gabah, kakao, kopi, atau rempah tanpa terhambat hujan mendadak, sekaligus menjaga produk steril dari kontaminasi serangga atau kotoran hewan.',
   'Infrastruktur berbentuk kubah setengah lingkaran berlapis polikarbonat transparan yang menjebak radiasi termal ultraviolet matahari (efek rumah kaca), dibantu kipas ekstraktor ventilasi untuk menjaga sirkulasi suhu.',
   'Infrastruktur hibrida berbentuk kubah setengah lingkaran berlapis polikarbonat transparan yang menjebak radiasi termal ultraviolet matahari (efek rumah kaca). Kipas ekstraktor ventilasi menjaga sirkulasi termodinamika suhu di dalam struktur kubah, sehingga mampu mengakselerasi tingkat evaporasi kadar air pada produk gabah, kakao, kopi, atau rempah tanpa ancaman terhambat hujan mendadak, serta menjaga produk steril dari kontaminasi vektor serangga lalat buah atau kotoran avifauna.',
   'Modul Pengeringan Biologis'),

  ('rice-miller', 'Mesin Penggiling (Rice Miller)', 'pasca_panen',
   'Tahap pertama pemrosesan gabah menuju beras siap konsumsi, sebelum diproses lanjut oleh mesin Polisher.',
   'Memecahkan cangkang keras (hulling) sekam cokelat gabah menjadi beras pecah kulit.',
   'Pemrosesan awal dari gabah menuju meja makan: mesin ini memecahkan cangkang keras (hulling) sekam cokelat gabah, menghasilkan beras pecah kulit yang kemudian diinjeksikan ke mesin pemoles (Polisher).',
   'Modul Peningkatan Nilai Tambah'),

  ('polisher', 'Polisher (Mesin Pemoles Beras)', 'pasca_panen',
   'Mengubah butir beras pecah kulit yang buram menjadi kristal putih bersih mengkilap sesuai standar kualitas medium atau premium.',
   'Beras pecah kulit hasil Rice Miller diinjeksikan ke mesin pemoles gesekan bertemperatur terkontrol, yang mengikis lapisan epidermis bekatul tipis (aleuron).',
   'Beras pecah kulit yang dihasilkan Rice Miller diinjeksikan ke mesin pemoles gesekan (Polisher) bertemperatur terkontrol, yang mengikis lapisan epidermis bekatul tipis (aleuron), mengubah butir buram menjadi kristal putih bersih mengkilap yang memenuhi standar kualifikasi beras kualitas medium atau premium berharga komersial tinggi di supermarket.',
   'Modul Peningkatan Nilai Tambah')
on conflict (slug) do update set
  name = excluded.name,
  category = excluded.category,
  function = excluded.function,
  mechanism = excluded.mechanism,
  description = excluded.description,
  related_module = excluded.related_module;
