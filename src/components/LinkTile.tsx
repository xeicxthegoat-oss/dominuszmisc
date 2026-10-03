import { useState, type CSSProperties } from 'react'
import type { HubLink } from '../data/links'
import { CATEGORIES } from '../data/links'
import { Icon } from './Icon'

function hostOf(url: string) {
  try {
    return new URL(url).hostname
  } catch {
    return ''
  }
}

function LinkArt({ link, size }: { link: HubLink; size: 'lg' | 'sm' }) {
  const [failed, setFailed] = useState(false)
  const hue = CATEGORIES.find((c) => c.id === link.category)?.hue ?? 320
  const host = hostOf(link.url)
  return (
    <span
      className={`art art-${size}`}
      style={{ '--hue': hue } as CSSProperties}
      aria-hidden="true"
    >
      {!failed && host ? (
        <img
          src={`https://www.google.com/s2/favicons?domain=${host}&sz=128`}
          alt=""
          loading="lazy"
          decoding="async"
          onError={() => setFailed(true)}
          onLoad={(e) => {
            // Google returns a 16px globe when a site has no icon — use initials instead
            if ((e.target as HTMLImageElement).naturalWidth <= 16) setFailed(true)
          }}
        />
      ) : (
        <span className="art-initials">{link.name.slice(0, 2)}</span>
      )}
    </span>
  )
}

interface TileProps {
  link: HubLink
  favorite: boolean
  newTab: boolean
  onToggleFavorite: (id: string) => void
  onOpen: (id: string) => void
  onRemove?: (id: string) => void
  variant?: 'tile' | 'card'
}

export function LinkTile({ link, favorite, newTab, onToggleFavorite, onOpen, onRemove, variant = 'card' }: TileProps) {
  const target = newTab ? { target: '_blank', rel: 'noopener noreferrer' } : {}
  return (
    <article className={`link link-${variant}`}>
      <a
        className="link-main"
        href={link.url}
        {...target}
        onClick={() => onOpen(link.id)}
        aria-label={`${link.name}: ${link.description}${newTab ? ' (opens in new tab)' : ''}`}
      >
        <LinkArt link={link} size={variant === 'tile' ? 'lg' : 'sm'} />
        <span className="link-text">
          <span className="link-name">{link.name}</span>
          {variant === 'card' && <span className="link-desc">{link.description}</span>}
          {variant === 'card' && link.tags && link.tags.length > 0 && (
            <span className="link-tags">
              {link.tags.map((t) => (
                <span key={t} className="tag">
                  {t}
                </span>
              ))}
            </span>
          )}
        </span>
        {variant === 'card' && (
          <span className="link-go" aria-hidden="true">
            <Icon name="external" size={16} />
          </span>
        )}
      </a>
      <div className="link-actions">
        <button
          type="button"
          className={`icon-btn fav ${favorite ? 'on' : ''}`}
          aria-pressed={favorite}
          aria-label={favorite ? `Unstar ${link.name}` : `Star ${link.name}`}
          title={favorite ? 'Unstar' : 'Star'}
          onClick={() => onToggleFavorite(link.id)}
        >
          <Icon name="star" size={16} filled={favorite} />
        </button>
        {onRemove && (
          <button
            type="button"
            className="icon-btn"
            aria-label={`Remove ${link.name}`}
            title="Remove"
            onClick={() => onRemove(link.id)}
          >
            <Icon name="trash" size={16} />
          </button>
        )}
      </div>
    </article>
  )
}
