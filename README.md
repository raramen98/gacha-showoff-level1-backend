# 🎰 뽑았다! — 갓챠 자랑 게시판 · 백엔드

가챠에서 뽑은 캐릭터를 사진과 함께 자랑하고, 작품·시리즈별로 구경하는 게시판의 **API 서버**예요.
NestJS + PostgreSQL로 만들었고, 화면(프론트엔드)은 [gacha-showoff-level1-frontend](https://github.com/raramen98/gacha-showoff-level1-frontend) 저장소에 있어요.

- 기획서: [기획서.md](./기획서.md)

> ⏰ **첫 접속이 느릴 수 있어요**
> Render **무료 서버**라서 15분 동안 아무도 쓰지 않으면 서버가 잠들어요.
> 잠든 뒤 처음 접속하면 서버가 깨어나는 데 **1분 가까이** 걸릴 수 있어요. 잠시 기다린 뒤 새로고침해 주세요.
> 한 번 깨어나면 그다음부터는 빠르게 응답해요.

## 기술
- NestJS 10 (Node.js 18.18 이상)
- PostgreSQL (`pg`) — 모든 테이블은 **`gacha_l1` 스키마** 안에 있어요
- 사진은 DB(`gacha_l1.posts.image_data`)에 함께 저장해요

## API
| 기능 | 주소 |
|---|---|
| DB 연결 상태 확인 | `GET /health` |
| 시리즈 목록 | `GET /series` |
| 시리즈 상세 (+자랑 글) | `GET /series/:id` |
| 시리즈 등록 | `POST /series` |
| 자랑 글 목록 | `GET /posts` |
| 자랑 글 상세 | `GET /posts/:id` |
| 자랑 글 사진 | `GET /posts/:id/image` |
| 자랑 글 등록 | `POST /posts` (multipart/form-data) |

- 자랑 글 등록에는 `image`(사진, **필수**, JPG·PNG·WEBP·GIF, 5MB 이하), `series_id`(선택), `nickname`(2~12자), `character_name`, `rarity`(`common`/`rare`/`secret`), `comment`(100자 이내)를 보내요.
- 업로드 날짜는 등록 시각(`created_at`)이 자동으로 들어가요.
- 입력이 틀리면 `400`과 함께 쉬운 한국어로 이유를 돌려줘요.
  ```json
  { "statusCode": 400, "message": "사진을 올려 주세요", "errors": { "image": "사진을 올려 주세요", "nickname": "닉네임을 적어 주세요" } }
  ```
- `/health` 예시
  ```json
  { "status": "ok", "db": "connected", "message": "DB에 잘 연결되어 있어요.", "schema": "gacha_l1", "counts": { "series": 12, "posts": 50 } }
  ```

## 데이터 구조 (`gacha_l1` 스키마)
- `series` — 가챠 시리즈 (작품 이름, 시리즈 이름, 1회 가격, 출시일)
- `posts` — 자랑 글 (시리즈(선택), 닉네임, 캐릭터, 레어도, 한마디, 사진, 업로드 날짜)
- 시리즈 하나에 자랑 글 여러 개 (`posts.series_id` → `series.id`, 1:N)

## 내 컴퓨터에서 실행하기
```bash
npm install
cp .env.example .env    # .env를 열어 DATABASE_URL에 DB 주소 적기
npm run db:setup        # gacha_l1 스키마와 테이블 만들기 (여러 번 해도 안전)
npm run db:seed         # 가상 데이터 넣기 (이미 있으면 건너뜀)
npm run start:dev       # http://localhost:4000
```
- 가상 데이터를 처음부터 다시 넣으려면 `npm run db:reset` (`gacha_l1`의 데이터만 지워요)

## 설정값 (.env)
| 이름 | 뜻 | 예 |
|---|---|---|
| `DATABASE_URL` | PostgreSQL 접속 주소 | `postgresql://사용자:비밀번호@호스트/DB이름` |
| `DB_SSL` | SSL로 DB에 접속할지 (Render DB는 `true`) | `true` |
| `PORT` | 서버 포트 (Render에서는 자동으로 정해짐) | `4000` |
| `CORS_ORIGIN` | 이 API를 부를 수 있는 프론트엔드 주소 (여러 개면 쉼표로 구분) | `https://gacha-showoff-level1-frontend.vercel.app` |

> `.env`는 `.gitignore`에 들어 있어서 GitHub에 올라가지 않아요. 값의 이름만 `.env.example`에 있어요.

## Render에 올리기
1. Render → **New → Web Service** → 이 저장소 선택 (또는 **New → Blueprint**로 `render.yaml` 사용)
2. 설정
   | 항목 | 값 |
   |---|---|
   | Runtime | Node |
   | Build Command | `npm install && npm run build` |
   | Start Command | `npm start` |
   | Health Check Path | `/health` |
3. Environment에 `DATABASE_URL`, `DB_SSL`, `CORS_ORIGIN`, `NODE_VERSION`(`20`)을 넣기
4. 배포가 끝나면 `https://<서비스 이름>.onrender.com/health`에서 `"db":"connected"`가 나오는지 확인
