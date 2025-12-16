/* 
		BÖLÜM 1: 
Tablo oluşturma ve ilişki tanımlama.
*/
CREATE TABLE "developers"(
    "id" bigserial PRIMARY KEY,
    "company_name" VARCHAR(255) NOT NULL,
    "country" VARCHAR(255) NOT NULL,
    "founded_year" SMALLINT NOT NULL
);
CREATE TABLE "games"(
    "id" bigserial PRIMARY KEY,
    "title" VARCHAR(255) NOT NULL,
    "price" NUMERIC(6,2) NOT NULL,
    "release_date" DATE NOT NULL,
    "rating" NUMERIC(3,1) NOT NULL,
    "developer_id" BIGINT NOT NULL
);
CREATE TABLE "genres"(
    "id" bigserial PRIMARY KEY,
    "name" VARCHAR(255) NOT NULL,
    "description" VARCHAR(255)
);
CREATE TABLE "games_genres"(
    "id" bigserial PRIMARY KEY,
    "game_id" BIGINT NOT NULL,
    "genre_id" BIGINT NOT NULL,
	CONSTRAINT games_genres_unique UNIQUE (game_id, genre_id),
    CONSTRAINT fk_game
        FOREIGN KEY (game_id)
        REFERENCES games(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_genre
        FOREIGN KEY (genre_id)
        REFERENCES genres(id)
        ON DELETE CASCADE
);
ALTER TABLE
    "games" ADD CONSTRAINT "games_developer_id_foreign" FOREIGN KEY("developer_id") REFERENCES "developers"("id");
/*
			BÖLÜM 2:
Veri ekleme. 5 adet geliştirici, 5 adet tür, 10 adet oyun, oyun tür eşleştirmesi.
*/
INSERT INTO developers (company_name, country, founded_year) -- Çözüm 2.1
VALUES 
('CD Project Red', 'Poland', 2002),
('Bethesda Softworks', 'USA', 1986),
('Rockstar Games', 'USA', 1998),
('Larian Studios', 'Belgium', 1996),
('Valve', 'USA', 1996);

INSERT INTO genres (name) -- Çözüm 2.2
VALUES
('Action'),
('RPG'),
('Open World'),
('Fantasy'),
('FPS'),
('MMORPG');

INSERT INTO games (title, price, release_date, rating, developer_id) -- Çözüm 2.3
VALUES
('Cyberpunk 2077', 1800.00, '2020-10-12', 8.6, 1),
('The Witcher 3: Wild Hunt', 1200.00, '2015-05-18', 9.5, 1),
('The Elder Scrolls V: Skyrim', 480.00, '2011-11-11', 10.0, 2),
('Fallout: New Vegas', 240.00, '2010-10-22', 9.6, 2),
('Red Dead Redemption 2', 4000.00, '2019-12-05', 9.8, 3),
('L.A. Noire', 800.00, '2011-11-08', 8.2, 3),
('Baldurs Gate 3', 1400.00, '2023-08-03', 10.0, 4),
('Divinity: Original Sin 2', 1040.00, '2017-09-14', 10.0, 4),
('Counter-Strike 2', 600.00, '2012-08-21', 7.2, 5),
('Half-Life 2', 403.20, '2007-10-10', 8.5, 5);

INSERT INTO games_genres (game_id, genre_id) -- Çözüm 2.4
VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), (2, 3),
(3, 2), (3, 3), (3, 4),
(4, 1), (4, 2), (4, 4), (4, 5),
(5, 1), (5, 2), (5, 3),
(6, 1), (6, 2),
(7, 1), (7, 2), (7, 3), (7, 4),
(8, 1), (8, 2), (8, 3), (8, 4),
(9, 1), (9, 5),
(10, 1), (10, 5);
/*
		BÖLÜM 3:
Güncelleme ve silme işlemleri; indirim zamanı, hata düzeltme ve kaldırma.
*/
UPDATE games SET price -= (price / 10); -- Çözüm 3.1
UPDATE games SET rating = 9.0 WHERE title = 'Half-Life 2'; -- Çözüm 3.2
DELETE FROM games WHERE title='Half-Life 2'; -- Çözüm 3.3
/*
		BÖLÜM 4:
Raporlama; tüm oyunlar listesi, kategori filtresi, fiyat analizi, arama.
*/
SELECT games.title, games.price, developers.company_name -- Çözüm 4.1
FROM games
INNER JOIN developers ON games.developer_id = developers.id;

SELECT games.title, games.rating, genres.name -- Çözüm 4.2
FROM games
JOIN games_genres ON games.id = games_genres.game_id 
JOIN genres ON genres.id = games_genres.genre_id;

SELECT * -- Çözüm 4.3
FROM games
WHERE games.price > 500
ORDER BY games.price DESC;

SELECT * -- Çözüm 4.4
FROM games
WHERE games.title LIKE '%War%'