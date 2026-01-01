CREATE TABLE "Çalışanlar"(
    "çalışan_id" bigserial PRIMARY KEY,
    "ad" VARCHAR(255) NOT NULL,
    "soyad" VARCHAR(255) NOT NULL,
    "departman_id" BIGINT NOT NULL,
    "pozisyon" VARCHAR(255) NOT NULL,
    "işe_giriş_tarihi" DATE NOT NULL,
    "işten_ayrılış_tarihi" DATE,
    "maaş" BIGINT NOT NULL
);
CREATE TABLE "Departmanlar"(
    "departman_id" bigserial PRIMARY KEY,
    "departman_adı" VARCHAR(255) NOT NULL,
    "yönetici_id" BIGINT,
    "lokasyon" CHAR(255) NOT NULL,
    "bütçe" BIGINT NOT NULL
);
CREATE TABLE "Bordro"(
    "bordro_id" bigserial PRIMARY KEY,
    "çalışan_id" BIGINT NOT NULL,
    "ay" SMALLINT NOT NULL,
    "yıl" SMALLINT NOT NULL,
    "net_maaş" BIGINT NOT NULL,
    "prim" BIGINT NOT NULL,
    "kesinti" BIGINT NOT NULL
);
CREATE TABLE "İzinler"(
    "izin_id" bigserial PRIMARY KEY,
    "çalışan_id" BIGINT NOT NULL,
    "izin_türü" VARCHAR(255) NOT NULL,
    "başlangıç" DATE NOT NULL,
    "bitiş" DATE NOT NULL,
    "onay_durumu" BOOLEAN NOT NULL
);

ALTER TABLE
    "İzinler" ADD CONSTRAINT "İzinler_çalışan_id_foreign" FOREIGN KEY("çalışan_id") REFERENCES "Çalışanlar"("çalışan_id");
ALTER TABLE
    "Çalışanlar" ADD CONSTRAINT "Çalışanlar_departman_id_foreign" FOREIGN KEY("departman_id") REFERENCES "Departmanlar"("departman_id");
ALTER TABLE
    "Bordro" ADD CONSTRAINT "bordro_çalışan_id_foreign" FOREIGN KEY("çalışan_id") REFERENCES "Çalışanlar"("çalışan_id");
ALTER TABLE 
	"Departmanlar" ADD CONSTRAINT "Departmanlar_yönetici_id_foreign" FOREIGN KEY ("yönetici_id") REFERENCES "Çalışanlar"("çalışan_id");
