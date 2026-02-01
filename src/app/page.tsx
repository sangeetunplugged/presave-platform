import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 bg-[#0a0a0a]/80 backdrop-blur-xl border-b border-[#27272a]/50">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-[#1DB954] to-[#8b5cf6] flex items-center justify-center">
              <span className="text-white font-bold text-lg">P</span>
            </div>
            <span className="text-xl font-bold">PreSave.in</span>
          </Link>
          <div className="hidden md:flex items-center gap-8">
            <Link href="#features" className="text-[#a1a1aa] hover:text-white transition-colors">Features</Link>
            <Link href="#playlists" className="text-[#a1a1aa] hover:text-white transition-colors">Playlist Pitching</Link>
            <Link href="#pricing" className="text-[#a1a1aa] hover:text-white transition-colors">Pricing</Link>
            <Link href="/curator/register" className="text-[#a1a1aa] hover:text-white transition-colors">For Curators</Link>
            <Link href="/login" className="text-[#a1a1aa] hover:text-white transition-colors">Login</Link>
            <Link href="/signup" className="px-5 py-2.5 rounded-full bg-[#1DB954] hover:bg-[#1ed760] text-black font-semibold transition-colors">
              Get Started Free
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-6 relative overflow-hidden">
        <div className="max-w-7xl mx-auto text-center relative z-10">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#18181b] border border-[#27272a] mb-8">
            <span className="w-2 h-2 rounded-full bg-[#1DB954] animate-pulse"></span>
            <span className="text-sm text-[#a1a1aa]">India's #1 Music Marketing Platform</span>
          </div>

          <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight">
            From Pre-Save to{" "}
            <span className="gradient-text">Platinum</span>
          </h1>
          
          <p className="text-xl text-[#a1a1aa] max-w-3xl mx-auto mb-10">
            Pre-saves, smart links, playlist pitching, and fan marketing. Everything you need to grow your music career — built for Indian artists.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16">
            <Link 
              href="/signup" 
              className="px-8 py-4 rounded-full bg-[#1DB954] hover:bg-[#1ed760] text-black font-semibold text-lg transition-all hover:-translate-y-1 hover:shadow-lg hover:shadow-[#1DB954]/25"
            >
              Start Free — No Card Needed
            </Link>
            <Link 
              href="#demo" 
              className="px-8 py-4 rounded-full border border-[#3f3f46] hover:border-[#a1a1aa] text-white font-semibold text-lg transition-colors"
            >
              Watch Demo
            </Link>
          </div>

          {/* Platform Logos */}
          <div className="flex flex-wrap items-center justify-center gap-4">
            <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#18181b]/50 border border-[#27272a]">
              <div className="w-3 h-3 rounded-full" style={{ background: '#1DB954' }}></div>
              <span className="text-sm text-[#a1a1aa]">Spotify</span>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#18181b]/50 border border-[#27272a]">
              <div className="w-3 h-3 rounded-full" style={{ background: '#fc3c44' }}></div>
              <span className="text-sm text-[#a1a1aa]">Apple Music</span>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#18181b]/50 border border-[#27272a]">
              <div className="w-3 h-3 rounded-full" style={{ background: '#2BC5B4' }}></div>
              <span className="text-sm text-[#a1a1aa]">JioSaavn</span>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#18181b]/50 border border-[#27272a]">
              <div className="w-3 h-3 rounded-full" style={{ background: '#FF0000' }}></div>
              <span className="text-sm text-[#a1a1aa]">YouTube Music</span>
            </div>
            <div className="flex items-center gap-2 px-4 py-2 rounded-full bg-[#18181b]/50 border border-[#27272a]">
              <div className="w-3 h-3 rounded-full" style={{ background: '#E72C30' }}></div>
              <span className="text-sm text-[#a1a1aa]">Gaana</span>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-16 border-y border-[#27272a] bg-[#0f0f0f]">
        <div className="max-w-7xl mx-auto px-6">
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-8 text-center">
            <div className="text-center">
              <div className="text-3xl md:text-4xl font-bold gradient-text mb-1">10,000+</div>
              <div className="text-[#a1a1aa]">Artists</div>
            </div>
            <div className="text-center">
              <div className="text-3xl md:text-4xl font-bold gradient-text mb-1">1M+</div>
              <div className="text-[#a1a1aa]">Pre-Saves Collected</div>
            </div>
            <div className="text-center">
              <div className="text-3xl md:text-4xl font-bold gradient-text mb-1">500+</div>
              <div className="text-[#a1a1aa]">Playlist Curators</div>
            </div>
            <div className="text-center">
              <div className="text-3xl md:text-4xl font-bold gradient-text mb-1">FREE</div>
              <div className="text-[#a1a1aa]">Start for Free</div>
            </div>
          </div>
        </div>
      </section>

      {/* Rest of the content continues... */}
    </div>
  );
}
