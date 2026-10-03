# Sakura Hub

An ad-free, accessible start page that gathers web proxies, cloud gaming services, browser games, AI tools and trusted downloads in one place. It has a dark glass look with falling sakura petals.

## Features

- **Dashboard**: a greeting, rotating tips, featured or starred links, "Jump back in" recents, category cards and a library stats panel
- **Sections**: Proxies, Cloud Gaming, Games, AI and Downloads, each with tag filters
- **Search**: press `/` from anywhere. Enter opens the top match, or goes straight to a URL you paste
- **Stars**: pin any link. Starred links replace "Featured" on the dashboard
- **Settings**: display name, accent colour, petals on/off, larger text, new-tab behaviour, and your own custom links
- **Accessibility**: skip link, full keyboard navigation, visible focus rings, ARIA labels, and support for `prefers-reduced-motion`
- No ads, no trackers, no accounts

## Tech

Vite + React 19 + TypeScript and plain CSS, deployed on Netlify as a static site. Personal preferences are stored in the browser's `localStorage`.

## Run locally

```bash
npm install
npm run dev        # or: netlify dev
```

## Editing links

All built-in links live in `src/data/links.ts`. Add an entry with `l(category, name, url, description, tags, featured)`.
