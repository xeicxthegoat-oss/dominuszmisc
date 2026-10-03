// Curated link catalog. Add, remove or edit entries here — the whole UI is driven by this file.

export type CategoryId = 'proxies' | 'cloud' | 'games' | 'ai' | 'downloads'

export interface HubLink {
  id: string
  name: string
  url: string
  category: CategoryId
  description: string
  tags?: string[]
  featured?: boolean
  custom?: boolean
}

export interface Category {
  id: CategoryId
  label: string
  blurb: string
  icon: string
  hue: number
}

export const CATEGORIES: Category[] = [
  { id: 'proxies', label: 'Proxies', blurb: 'Web proxies and self-hostable proxy projects.', icon: 'shield', hue: 330 },
  { id: 'cloud', label: 'Cloud Gaming', blurb: 'Stream full games straight to your browser.', icon: 'cloud', hue: 200 },
  { id: 'games', label: 'Games', blurb: 'Instant-play browser games, no installs.', icon: 'gamepad', hue: 280 },
  { id: 'ai', label: 'AI', blurb: 'Chatbots, assistants and creative AI tools.', icon: 'sparkles', hue: 160 },
  { id: 'downloads', label: 'Downloads', blurb: 'Official stores, launchers and safe software.', icon: 'download', hue: 30 },
]

const l = (
  category: CategoryId,
  name: string,
  url: string,
  description: string,
  tags: string[] = [],
  featured = false,
): HubLink => ({
  id: `${category}:${name.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`,
  name,
  url,
  category,
  description,
  tags,
  featured,
})

export const LINKS: HubLink[] = [
  // Proxies
  l('proxies', 'CroxyProxy', 'https://www.croxyproxy.com', 'Fast free web proxy with video support.', ['web proxy'], true),
  l('proxies', 'ProxySite', 'https://www.proxysite.com', 'Simple web proxy with multiple server regions.', ['web proxy']),
  l('proxies', 'Hide.me Proxy', 'https://hide.me/en/proxy', 'Free proxy from a well-known VPN provider.', ['web proxy']),
  l('proxies', 'Proxyium', 'https://proxyium.com', 'Lightweight browser proxy, no sign-up.', ['web proxy']),
  l('proxies', 'KProxy', 'https://kproxy.com', 'Long-running free proxy service.', ['web proxy']),
  l('proxies', '4everproxy', 'https://www.4everproxy.com', 'Proxy with selectable IP locations.', ['web proxy']),
  l('proxies', 'Ultraviolet', 'https://github.com/titaniumnetwork-dev/Ultraviolet', 'Open-source service-worker proxy engine.', ['self-host', 'open source']),
  l('proxies', 'Interstellar', 'https://github.com/UseInterstellar/Interstellar', 'Self-hostable proxy site with a games hub.', ['self-host', 'open source']),
  l('proxies', 'Holy Unblocker', 'https://github.com/QuiteAFancyEmerald/Holy-Unblocker', 'Privacy-focused self-hostable web proxy.', ['self-host', 'open source']),

  // Cloud gaming
  l('cloud', 'Xbox Cloud Gaming', 'https://www.xbox.com/play', 'Stream Game Pass titles in your browser.', ['game pass'], true),
  l('cloud', 'GeForce NOW', 'https://play.geforcenow.com', 'Play your Steam & Epic library on NVIDIA servers.', ['free tier'], true),
  l('cloud', 'now.gg', 'https://now.gg', 'Run mobile games instantly in the browser.', ['mobile', 'free']),
  l('cloud', 'Boosteroid', 'https://cloud.boosteroid.com', 'Cloud PC gaming for games you own.', ['subscription']),
  l('cloud', 'Amazon Luna', 'https://luna.amazon.com', 'Amazon’s game streaming channels.', ['prime']),
  l('cloud', 'easyfun.gg', 'https://www.easyfun.gg', 'Free cloud gaming for popular titles.', ['free']),
  l('cloud', 'Blacknut', 'https://www.blacknut.com', 'Family-friendly cloud gaming catalog.', ['subscription']),
  l('cloud', 'PlayStation Plus', 'https://www.playstation.com/ps-plus/', 'Stream PlayStation classics with Premium.', ['subscription']),
  l('cloud', 'Parsec', 'https://parsec.app', 'Low-latency remote play from your own PC.', ['remote play', 'free']),

  // Games
  l('games', 'Poki', 'https://poki.com', 'Thousands of free browser games.', ['portal'], true),
  l('games', 'CrazyGames', 'https://www.crazygames.com', 'Huge library of instant-play games.', ['portal']),
  l('games', 'Krunker', 'https://krunker.io', 'Fast-paced pixel FPS.', ['fps', 'multiplayer'], true),
  l('games', 'Shell Shockers', 'https://shellshock.io', 'Egg-themed multiplayer shooter.', ['fps', 'multiplayer']),
  l('games', 'Bloxd.io', 'https://bloxd.io', 'Voxel minigames and building.', ['sandbox', 'multiplayer']),
  l('games', 'Minecraft Classic', 'https://classic.minecraft.net', 'The 2009 original, free in-browser.', ['sandbox']),
  l('games', 'Smash Karts', 'https://smashkarts.io', 'Kart battle arena.', ['racing', 'multiplayer']),
  l('games', 'Slither.io', 'https://slither.io', 'Grow the longest snake.', ['io', 'multiplayer']),
  l('games', 'Agar.io', 'https://agar.io', 'Eat cells, get big, don’t get eaten.', ['io', 'multiplayer']),
  l('games', 'Diep.io', 'https://diep.io', 'Tank upgrade arena.', ['io', 'multiplayer']),
  l('games', 'Paper.io 2', 'https://paper-io.com', 'Claim territory, avoid trails.', ['io']),
  l('games', 'GeoGuessr', 'https://www.geoguessr.com', 'Guess where in the world you are.', ['puzzle']),
  l('games', '2048', 'https://play2048.co', 'Slide tiles to reach 2048.', ['puzzle']),
  l('games', 'Wordle', 'https://www.nytimes.com/games/wordle', 'One word a day.', ['puzzle', 'daily']),
  l('games', 'Little Alchemy 2', 'https://littlealchemy2.com', 'Combine elements to discover the world.', ['puzzle']),
  l('games', 'Lichess', 'https://lichess.org', 'Free, open-source chess.', ['board', 'multiplayer']),
  l('games', 'Chess.com', 'https://www.chess.com/play', 'Play chess online with millions.', ['board', 'multiplayer']),
  l('games', 'Skribbl.io', 'https://skribbl.io', 'Draw and guess with friends.', ['party', 'multiplayer']),
  l('games', 'Gartic Phone', 'https://garticphone.com', 'The telephone game, with drawings.', ['party', 'multiplayer']),
  l('games', 'Coolmath Games', 'https://www.coolmathgames.com', 'Classic logic and skill games.', ['portal']),
  l('games', 'itch.io Web Games', 'https://itch.io/games/platform-web', 'Indie games playable in-browser.', ['indie', 'portal']),

  // AI
  l('ai', 'ChatGPT', 'https://chatgpt.com', 'OpenAI’s general-purpose assistant.', ['chat'], true),
  l('ai', 'Claude', 'https://claude.ai', 'Anthropic’s assistant for writing, code and analysis.', ['chat'], true),
  l('ai', 'Gemini', 'https://gemini.google.com', 'Google’s multimodal assistant.', ['chat']),
  l('ai', 'Perplexity', 'https://www.perplexity.ai', 'AI answer engine with sources.', ['search']),
  l('ai', 'Microsoft Copilot', 'https://copilot.microsoft.com', 'Microsoft’s everyday AI companion.', ['chat']),
  l('ai', 'Grok', 'https://grok.com', 'xAI’s conversational assistant.', ['chat']),
  l('ai', 'DeepSeek', 'https://chat.deepseek.com', 'Strong open-weight reasoning models.', ['chat']),
  l('ai', 'Le Chat', 'https://chat.mistral.ai', 'Mistral’s fast assistant.', ['chat']),
  l('ai', 'HuggingChat', 'https://huggingface.co/chat', 'Chat with open-source models.', ['chat', 'open source']),
  l('ai', 'Poe', 'https://poe.com', 'Many AI models in one app.', ['chat']),
  l('ai', 'NotebookLM', 'https://notebooklm.google.com', 'Research and study with your own sources.', ['study']),
  l('ai', 'Character.AI', 'https://character.ai', 'Chat with custom AI characters.', ['fun']),
  l('ai', 'Suno', 'https://suno.com', 'Generate songs from a prompt.', ['music']),
  l('ai', 'Leonardo.Ai', 'https://leonardo.ai', 'AI image generation and editing.', ['images']),

  // Downloads
  l('downloads', 'Steam', 'https://store.steampowered.com', 'The biggest PC game store.', ['store'], true),
  l('downloads', 'Epic Games Store', 'https://store.epicgames.com', 'Free games every week.', ['store', 'free games']),
  l('downloads', 'GOG', 'https://www.gog.com', 'DRM-free games and classics.', ['store']),
  l('downloads', 'itch.io', 'https://itch.io', 'Indie games, many free or pay-what-you-want.', ['store', 'indie']),
  l('downloads', 'Prism Launcher', 'https://prismlauncher.org', 'Open-source Minecraft launcher.', ['launcher']),
  l('downloads', 'Modrinth', 'https://modrinth.com', 'Minecraft mods, packs and shaders.', ['mods']),
  l('downloads', 'CurseForge', 'https://www.curseforge.com', 'Mods for many games.', ['mods']),
  l('downloads', 'Heroic Launcher', 'https://heroicgameslauncher.com', 'Open-source Epic & GOG launcher.', ['launcher']),
  l('downloads', 'Playnite', 'https://playnite.link', 'One library for every launcher.', ['launcher']),
  l('downloads', 'RetroArch', 'https://www.retroarch.com', 'Frontend for emulators and engines.', ['emulation']),
  l('downloads', 'Discord', 'https://discord.com/download', 'Voice and chat for gamers.', ['social']),
  l('downloads', 'OBS Studio', 'https://obsproject.com', 'Free recording and streaming.', ['creator']),
  l('downloads', 'Ninite', 'https://ninite.com', 'Install many apps at once, no junk.', ['utility']),
  l('downloads', '7-Zip', 'https://www.7-zip.org', 'Open-source file archiver.', ['utility']),
  l('downloads', 'VLC', 'https://www.videolan.org', 'Plays almost any media file.', ['media']),
  l('downloads', 'Firefox', 'https://www.mozilla.org/firefox', 'Private, independent browser.', ['browser']),
  l('downloads', 'uBlock Origin', 'https://ublockorigin.com', 'Efficient content blocker.', ['browser', 'privacy']),
  l('downloads', 'LibreOffice', 'https://www.libreoffice.org', 'Free office suite.', ['productivity']),
]

export const QUOTES = [
  'Everything you need, one tab away.',
  'No ads. No clutter. Just links.',
  'Press / to search anything.',
  'Star a link to pin it to your dashboard.',
  'Paste a URL in search and hit Enter to go.',
]
