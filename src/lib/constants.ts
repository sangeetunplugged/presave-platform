// Platform configurations and constants

export const PLATFORMS = {
  spotify: {
    id: 'spotify',
    name: 'Spotify',
    color: '#1DB954',
    hoverColor: '#1ed760',
    textColor: '#000000',
    icon: '🎵',
    hasPlaylistApi: true,
  },
  apple: {
    id: 'apple',
    name: 'Apple Music',
    color: '#fc3c44',
    hoverColor: '#ff5a5f',
    textColor: '#ffffff',
    icon: '🍎',
    hasPlaylistApi: false,
  },
  // ... more platforms
} as const;

export const PRICING = {
  free: {
    name: 'Free',
    price: 0,
    features: ['3 pre-save links/month', 'Unlimited smart links', 'Basic analytics'],
  },
  artist: {
    name: 'Artist',
    price: 99,
    features: ['Unlimited pre-save links', 'Email collection', 'WhatsApp reminders'],
  },
  // ... more pricing tiers
} as const;
