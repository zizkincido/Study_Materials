CREATE OR REPLACE VIEW vw_departman_maas_dagilimi AS
SELECT
    d."departman_adı",
    percentile_cont(0.25) WITHIN GROUP (ORDER BY c."maaş") AS q1,
    percentile_cont(0.50) WITHIN GROUP (ORDER BY c."maaş") AS median,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY c."maaş") AS q3,
    MIN(c."maaş") AS min_maas,
    MAX(c."maaş") AS max_maas,
    COUNT(*) AS calisan_sayisi
FROM "Çalışanlar" c
JOIN "Departmanlar" d ON d."departman_id" = c."departman_id"
WHERE c."işten_ayrılış_tarihi" IS NULL
GROUP BY d."departman_adı";
CREATE OR REPLACE VIEW vw_departman_maaliyet AS
SELECT
    d."departman_adı",
    SUM(c."maaş") AS toplam_maas
FROM "Çalışanlar" c
JOIN "Departmanlar" d ON d."departman_id" = c."departman_id"
WHERE c."işten_ayrılış_tarihi" IS NULL
GROUP BY d."departman_adı";
CREATE OR REPLACE VIEW vw_calisan_sirkulasyon AS
SELECT
    tarih,
    SUM(ise_giren) AS ise_giren,
    SUM(isten_ayrilan) AS isten_ayrilan
FROM (
    SELECT
        date_trunc('month', "işe_giriş_tarihi") AS tarih,
        1 AS ise_giren,
        0 AS isten_ayrilan
    FROM "Çalışanlar"

    UNION ALL

    SELECT
        date_trunc('month', "işten_ayrılış_tarihi") AS tarih,
        0,
        1
    FROM "Çalışanlar"
    WHERE "işten_ayrılış_tarihi" IS NOT NULL
) t
GROUP BY tarih;
CREATE OR REPLACE VIEW vw_kidem_analizi AS
SELECT
    c."çalışan_id",
    d."departman_adı",
    EXTRACT(YEAR FROM AGE(COALESCE(c."işten_ayrılış_tarihi", CURRENT_DATE),
                          c."işe_giriş_tarihi")) AS kidem_yil,
    c."maaş"
FROM "Çalışanlar" c
JOIN "Departmanlar" d ON d."departman_id" = c."departman_id";
CREATE OR REPLACE VIEW vw_izin_kullanimi AS
SELECT
    d."departman_adı",
    i."izin_türü",
    COUNT(*) AS izin_sayisi,
    SUM(i."bitiş" - i."başlangıç" + 1) AS toplam_izin_gunu
FROM "İzinler" i
JOIN "Çalışanlar" c ON c."çalışan_id" = i."çalışan_id"
JOIN "Departmanlar" d ON d."departman_id" = c."departman_id"
WHERE i."onay_durumu" = TRUE
GROUP BY d."departman_adı", i."izin_türü";
