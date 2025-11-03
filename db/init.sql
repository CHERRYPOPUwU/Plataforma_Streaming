-- db/init.sql
-- Ejecuta este archivo con: psql -U postgres -d streaming_platform -f db/init.sql

-- *********************
-- TABLAS (mismo esquema limpio)
-- *********************

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- accounts
CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    locale VARCHAR(10),
    role VARCHAR(50) DEFAULT 'user'
);

-- profiles
CREATE TABLE IF NOT EXISTS profiles (
    id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    birthdate DATE,
    is_kids BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- parental_controls
CREATE TABLE IF NOT EXISTS parental_controls (
    id SERIAL PRIMARY KEY,
    profile_id INT REFERENCES profiles(id) ON DELETE CASCADE,
    max_rating VARCHAR(10),
    blocked_genre_ids INT[],
    blocked_content INT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- plans
CREATE TABLE IF NOT EXISTS plans (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price_cents INT NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    max_streams INT DEFAULT 1,
    resolution_limit VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);

-- subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
    id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(id) ON DELETE CASCADE,
    plan_id INT REFERENCES plans(id),
    status VARCHAR(50) DEFAULT 'active',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    canceled_at TIMESTAMP
);

-- payments
CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(id) ON DELETE CASCADE,
    subscription_id INT REFERENCES subscriptions(id) ON DELETE SET NULL,
    amount_cents INT NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'pending',
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- contents
CREATE TABLE IF NOT EXISTS contents (
    id SERIAL PRIMARY KEY,
    type VARCHAR(50) CHECK (type IN ('movie', 'series', 'episode', 'documentary')),
    title VARCHAR(255) NOT NULL,
    original_title VARCHAR(255),
    synopsis TEXT,
    release_date DATE,
    runtime_minutes INT,
    year INT,
    rating_avg NUMERIC(3,2) DEFAULT 0,
    rating_count INT DEFAULT 0,
    language_primary VARCHAR(10),
    maturity_rating VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- series
CREATE TABLE IF NOT EXISTS series (
    id INT PRIMARY KEY REFERENCES contents(id) ON DELETE CASCADE,
    total_seasons INT DEFAULT 0,
    total_episodes INT DEFAULT 0,
    showrunner VARCHAR(255)
);

-- seasons
CREATE TABLE IF NOT EXISTS seasons (
    id SERIAL PRIMARY KEY,
    series_id INT REFERENCES series(id) ON DELETE CASCADE,
    season_number INT NOT NULL,
    title VARCHAR(255),
    overview TEXT,
    release_date DATE
);

-- episodes
CREATE TABLE IF NOT EXISTS episodes (
    id SERIAL PRIMARY KEY,
    content_id INT REFERENCES contents(id) ON DELETE CASCADE,
    season_id INT REFERENCES seasons(id) ON DELETE CASCADE,
    episode_number INT NOT NULL,
    title VARCHAR(255),
    synopsis TEXT,
    runtime_minutes INT,
    released_at DATE
);

-- genres
CREATE TABLE IF NOT EXISTS genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL
);

-- content_genres
CREATE TABLE IF NOT EXISTS content_genres (
    content_id INT REFERENCES contents(id) ON DELETE CASCADE,
    genre_id INT REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (content_id, genre_id)
);

-- actor
CREATE TABLE IF NOT EXISTS actor (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    birthdate DATE,
    bio TEXT
);

-- watchlists
CREATE TABLE IF NOT EXISTS watchlists (
    id SERIAL PRIMARY KEY,
    profile_id INT REFERENCES profiles(id) ON DELETE CASCADE,
    content_id INT REFERENCES contents(id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(profile_id, content_id)
);

-- watch_history
CREATE TABLE IF NOT EXISTS watch_history (
    id SERIAL PRIMARY KEY,
    profile_id INT REFERENCES profiles(id) ON DELETE CASCADE,
    content_id INT REFERENCES contents(id) ON DELETE CASCADE,
    episode_id INT REFERENCES episodes(id) ON DELETE SET NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_position_seconds INT DEFAULT 0,
    finished BOOLEAN DEFAULT FALSE,
    finished_at TIMESTAMP
);

-- ratings
CREATE TABLE IF NOT EXISTS ratings (
    id SERIAL PRIMARY KEY,
    profile_id INT REFERENCES profiles(id) ON DELETE CASCADE,
    content_id INT REFERENCES contents(id) ON DELETE CASCADE,
    score INT CHECK (score BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- recommendations
CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    profile_id INT REFERENCES profiles(id) ON DELETE CASCADE,
    content_id INT REFERENCES contents(id) ON DELETE CASCADE,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- *********************
-- PROCEDIMIENTOS ALMACENADOS (RETORNAN JSON)
-- *********************

/*
1) get_content_by_id_json(content_id) -> devuelve información completa de un contenido en JSON
*/
CREATE OR REPLACE FUNCTION get_content_by_id_json(cid INT)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'id', c.id,
        'type', c.type,
        'title', c.title,
        'original_title', c.original_title,
        'synopsis', c.synopsis,
        'release_date', c.release_date,
        'runtime_minutes', c.runtime_minutes,
        'year', c.year,
        'rating_avg', c.rating_avg,
        'rating_count', c.rating_count,
        'language_primary', c.language_primary,
        'maturity_rating', c.maturity_rating,
        'created_at', c.created_at,
        'updated_at', c.updated_at,
        'genres', (
            SELECT json_agg(json_build_object('id', g.id, 'name', g.name, 'slug', g.slug))
            FROM genres g
            JOIN content_genres cg ON cg.genre_id = g.id
            WHERE cg.content_id = c.id
        ),
        'episodes', (
            SELECT json_agg(json_build_object('id', e.id, 'episode_number', e.episode_number, 'title', e.title))
            FROM episodes e
            WHERE e.content_id = c.id
            ORDER BY e.episode_number
        )
    ) INTO result
    FROM contents c
    WHERE c.id = cid;

    IF result IS NULL THEN
        RETURN json_build_object('error','not_found');
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;

-- 2) search_contents_json(query, limit) -> devuelve lista JSON con resultados de búsqueda
CREATE OR REPLACE FUNCTION search_contents_json(q TEXT, lim INT DEFAULT 50)
RETURNS JSON AS $$
DECLARE
    results JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', c.id,
            'title', c.title,
            'type', c.type,
            'year', c.year,
            'synopsis', c.synopsis
        )
    ) INTO results
    FROM contents c
    WHERE q IS NULL OR q = '' OR (c.title ILIKE '%' || q || '%' OR c.synopsis ILIKE '%' || q || '%' OR c.original_title ILIKE '%' || q || '%')
    ORDER BY c.year DESC
    LIMIT lim;

    IF results IS NULL THEN
        RETURN '[]'::json;
    END IF;
    RETURN results;
END;
$$ LANGUAGE plpgsql STABLE;

-- 3) get_recommendations_for_profile(profile_id, limit) -> recomendaciones simples (no IA)
CREATE OR REPLACE FUNCTION get_recommendations_for_profile(pid INT, lim INT DEFAULT 10)
RETURNS JSON AS $$
DECLARE
    recs JSON;
BEGIN
    -- Ejemplo simple: recomendar los contenidos más valorados por score promedio, excluyendo los ya vistos por profile
    SELECT json_agg(json_build_object('id', c.id, 'title', c.title, 'rating_avg', c.rating_avg)) INTO recs
    FROM contents c
    WHERE c.id NOT IN (
        SELECT wh.content_id FROM watch_history wh WHERE wh.profile_id = pid
    )
    ORDER BY c.rating_avg DESC NULLS LAST
    LIMIT lim;

    IF recs IS NULL THEN
        RETURN '[]'::json;
    END IF;
    RETURN recs;
END;
$$ LANGUAGE plpgsql STABLE;

-- *********************
-- TRIGGERS Y FUNCIONES DE TRIGGER
-- *********************

-- 1) Trigger: actualizar updated_at en contents
CREATE OR REPLACE FUNCTION fn_update_contents_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_contents_updated_at ON contents;
CREATE TRIGGER trg_contents_updated_at
BEFORE UPDATE ON contents
FOR EACH ROW
EXECUTE PROCEDURE fn_update_contents_updated_at();

-- 2) Trigger: recalcular rating_avg y rating_count tras cambios en ratings
CREATE OR REPLACE FUNCTION fn_recalculate_ratings()
RETURNS TRIGGER AS $$
DECLARE
    avg_val NUMERIC(3,2);
    cnt INT;
BEGIN
    IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') OR (TG_OP = 'DELETE') THEN
        SELECT COUNT(*) , COALESCE(AVG(score),0) INTO cnt, avg_val
        FROM ratings
        WHERE content_id = COALESCE(NEW.content_id, OLD.content_id);

        UPDATE contents SET rating_count = cnt, rating_avg = avg_val
        WHERE id = COALESCE(NEW.content_id, OLD.content_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ratings_recalc ON ratings;
CREATE TRIGGER trg_ratings_recalc
AFTER INSERT OR UPDATE OR DELETE ON ratings
FOR EACH ROW
EXECUTE PROCEDURE fn_recalculate_ratings();

-- 3) Trigger: mantener counters de series (total_seasons / total_episodes)
CREATE OR REPLACE FUNCTION fn_update_series_counts_after_season()
RETURNS TRIGGER AS $$
DECLARE
    seasons_count INT;
    episodes_count INT;
BEGIN
    -- recalcula seasons
    SELECT COUNT(*) INTO seasons_count FROM seasons WHERE series_id = NEW.series_id;
    -- recalcula episodes total para la serie
    SELECT COUNT(e.*) INTO episodes_count
    FROM episodes e
    JOIN seasons s ON e.season_id = s.id
    WHERE s.series_id = NEW.series_id;

    UPDATE series SET total_seasons = seasons_count, total_episodes = episodes_count WHERE id = NEW.series_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_seasons_update_series ON seasons;
CREATE TRIGGER trg_seasons_update_series
AFTER INSERT OR DELETE ON seasons
FOR EACH ROW
EXECUTE PROCEDURE fn_update_series_counts_after_season();

-- Cuando se inserte o elimine un episodio, actualizar total_episodes para la serie correspondiente
CREATE OR REPLACE FUNCTION fn_update_series_counts_after_episode()
RETURNS TRIGGER AS $$
DECLARE
    series_id_val INT;
    episodes_count INT;
BEGIN
    SELECT s.series_id INTO series_id_val FROM seasons s WHERE s.id = COALESCE(NEW.season_id, OLD.season_id);
    IF series_id_val IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT COUNT(*) INTO episodes_count
    FROM episodes e
    JOIN seasons s ON e.season_id = s.id
    WHERE s.series_id = series_id_val;

    UPDATE series SET total_episodes = episodes_count WHERE id = series_id_val;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_episodes_update_series ON episodes;
CREATE TRIGGER trg_episodes_update_series
AFTER INSERT OR DELETE ON episodes
FOR EACH ROW
EXECUTE PROCEDURE fn_update_series_counts_after_episode();

-- 4) Trigger opcional: marcar finished en watch_history si last_position_seconds >= runtime_minutes*60
CREATE OR REPLACE FUNCTION fn_mark_watch_finished()
RETURNS TRIGGER AS $$
DECLARE
    runtime_seconds INT;
    cont_runtime INT;
BEGIN
    IF NEW.last_position_seconds IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT runtime_minutes INTO cont_runtime FROM contents WHERE id = NEW.content_id;
    IF cont_runtime IS NULL THEN
        RETURN NEW;
    END IF;
    runtime_seconds := cont_runtime * 60;
    IF NEW.last_position_seconds >= runtime_seconds THEN
        NEW.finished = TRUE;
        NEW.finished_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_watchhistory_mark_finished ON watch_history;
CREATE TRIGGER trg_watchhistory_mark_finished
BEFORE INSERT OR UPDATE ON watch_history
FOR EACH ROW
EXECUTE PROCEDURE fn_mark_watch_finished();


-- FIN init.sql
