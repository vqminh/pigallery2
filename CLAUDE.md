# CLAUDE.md

## Build & Run

The backend has **compiled `.js` files alongside `.ts` sources**. Node resolves `.js` before `.ts`, so editing a `.ts` file has no effect until you rebuild.

```bash
# Rebuild backend after editing .ts files (required before restart)
npx tsc --project tsconfig.json

# Start the server
node ./src/backend/index

# Type-check only (does NOT produce .js output)
npx tsc --noEmit --project tsconfig.json

# Run tests
npx ts-mocha --timeout 10000 test/backend/unit/**/*.spec.ts
```

## Architecture

- **Backend**: Express server in `src/backend/`, TypeScript compiled to `.js` in-place
- **Frontend**: Angular app in `src/frontend/`, built to `dist/` (language subfolders)
- **Common**: Shared types/DTOs in `src/common/` (used by both frontend and backend)
- **Config**: Runtime config in `config.json` at project root; defaults in `src/common/config/`
- **Database**: SQLite by default, stored in `db/sqlite.db`

## Key Paths

- `src/backend/routes/` — Express route definitions
- `src/backend/middlewares/` — Express middleware (auth, thumbnails, rendering)
- `src/backend/model/fileaccess/` — Photo/video processing, Sharp/ffmpeg integration
- `src/common/entities/ContentWrapper.ts` — Packed wire format for API responses
- `config.json` — Runtime configuration (media folder, DB, supported formats)
- `browse.html` — Standalone photo browser UI (served at `/browse`)

## API

- Login: `POST /pgapi/user/login` with `{loginCredential: {username, password}}`
- Directory listing: `GET /pgapi/gallery/content/<path>`
- Thumbnails: `GET /pgapi/gallery/content/<mediaPath>/<size>` (sizes: 320, 540, 1080, 2160)
- Full-res photo: `GET /pgapi/gallery/content/<mediaPath>`
- Search: `GET /pgapi/search/<searchQueryDTO>`

API responses use a packed format (abbreviated field names) — see `ContentWrapperUtils.pack/unpack` in `ContentWrapper.ts`.

## Photo Processing

- Thumbnails are converted to WebP via Sharp and cached in `<tempFolder>/tc/`
- Non-browser-native formats (HEIC, DNG, ARW, TIFF) are converted to WebP on-the-fly for full-res serving
- Thumbnail cache checks verify `stat.size > 0` to catch failed conversions (0-byte files)
- Supported photo formats configured in `config.json` under `Media.Photo.supportedFormats`
