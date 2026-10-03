import { useCallback, useEffect, useMemo, useRef, useState, type ComponentProps, type CSSProperties, type FormEvent, type ReactNode } from 'react'
import { CATEGORIES, LINKS, QUOTES, type CategoryId, type HubLink } from './data/links'
import { DEFAULT_SETTINGS, useStored, type Settings } from './storage'
import { Icon } from './components/Icon'
import { LinkTile } from './components/LinkTile'
import { Petals } from './components/Petals'

type View = 'dashboard' | CategoryId | 'favorites' | 'settings'

const NAV: { id: View; label: string; icon: string }[] = [
  { id: 'dashboard', label: 'Dashboard', icon: 'home' },
  ...CATEGORIES.map((c) => ({ id: c.id as View, label: c.label, icon: c.icon })),
  { id: 'favorites', label: 'Starred', icon: 'star' },
  { id: 'settings', label: 'Settings', icon: 'settings' },
]

const VIEW_IDS = NAV.map((n) => n.id)

function readHash(): View {
  const h = window.location.hash.replace(/^#\/?/, '') as View
  return VIEW_IDS.includes(h) ? h : 'dashboard'
}

function looksLikeUrl(q: string) {
  return /^(https?:\/\/)?[\w-]+(\.[\w-]+)+(\/\S*)?$/i.test(q.trim())
}

export default function App() {
  const [view, setView] = useState<View>(readHash)
  const [query, setQuery] = useState('')
  const [navOpen, setNavOpen] = useState(false)
  const [settings, setSettings] = useStored<Settings>('settings', DEFAULT_SETTINGS)
  const [favorites, setFavorites] = useStored<string[]>('favorites', [])
  const [recent, setRecent] = useStored<string[]>('recent', [])
  const [customLinks, setCustomLinks] = useStored<HubLink[]>('custom', [])
  const searchRef = useRef<HTMLInputElement>(null)
  const mainRef = useRef<HTMLElement>(null)

  const s = { ...DEFAULT_SETTINGS, ...settings }
  const allLinks = useMemo(() => [...LINKS, ...customLinks], [customLinks])
  const byId = useMemo(() => new Map(allLinks.map((x) => [x.id, x])), [allLinks])

  useEffect(() => {
    const onHash = () => setView(readHash())
    window.addEventListener('hashchange', onHash)
    return () => window.removeEventListener('hashchange', onHash)
  }, [])

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      const el = e.target as HTMLElement
      const typing = el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.tagName === 'SELECT'
      if (e.key === '/' && !typing) {
        e.preventDefault()
        searchRef.current?.focus()
      }
      if (e.key === 'Escape') setNavOpen(false)
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  useEffect(() => {
    document.documentElement.dataset.accent = s.accent
    document.documentElement.classList.toggle('large-text', s.largeText)
  }, [s.accent, s.largeText])

  const go = (v: View) => {
    window.location.hash = `/${v}`
    setView(v)
    setQuery('')
    setNavOpen(false)
    mainRef.current?.focus()
  }

  const toggleFavorite = useCallback(
    (id: string) => setFavorites((f) => (f.includes(id) ? f.filter((x) => x !== id) : [id, ...f])),
    [setFavorites],
  )
  const markOpened = useCallback(
    (id: string) => setRecent((r) => [id, ...r.filter((x) => x !== id)].slice(0, 8)),
    [setRecent],
  )
  const removeCustom = (id: string) => {
    setCustomLinks((c) => c.filter((x) => x.id !== id))
    setFavorites((f) => f.filter((x) => x !== id))
  }

  const tileProps = (link: HubLink) => ({
    link,
    favorite: favorites.includes(link.id),
    newTab: s.newTab,
    onToggleFavorite: toggleFavorite,
    onOpen: markOpened,
    onRemove: link.custom ? removeCustom : undefined,
  })

  const q = query.trim().toLowerCase()
  const results = q
    ? allLinks.filter((x) =>
        [x.name, x.description, x.url, ...(x.tags ?? []), CATEGORIES.find((c) => c.id === x.category)?.label ?? '']
          .join(' ')
          .toLowerCase()
          .includes(q),
      )
    : []

  const openUrl = (url: string) => {
    if (s.newTab) window.open(url, '_blank', 'noopener,noreferrer')
    else window.location.href = url
  }

  const onSearchSubmit = (e: FormEvent) => {
    e.preventDefault()
    if (!q) return
    if (results.length > 0 && !looksLikeUrl(query)) {
      const first = results[0]
      markOpened(first.id)
      openUrl(first.url)
    } else if (looksLikeUrl(query)) {
      const url = /^https?:\/\//i.test(query.trim()) ? query.trim() : `https://${query.trim()}`
      openUrl(url)
    }
  }

  return (
    <div className={`shell ${navOpen ? 'nav-open' : ''}`}>
      <a className="skip" href="#main">
        Skip to content
      </a>
      {s.petals && <Petals />}

      <aside className="sidebar" aria-label="Primary">
        <div className="brand">
          <img src="/favicon.svg" alt="" width={48} height={48} />
          <div>
            <div className="brand-name">Sakura Hub</div>
            <div className="brand-sub">Proxies · Cloud · Games · AI</div>
          </div>
          <button type="button" className="icon-btn nav-close" aria-label="Close menu" onClick={() => setNavOpen(false)}>
            <Icon name="close" />
          </button>
        </div>
        <nav>
          <ul>
            {NAV.map((n) => (
              <li key={n.id}>
                <a
                  href={`#/${n.id}`}
                  className={`nav-item ${view === n.id && !q ? 'active' : ''}`}
                  aria-current={view === n.id && !q ? 'page' : undefined}
                  onClick={(e) => {
                    e.preventDefault()
                    go(n.id)
                  }}
                >
                  <Icon name={n.icon} size={22} filled={n.id === 'favorites' && favorites.length > 0} />
                  <span>{n.label}</span>
                  {n.id === 'favorites' && favorites.length > 0 && <span className="count">{favorites.length}</span>}
                </a>
              </li>
            ))}
          </ul>
        </nav>
        <div className="noads">
          <Icon name="shield" size={18} />
          <span>Ad-free</span>
          <span className="pill">Always</span>
        </div>
        <div className="sidebar-foot">
          <span>
            <Icon name="globe" size={14} /> Shared library
          </span>
          <span className="pill mono">{allLinks.length} links</span>
        </div>
      </aside>
      <button
        type="button"
        className="scrim"
        aria-hidden={!navOpen}
        tabIndex={-1}
        onClick={() => setNavOpen(false)}
      />

      <div className="content">
        <header className="topbar">
          <button
            type="button"
            className="icon-btn menu-btn"
            aria-label="Open menu"
            aria-expanded={navOpen}
            onClick={() => setNavOpen(true)}
          >
            <Icon name="menu" />
          </button>
          <form className="search" role="search" onSubmit={onSearchSubmit}>
            <Icon name="search" size={18} />
            <label htmlFor="search" className="sr-only">
              Search links or enter a URL
            </label>
            <input
              id="search"
              ref={searchRef}
              type="search"
              placeholder="Search proxies, games, AI… or paste a URL  ( / )"
              value={query}
              autoComplete="off"
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => e.key === 'Escape' && setQuery('')}
            />
          </form>
          <Clock />
          <button
            type="button"
            className="icon-btn square"
            aria-label="Toggle fullscreen"
            title="Fullscreen"
            onClick={() =>
              document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.()
            }
          >
            <Icon name="expand" />
          </button>
          <button type="button" className="user" onClick={() => go('settings')} aria-label={`Profile: ${s.name}. Open settings`}>
            <img src="/favicon.svg" alt="" width={36} height={36} />
            <span>{s.name}</span>
          </button>
        </header>

        <main id="main" ref={mainRef} tabIndex={-1}>
          {q ? (
            <section aria-labelledby="results-h">
              <SectionHead id="results-h" icon="search" title={`Results for “${query.trim()}”`} />
              <p className="muted" aria-live="polite">
                {results.length} {results.length === 1 ? 'match' : 'matches'}
                {results.length > 0 && ' · press Enter to open the first one'}
                {looksLikeUrl(query) && ' · press Enter to open this URL'}
              </p>
              <div className="grid cards">
                {results.map((x) => (
                  <LinkTile key={x.id} {...tileProps(x)} />
                ))}
              </div>
            </section>
          ) : view === 'dashboard' ? (
            <Dashboard
              name={s.name}
              allLinks={allLinks}
              favorites={favorites.map((id) => byId.get(id)).filter(Boolean) as HubLink[]}
              recent={recent.map((id) => byId.get(id)).filter(Boolean) as HubLink[]}
              tileProps={tileProps}
              go={go}
            />
          ) : view === 'favorites' ? (
            <section aria-labelledby="fav-h">
              <SectionHead id="fav-h" icon="star" title="Starred" />
              {favorites.length === 0 ? (
                <Empty text="Nothing starred yet. Tap the ☆ on any link to pin it here and on your dashboard." />
              ) : (
                <div className="grid cards">
                  {favorites
                    .map((id) => byId.get(id))
                    .filter(Boolean)
                    .map((x) => (
                      <LinkTile key={x!.id} {...tileProps(x!)} />
                    ))}
                </div>
              )}
            </section>
          ) : view === 'settings' ? (
            <SettingsView
              settings={s}
              setSettings={setSettings}
              customLinks={customLinks}
              addCustom={(link) => setCustomLinks((c) => [...c, link])}
              removeCustom={removeCustom}
              reset={() => {
                setSettings(DEFAULT_SETTINGS)
                setFavorites([])
                setRecent([])
                setCustomLinks([])
              }}
            />
          ) : (
            <CategoryView id={view} links={allLinks.filter((x) => x.category === view)} tileProps={tileProps} />
          )}
        </main>
        <footer className="footer">
          Sakura Hub · no ads, no trackers · links open the official sites · use services in line with your network’s rules
        </footer>
      </div>
    </div>
  )
}

type TilePropsFn = (link: HubLink) => ComponentProps<typeof LinkTile>

function SectionHead({ id, icon, title, action }: { id: string; icon: string; title: string; action?: ReactNode }) {
  return (
    <div className="section-head">
      <h2 id={id}>
        <span className="section-icon">
          <Icon name={icon} size={22} filled={icon === 'flame' || icon === 'star'} />
        </span>
        {title}
      </h2>
      {action}
    </div>
  )
}

function Empty({ text }: { text: string }) {
  return <p className="empty">{text}</p>
}

function Clock() {
  const [now, setNow] = useState(() => new Date())
  useEffect(() => {
    const t = setInterval(() => setNow(new Date()), 1000)
    return () => clearInterval(t)
  }, [])
  return (
    <div className="chip clock" aria-label={`Current time ${now.toLocaleTimeString()}`} role="timer">
      <Icon name="clock" size={18} />
      <span className="mono">{now.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit', second: '2-digit' })}</span>
    </div>
  )
}

function Dashboard({
  name,
  allLinks,
  favorites,
  recent,
  tileProps,
  go,
}: {
  name: string
  allLinks: HubLink[]
  favorites: HubLink[]
  recent: HubLink[]
  tileProps: TilePropsFn
  go: (v: View) => void
}) {
  const [quote, setQuote] = useState(0)
  useEffect(() => {
    const t = setInterval(() => setQuote((i) => (i + 1) % QUOTES.length), 6000)
    return () => clearInterval(t)
  }, [])
  const featured = allLinks.filter((x) => x.featured)
  const pinned = favorites.length ? favorites : featured
  const greeting = (() => {
    const h = new Date().getHours()
    return h < 5 ? 'Up late' : h < 12 ? 'Good morning' : h < 18 ? 'Welcome back' : 'Good evening'
  })()

  return (
    <>
      <section className="hero glass" aria-labelledby="hero-h">
        <h1 id="hero-h">
          {greeting}, {name}
        </h1>
        <p className="quote" aria-live="polite">
          “{QUOTES[quote]}”
        </p>
        <div className="dots" role="tablist" aria-label="Tips">
          {QUOTES.map((_, i) => (
            <button
              key={i}
              type="button"
              role="tab"
              aria-selected={i === quote}
              aria-label={`Tip ${i + 1}`}
              className={i === quote ? 'on' : ''}
              onClick={() => setQuote(i)}
            />
          ))}
        </div>
      </section>

      <div className="dash">
        <div className="dash-main">
          <section aria-labelledby="feat-h">
            <SectionHead
              id="feat-h"
              icon={favorites.length ? 'star' : 'flame'}
              title={favorites.length ? 'Your starred' : 'Featured'}
              action={
                <a
                  className="see-all"
                  href="#/games"
                  onClick={(e) => {
                    e.preventDefault()
                    go(favorites.length ? 'favorites' : 'games')
                  }}
                >
                  {favorites.length ? 'All starred' : 'All games'} →
                </a>
              }
            />
            <div className="grid tiles">
              {pinned.slice(0, 12).map((x) => (
                <LinkTile key={x.id} {...tileProps(x)} variant="tile" />
              ))}
            </div>
          </section>

          {recent.length > 0 && (
            <section aria-labelledby="recent-h">
              <SectionHead id="recent-h" icon="history" title="Jump back in" />
              <div className="grid tiles">
                {recent.slice(0, 6).map((x) => (
                  <LinkTile key={x.id} {...tileProps(x)} variant="tile" />
                ))}
              </div>
            </section>
          )}

          <section aria-labelledby="cats-h">
            <SectionHead id="cats-h" icon="sparkles" title="Browse everything" />
            <div className="grid cats">
              {CATEGORIES.map((c) => (
                <a
                  key={c.id}
                  href={`#/${c.id}`}
                  className="cat glass"
                  style={{ '--hue': c.hue } as CSSProperties}
                  onClick={(e) => {
                    e.preventDefault()
                    go(c.id)
                  }}
                >
                  <span className="cat-icon">
                    <Icon name={c.icon} size={26} />
                  </span>
                  <span className="cat-label">{c.label}</span>
                  <span className="cat-blurb">{c.blurb}</span>
                  <span className="cat-count mono">{allLinks.filter((x) => x.category === c.id).length} links</span>
                </a>
              ))}
            </div>
          </section>
        </div>

        <aside className="library glass" aria-labelledby="lib-h">
          <div className="library-head">
            <h2 id="lib-h">Your library</h2>
            <Icon name="chart" size={20} />
          </div>
          <dl>
            {CATEGORIES.map((c) => (
              <div key={c.id} className="row">
                <dt>{c.label}</dt>
                <dd className="mono" style={{ color: `hsl(${c.hue} 90% 75%)` }}>
                  {allLinks.filter((x) => x.category === c.id).length}
                </dd>
              </div>
            ))}
            <div className="row">
              <dt>Starred</dt>
              <dd className="mono">{favorites.length}</dd>
            </div>
            <div className="row">
              <dt>Ads shown</dt>
              <dd className="mono">0</dd>
            </div>
          </dl>
        </aside>
      </div>
    </>
  )
}

function CategoryView({ id, links, tileProps }: { id: CategoryId; links: HubLink[]; tileProps: TilePropsFn }) {
  const cat = CATEGORIES.find((c) => c.id === id)!
  const tags = useMemo(() => [...new Set(links.flatMap((x) => x.tags ?? []))].sort(), [links])
  const [tag, setTag] = useState<string | null>(null)
  useEffect(() => setTag(null), [id])
  const shown = tag ? links.filter((x) => x.tags?.includes(tag)) : links

  return (
    <section aria-labelledby="cat-h">
      <div className="cat-hero glass" style={{ '--hue': cat.hue } as CSSProperties}>
        <span className="cat-icon big">
          <Icon name={cat.icon} size={34} />
        </span>
        <div>
          <h1 id="cat-h">{cat.label}</h1>
          <p className="muted">{cat.blurb}</p>
        </div>
      </div>
      {tags.length > 1 && (
        <div className="filters" role="group" aria-label={`Filter ${cat.label}`}>
          <button type="button" className={`chip-btn ${!tag ? 'on' : ''}`} aria-pressed={!tag} onClick={() => setTag(null)}>
            All · {links.length}
          </button>
          {tags.map((t) => (
            <button
              key={t}
              type="button"
              className={`chip-btn ${tag === t ? 'on' : ''}`}
              aria-pressed={tag === t}
              onClick={() => setTag(tag === t ? null : t)}
            >
              {t}
            </button>
          ))}
        </div>
      )}
      <div className="grid cards">
        {shown.map((x) => (
          <LinkTile key={x.id} {...tileProps(x)} />
        ))}
      </div>
    </section>
  )
}

function SettingsView({
  settings,
  setSettings,
  customLinks,
  addCustom,
  removeCustom,
  reset,
}: {
  settings: Settings
  setSettings: (s: Settings) => void
  customLinks: HubLink[]
  addCustom: (l: HubLink) => void
  removeCustom: (id: string) => void
  reset: () => void
}) {
  const update = <K extends keyof Settings>(k: K, v: Settings[K]) => setSettings({ ...settings, [k]: v })
  const [draft, setDraft] = useState({ name: '', url: '', category: 'games' as CategoryId, description: '' })
  const [error, setError] = useState('')

  const submit = (e: FormEvent) => {
    e.preventDefault()
    const raw = draft.url.trim()
    const url = /^https?:\/\//i.test(raw) ? raw : `https://${raw}`
    try {
      new URL(url)
    } catch {
      setError('That doesn’t look like a valid URL.')
      return
    }
    if (!draft.name.trim()) {
      setError('Give the link a name.')
      return
    }
    addCustom({
      id: `custom:${Date.now()}`,
      name: draft.name.trim(),
      url,
      category: draft.category,
      description: draft.description.trim() || 'Added by you.',
      tags: ['mine'],
      custom: true,
    })
    setDraft({ name: '', url: '', category: draft.category, description: '' })
    setError('')
  }

  const accents: { id: Settings['accent']; label: string }[] = [
    { id: 'sakura', label: 'Sakura' },
    { id: 'violet', label: 'Violet' },
    { id: 'aqua', label: 'Aqua' },
    { id: 'citrus', label: 'Citrus' },
  ]

  return (
    <section aria-labelledby="set-h" className="settings">
      <SectionHead id="set-h" icon="settings" title="Settings" />
      <div className="settings-grid">
        <div className="panel glass">
          <h3>Profile & look</h3>
          <label className="field">
            <span>Display name</span>
            <input
              value={settings.name}
              maxLength={24}
              onChange={(e) => update('name', e.target.value || 'friend')}
            />
          </label>
          <fieldset className="field">
            <legend>Accent colour</legend>
            <div className="swatches">
              {accents.map((a) => (
                <label key={a.id} className={`swatch swatch-${a.id}`}>
                  <input
                    type="radio"
                    name="accent"
                    checked={settings.accent === a.id}
                    onChange={() => update('accent', a.id)}
                  />
                  <span>{a.label}</span>
                </label>
              ))}
            </div>
          </fieldset>
          <Toggle label="Falling petals" checked={settings.petals} onChange={(v) => update('petals', v)} />
          <Toggle label="Larger text" checked={settings.largeText} onChange={(v) => update('largeText', v)} />
          <Toggle label="Open links in a new tab" checked={settings.newTab} onChange={(v) => update('newTab', v)} />
        </div>

        <div className="panel glass">
          <h3>Add your own link</h3>
          <form onSubmit={submit} className="add-form" noValidate>
            <label className="field">
              <span>Name</span>
              <input value={draft.name} onChange={(e) => setDraft({ ...draft, name: e.target.value })} required />
            </label>
            <label className="field">
              <span>URL</span>
              <input
                value={draft.url}
                inputMode="url"
                placeholder="example.com"
                onChange={(e) => setDraft({ ...draft, url: e.target.value })}
                required
              />
            </label>
            <label className="field">
              <span>Section</span>
              <select
                value={draft.category}
                onChange={(e) => setDraft({ ...draft, category: e.target.value as CategoryId })}
              >
                {CATEGORIES.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.label}
                  </option>
                ))}
              </select>
            </label>
            <label className="field">
              <span>Short description (optional)</span>
              <input value={draft.description} onChange={(e) => setDraft({ ...draft, description: e.target.value })} />
            </label>
            {error && (
              <p className="error" role="alert">
                {error}
              </p>
            )}
            <button type="submit" className="btn">
              <Icon name="plus" size={18} /> Add link
            </button>
          </form>
          {customLinks.length > 0 && (
            <ul className="custom-list">
              {customLinks.map((c) => (
                <li key={c.id}>
                  <span>
                    <strong>{c.name}</strong> <span className="muted">· {CATEGORIES.find((x) => x.id === c.category)?.label}</span>
                  </span>
                  <button type="button" className="icon-btn" aria-label={`Remove ${c.name}`} onClick={() => removeCustom(c.id)}>
                    <Icon name="trash" size={16} />
                  </button>
                </li>
              ))}
            </ul>
          )}
          <p className="muted small">Your name, stars and custom links are saved in this browser only.</p>
        </div>
      </div>
      <button
        type="button"
        className="btn ghost danger"
        onClick={() => window.confirm('Reset all settings, stars and custom links?') && reset()}
      >
        Reset everything
      </button>
    </section>
  )
}

function Toggle({ label, checked, onChange }: { label: string; checked: boolean; onChange: (v: boolean) => void }) {
  return (
    <label className="toggle">
      <span>{label}</span>
      <input type="checkbox" role="switch" checked={checked} onChange={(e) => onChange(e.target.checked)} />
      <span className="track" aria-hidden="true" />
    </label>
  )
}
