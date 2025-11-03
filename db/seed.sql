-- ====================================================
-- SEED DE CATÁLOGO DE CONTENIDOS – PLATAFORMA STREAMING
-- Películas y series populares (2022–2024)
-- ====================================================

-- =============================
-- GÉNEROS
-- =============================
INSERT INTO genres (name, slug) VALUES
('Acción', 'accion'),
('Aventura', 'aventura'),
('Ciencia Ficción', 'ciencia-ficcion'),
('Comedia', 'comedia'),
('Drama', 'drama'),
('Romance', 'romance'),
('Terror', 'terror'),
('Suspenso', 'suspenso'),
('Animación', 'animacion'),
('Fantasía', 'fantasia');

-- =============================
-- PELÍCULAS POPULARES
-- =============================
INSERT INTO contents (type, title, original_title, synopsis, release_date, runtime_minutes, year, rating_avg, rating_count, language_primary, maturity_rating, created_at, updated_at)
VALUES
('movie','Oppenheimer','Oppenheimer','La historia del físico J. Robert Oppenheimer y el desarrollo de la bomba atómica.', '2023-07-21', 180, 2023, 0, 0, 'en', 'R', NOW(), NOW()),
('movie','Barbie','Barbie','Una muñeca que vive en Barbieland es expulsada al mundo real.', '2023-07-21', 114, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Dune: Parte Dos','Dune: Part Two','Paul Atreides busca venganza contra los conspiradores que destruyeron su familia.', '2024-03-01', 166, 2024, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','The Batman','The Batman','Batman descubre la corrupción en Ciudad Gótica mientras enfrenta al Acertijo.', '2022-03-04', 176, 2022, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Avatar: The Way of Water','Avatar: The Way of Water','Jake Sully vive con su familia en Pandora y enfrenta una nueva amenaza humana.', '2022-12-16', 192, 2022, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Guardians of the Galaxy Vol. 3','Guardians of the Galaxy Vol. 3','Los Guardianes deben proteger a Rocket mientras enfrentan a su pasado.', '2023-05-05', 150, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','John Wick: Chapter 4','John Wick: Chapter 4','John Wick busca derrotar a la Alta Mesa y ganar su libertad.', '2023-03-24', 169, 2023, 0, 0, 'en', 'R', NOW(), NOW()),
('movie','The Marvels','The Marvels','Carol Danvers une fuerzas con Kamala Khan y Monica Rambeau para salvar el universo.', '2023-11-10', 105, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Spider-Man: Across the Spider-Verse','Spider-Man: Across the Spider-Verse','Miles Morales viaja a través del multiverso junto a Gwen Stacy.', '2023-06-02', 140, 2023, 0, 0, 'en', 'PG', NOW(), NOW()),
('movie','Wonka','Wonka','La historia de origen de Willy Wonka, el excéntrico chocolatero.', '2023-12-15', 116, 2023, 0, 0, 'en', 'PG', NOW(), NOW()),
('movie','Inside Out 2','Inside Out 2','Riley enfrenta nuevas emociones mientras entra en la adolescencia.', '2024-06-14', 100, 2024, 0, 0, 'en', 'PG', NOW(), NOW()),
('movie','The Super Mario Bros. Movie','The Super Mario Bros. Movie','Mario viaja a un reino mágico para rescatar a su hermano Luigi.', '2023-04-05', 92, 2023, 0, 0, 'en', 'PG', NOW(), NOW()),
('movie','The Flash','The Flash','Barry Allen altera el tiempo para salvar a su madre, creando un nuevo universo.', '2023-06-16', 144, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Mission: Impossible – Dead Reckoning Part One','Mission: Impossible – Dead Reckoning Part One','Ethan Hunt enfrenta una nueva amenaza que podría destruir el mundo.', '2023-07-12', 163, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Fast X','Fast X','Dom Toretto y su familia enfrentan a un enemigo del pasado.', '2023-05-19', 141, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Godzilla x Kong: The New Empire','Godzilla x Kong: The New Empire','Los titanes se unen para enfrentar una amenaza ancestral.', '2024-03-29', 115, 2024, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','The Hunger Games: The Ballad of Songbirds & Snakes','The Hunger Games: The Ballad of Songbirds & Snakes','Precuela que narra el origen del presidente Snow.', '2023-11-17', 157, 2023, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Black Panther: Wakanda Forever','Black Panther: Wakanda Forever','La nación de Wakanda lucha por protegerse tras la muerte de su rey.', '2022-11-11', 161, 2022, 0, 0, 'en', 'PG-13', NOW(), NOW()),
('movie','Nope','Nope','Dos hermanos intentan capturar evidencia de un fenómeno extraterrestre.', '2022-07-22', 130, 2022, 0, 0, 'en', 'R', NOW(), NOW()),
('movie','The Whale','The Whale','Un profesor obeso intenta reconectarse con su hija.', '2022-12-09', 117, 2022, 0, 0, 'en', 'R', NOW(), NOW());

-- =============================
-- SERIES POPULARES
-- =============================
INSERT INTO contents (type, title, original_title, synopsis, release_date, runtime_minutes, year, rating_avg, rating_count, language_primary, maturity_rating, created_at, updated_at)
VALUES
('series','The Last of Us','The Last of Us','Joel y Ellie atraviesan un EE.UU. postapocalíptico infestado por hongos.', '2023-01-15', NULL, 2023, 0, 0, 'en', 'TV-MA', NOW(), NOW()),
('series','Wednesday','Wednesday','La hija de la familia Addams asiste a la Academia Nevermore.', '2022-11-23', NULL, 2022, 0, 0, 'en', 'TV-14', NOW(), NOW()),
('series','Stranger Things','Stranger Things','Un grupo de niños enfrenta amenazas sobrenaturales en Hawkins.', '2016-07-15', NULL, 2016, 0, 0, 'en', 'TV-14', NOW(), NOW()),
('series','House of the Dragon','House of the Dragon','La guerra civil de los Targaryen por el Trono de Hierro.', '2022-08-21', NULL, 2022, 0, 0, 'en', 'TV-MA', NOW(), NOW()),
('series','Squid Game','Squid Game','Personas con deudas compiten en juegos mortales por dinero.', '2021-09-17', NULL, 2021, 0, 0, 'ko', 'TV-MA', NOW(), NOW()),
('series','The Boys','The Boys','Un grupo de vigilantes lucha contra superhéroes corruptos.', '2019-07-26', NULL, 2019, 0, 0, 'en', 'TV-MA', NOW(), NOW()),
('series','Loki','Loki','El dios del engaño altera las líneas del tiempo tras robar el Teseracto.', '2021-06-09', NULL, 2021, 0, 0, 'en', 'TV-14', NOW(), NOW()),
('series','One Piece','One Piece','Adaptación live action del famoso manga sobre piratas.', '2023-08-31', NULL, 2023, 0, 0, 'en', 'TV-14', NOW(), NOW()),
('series','The Mandalorian','The Mandalorian','Un cazarrecompensas viaja por la galaxia junto a Grogu.', '2019-11-12', NULL, 2019, 0, 0, 'en', 'TV-14', NOW(), NOW()),
('series','Bridgerton','Bridgerton','Familia noble londinense enfrenta el amor y el escándalo.', '2020-12-25', NULL, 2020, 0, 0, 'en', 'TV-MA', NOW(), NOW()),
('series','Fallout','Fallout','Sobrevivientes del apocalipsis nuclear en un mundo retrofuturista.', '2024-04-10', NULL, 2024, 0, 0, 'en', 'TV-MA', NOW(), NOW());

-- =============================
-- RELACIÓN CONTENIDO-GÉNERO
-- =============================
INSERT INTO content_genres (content_id, genre_id) VALUES
(1,3),(1,5),
(2,4),(2,6),
(3,1),(3,3),
(4,1),(4,8),
(5,2),(5,10),
(6,1),(6,4),
(7,1),(7,8),
(8,1),(8,3),
(9,9),(9,2),
(10,9),(10,4),
(11,9),(11,6),
(12,9),(12,2),
(13,1),(13,3),
(14,1),(14,8),
(15,1),(15,2),
(16,1),(16,3),
(17,1),(17,5),
(18,5),(18,6),
(19,7),(19,8),
(20,5),(20,3),
(21,3),(21,8),
(22,4),(22,5),
(23,10),(23,8),
(24,10),(24,5),
(25,5),(25,8),
(26,1),(26,3),
(27,3),(27,8),
(28,2),(28,10),
(29,1),(29,10),
(30,6),(30,5),
(31,3),(31,1);

-- =============================
-- FIN DEL SEED DE CATÁLOGO
-- =============================
