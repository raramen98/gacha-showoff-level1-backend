-- 갓챠 자랑 게시판 Level 1 — 모든 테이블은 gacha_l1 스키마 안에만 만든다.
-- (같은 DB를 Level 2에서도 쓰기 때문에 public 등 다른 스키마는 건드리지 않음)
CREATE SCHEMA IF NOT EXISTS gacha_l1;

-- 테이블 1: 가챠 시리즈
CREATE TABLE IF NOT EXISTS gacha_l1.series (
  id           SERIAL PRIMARY KEY,
  ip_name      VARCHAR(30)  NOT NULL,
  name         VARCHAR(60)  NOT NULL,
  price        INTEGER      NOT NULL CHECK (price >= 0),
  release_date DATE         NOT NULL,
  created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 테이블 2: 자랑 글 (시리즈 하나에 자랑 글 여러 개, 1:N — 시리즈는 고르지 않아도 됨)
-- 업로드 날짜는 created_at(등록 시각)을 그대로 쓴다
CREATE TABLE IF NOT EXISTS gacha_l1.posts (
  id             SERIAL PRIMARY KEY,
  series_id      INTEGER      REFERENCES gacha_l1.series(id) ON DELETE SET NULL,
  nickname       VARCHAR(12)  NOT NULL CHECK (char_length(nickname) >= 2),
  character_name VARCHAR(50)  NOT NULL,
  rarity         VARCHAR(10)  NOT NULL CHECK (rarity IN ('common', 'rare', 'secret')),
  comment        VARCHAR(100) NOT NULL DEFAULT '',
  image_type     VARCHAR(20),
  image_data     BYTEA,
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 이미 만들어 둔 테이블을 새 구조로 바꾸기 (여러 번 실행해도 안전)
ALTER TABLE gacha_l1.posts ALTER COLUMN series_id DROP NOT NULL;
ALTER TABLE gacha_l1.posts DROP COLUMN IF EXISTS pulled_at;
ALTER TABLE gacha_l1.posts ADD COLUMN IF NOT EXISTS image_type VARCHAR(20);
ALTER TABLE gacha_l1.posts ADD COLUMN IF NOT EXISTS image_data BYTEA;
ALTER TABLE gacha_l1.posts DROP CONSTRAINT IF EXISTS posts_series_id_fkey;
ALTER TABLE gacha_l1.posts ADD CONSTRAINT posts_series_id_fkey
  FOREIGN KEY (series_id) REFERENCES gacha_l1.series(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS posts_series_id_idx ON gacha_l1.posts (series_id);
CREATE INDEX IF NOT EXISTS posts_created_at_idx ON gacha_l1.posts (created_at DESC);
