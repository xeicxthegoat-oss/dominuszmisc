import { useEffect, useState } from 'react'

// Personal preferences (name, favorites, custom links) live in this browser only.
export function useStored<T>(key: string, initial: T) {
  const [value, setValue] = useState<T>(() => {
    try {
      const raw = localStorage.getItem(`sakura:${key}`)
      return raw ? (JSON.parse(raw) as T) : initial
    } catch {
      return initial
    }
  })
  useEffect(() => {
    try {
      localStorage.setItem(`sakura:${key}`, JSON.stringify(value))
    } catch {
      /* storage unavailable */
    }
  }, [key, value])
  return [value, setValue] as const
}

export interface Settings {
  name: string
  petals: boolean
  accent: 'sakura' | 'violet' | 'aqua' | 'citrus'
  newTab: boolean
  largeText: boolean
}

export const DEFAULT_SETTINGS: Settings = {
  name: 'friend',
  petals: true,
  accent: 'sakura',
  newTab: true,
  largeText: false,
}
