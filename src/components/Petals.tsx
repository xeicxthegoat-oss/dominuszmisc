import { useMemo, type CSSProperties } from 'react'

// Decorative falling sakura blossoms. Hidden from assistive tech and disabled for reduced-motion users via CSS.
export function Petals({ count = 22 }: { count?: number }) {
  const petals = useMemo(
    () =>
      Array.from({ length: count }, (_, i) => ({
        left: Math.random() * 100,
        size: 14 + Math.random() * 18,
        duration: 14 + Math.random() * 16,
        delay: -Math.random() * 30,
        drift: (Math.random() - 0.5) * 160,
        key: i,
      })),
    [count],
  )
  return (
    <div className="petals" aria-hidden="true">
      {petals.map((p) => (
        <svg
          key={p.key}
          className="petal"
          viewBox="-24 -24 48 48"
          width={p.size}
          height={p.size}
          style={
            {
              left: `${p.left}%`,
              animationDuration: `${p.duration}s`,
              animationDelay: `${p.delay}s`,
              '--drift': `${p.drift}px`,
            } as CSSProperties
          }
        >
          {[0, 72, 144, 216, 288].map((r) => (
            <path key={r} transform={`rotate(${r})`} d="M0-3C-7-9-8-18 0-22 8-18 7-9 0-3Z" />
          ))}
          <circle r="3.5" />
        </svg>
      ))}
    </div>
  )
}
