# AGENTS.md

## Overview
Sakura Hub is a static single-page link hub (proxies, cloud gaming, games, AI, downloads). It has no backend.

## Architecture
- `src/data/links.ts`: the source of truth for categories (id, label, icon, hue), every curated link, and the dashboard tips. The UI is fully data-driven, so adding a category means adding it to `CategoryId` and `CATEGORIES`.
- `src/App.tsx`: the app shell (sidebar, top bar, search) plus the views: Dashboard, CategoryView, Starred, SettingsView. Routing is hash-based (`#/games`) through the `View` type, with no router dependency.
- `src/components/LinkTile.tsx`: the link component in two variants. `tile` is the square art tile used on the dashboard; `card` is the descriptive card used on section pages. Icons come from Google's favicon service and fall back to initials on a hue gradient.
- `src/components/Petals.tsx`: decorative petals, hidden for reduced-motion users.
- `src/components/Icon.tsx`: inline SVG icon set, looked up by name.
- `src/storage.ts`: the `useStored` hook (localStorage, `sakura:` prefix) and the `Settings` defaults.
- `src/styles.css`: all styling. Theme tokens are CSS variables; `data-accent` on `<html>` swaps the accent palette.

## Conventions
- Never add ads, analytics or trackers. That is a core product promise.
- Link only to official sites. No piracy or malware sources in Downloads.
- Keep things accessible: every interactive element needs a label, focus styles must stay visible, and motion must respect `prefers-reduced-motion`.
- Only per-browser preferences go in localStorage. If shared or admin-managed links are added later, move them to Netlify Database.
