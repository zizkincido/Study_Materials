-- 1. Departmanları oluştur
INSERT INTO "Departmanlar" ("departman_adı", "lokasyon", "bütçe")
VALUES
    ('Bilgi Teknolojileri', 'İstanbul', 4500000),
    ('İnsan Kaynakları', 'Ankara', 2100000),
    ('Finans', 'İstanbul', 5800000),
    ('Satış', 'İzmir', 3200000),
    ('Pazarlama', 'İstanbul', 2900000),
    ('Operasyon', 'Bursa', 3700000),
    ('Ar-Ge', 'Kocaeli', 4100000),
    ('Müşteri Hizmetleri', 'Antalya', 1800000),
    ('Üretim', 'Kayseri', 5200000),
    ('Lojistik', 'İzmir', 2600000);

-- 2. 500 çalışan oluştur (tüm departmanlara rastgele dağıtılmış)
INSERT INTO "Çalışanlar" (
    "ad", "soyad", "departman_id", "pozisyon",
    "işe_giriş_tarihi", "işten_ayrılış_tarihi", "maaş"
)
SELECT
    (ARRAY['Ahmet', 'Mehmet', 'Ayşe', 'Fatma', 'Ali', 'Zeynep', 'Mustafa', 'Emine', 'Can', 'Elif',
           'Burak', 'Selin', 'Emre', 'Derya', 'Kemal', 'Merve', 'Cem', 'Deniz', 'Onur', 'Pınar'])[1 + floor(random() * 20)],
    (ARRAY['Yılmaz', 'Kaya', 'Demir', 'Çelik', 'Şahin', 'Arslan', 'Öztürk', 'Aydın', 'Özdemir', 'Koç',
           'Yıldız', 'Yıldırım', 'Çetin', 'Erdoğan', 'Aksoy', 'Polat', 'Karaca', 'Bulut', 'Şen', 'Acar'])[1 + floor(random() * 20)],
    dept_ids[1 + floor(random() * array_length(dept_ids, 1))],
    (ARRAY['Junior Uzman', 'Uzman', 'Kıdemli Uzman', 'Takım Lideri', 'Müdür Yardımcısı', 'Müdür'])[1 + floor(random() * 6)],
    DATE '2015-01-01' + (floor(random() * 3650))::INT,
    CASE 
        WHEN random() < 0.15 THEN DATE '2020-01-01' + (floor(random() * 1825))::INT
        ELSE NULL 
    END,
    CASE 
        WHEN random() < 0.20 THEN 18000 + floor(random() * 12000)
        WHEN random() < 0.50 THEN 30000 + floor(random() * 20000)
        WHEN random() < 0.80 THEN 50000 + floor(random() * 30000)
        ELSE 80000 + floor(random() * 70000)
    END
FROM generate_series(1, 500) g
CROSS JOIN (
    SELECT array_agg(departman_id) AS dept_ids FROM "Departmanlar"
) d;

-- 3. Her departmana bir yönetici ata (aktif çalışanlardan)
UPDATE "Departmanlar" d
SET "yönetici_id" = (
    SELECT c."çalışan_id"
    FROM "Çalışanlar" c
    WHERE c."departman_id" = d."departman_id"
      AND c."işten_ayrılış_tarihi" IS NULL
      AND c."maaş" >= 50000
    ORDER BY random()
    LIMIT 1
);

-- 4. 2024 yılı bordro kayıtları (tüm aylar)
INSERT INTO "Bordro" (
    "çalışan_id",
    "ay",
    "yıl",
    "net_maaş",
    "prim",
    "kesinti"
)
SELECT
    c."çalışan_id",
    m,
    2024,
    GREATEST(c."maaş" - (1000 + floor(random() * 3000))::BIGINT, 15000),
    CASE 
        WHEN random() < 0.3 THEN floor(random() * 8000)::BIGINT
        ELSE 0
    END,
    (500 + floor(random() * 2500))::BIGINT
FROM "Çalışanlar" c
CROSS JOIN generate_series(1, 12) m
WHERE c."işten_ayrılış_tarihi" IS NULL 
   OR c."işten_ayrılış_tarihi" >= DATE '2024-01-01';

-- 5. 2023 yılı bordro kayıtları (sadece o dönem aktif olanlar)
INSERT INTO "Bordro" (
    "çalışan_id",
    "ay",
    "yıl",
    "net_maaş",
    "prim",
    "kesinti"
)
SELECT
    c."çalışan_id",
    m,
    2023,
    GREATEST(c."maaş" - (1000 + floor(random() * 3000))::BIGINT, 15000),
    CASE 
        WHEN random() < 0.25 THEN floor(random() * 7000)::BIGINT
        ELSE 0
    END,
    (500 + floor(random() * 2000))::BIGINT
FROM "Çalışanlar" c
CROSS JOIN generate_series(1, 12) m
WHERE c."işe_giriş_tarihi" <= DATE '2023-12-31'
  AND (c."işten_ayrılış_tarihi" IS NULL OR c."işten_ayrılış_tarihi" >= DATE '2023-01-01');

-- 6. İzin kayıtları (her çalışan için 1-4 izin)
INSERT INTO "İzinler" (
    "çalışan_id",
    "izin_türü",
    "başlangıç",
    "bitiş",
    "onay_durumu"
)
SELECT
    c."çalışan_id",
    (ARRAY['Yıllık İzin', 'Hastalık İzni', 'Mazeret İzni', 'Ücretsiz İzin'])[1 + floor(random() * 4)],
    izin_baslangic,
    izin_baslangic + (1 + floor(random() * 14))::INT,
    random() > 0.15
FROM "Çalışanlar" c
CROSS JOIN LATERAL (
    SELECT
        DATE '2024-01-01' + (floor(random() * 365))::INT AS izin_baslangic
    FROM generate_series(1, 1 + floor(random() * 3)::INT)
) t
WHERE c."işten_ayrılış_tarihi" IS NULL;

-- Veri istatistikleri
SELECT 'Toplam Departman' AS Metrik, COUNT(*)::TEXT AS Değer FROM "Departmanlar"
UNION ALL
SELECT 'Toplam Çalışan', COUNT(*)::TEXT FROM "Çalışanlar"
UNION ALL
SELECT 'Aktif Çalışan', COUNT(*)::TEXT FROM "Çalışanlar" WHERE "işten_ayrılış_tarihi" IS NULL
UNION ALL
SELECT 'Ayrılmış Çalışan', COUNT(*)::TEXT FROM "Çalışanlar" WHERE "işten_ayrılış_tarihi" IS NOT NULL
UNION ALL
SELECT 'Toplam Bordro Kaydı', COUNT(*)::TEXT FROM "Bordro"
UNION ALL
SELECT 'Toplam İzin Kaydı', COUNT(*)::TEXT FROM "İzinler"
ORDER BY Metrik;