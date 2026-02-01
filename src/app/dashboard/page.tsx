"use client";

import Link from "next/link";
import { useState } from "react";
import { DashboardLayout } from "@/components/DashboardLayout";

export default function DashboardPage() {
  return (
    <DashboardLayout role="artist">
      <div className="p-6 lg:p-10">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-10">
          <div>
            <h1 className="text-3xl font-bold mb-1">Dashboard</h1>
            <p className="text-[#a1a1aa]">Welcome back! Here's what's happening with your music.</p>
          </div>
          <button className="px-6 py-3 rounded-xl bg-[#1DB954] hover:bg-[#1ed760] text-black font-semibold transition-colors flex items-center gap-2">
            <span>+</span>
            Create New Link
          </button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-10">
          <div className="bg-[#18181b] border border-[#27272a] rounded-2xl p-6">
            <p className="text-[#a1a1aa] text-sm mb-2">Total Clicks</p>
            <p className="text-3xl font-bold mb-1">12,458</p>
            <p className="text-sm text-[#1DB954]">+12% from last month</p>
          </div>
          <div className="bg-[#18181b] border border-[#27272a] rounded-2xl p-6">
            <p className="text-[#a1a1aa] text-sm mb-2">Pre-Saves</p>
            <p className="text-3xl font-bold mb-1">3,240</p>
            <p className="text-sm text-[#1DB954]">+8% from last month</p>
          </div>
          <div className="bg-[#18181b] border border-[#27272a] rounded-2xl p-6">
            <p className="text-[#a1a1aa] text-sm mb-2">Conversion Rate</p>
            <p className="text-3xl font-bold mb-1">26%</p>
            <p className="text-sm text-[#1DB954]">+2% from last month</p>
          </div>
          <div className="bg-[#18181b] border border-[#27272a] rounded-2xl p-6">
            <p className="text-[#a1a1aa] text-sm mb-2">Active Links</p>
            <p className="text-3xl font-bold mb-1">8</p>
            <p className="text-sm text-[#71717a]">No change</p>
          </div>
        </div>

        {/* Recent Links */}
        <div className="bg-[#18181b] border border-[#27272a] rounded-2xl overflow-hidden">
          <div className="p-6 border-b border-[#27272a] flex items-center justify-between">
            <h2 className="text-xl font-semibold">Recent Links</h2>
            <Link href="/dashboard/links" className="text-[#1DB954] hover:underline text-sm">
              View All →
            </Link>
          </div>

          <div className="divide-y divide-[#27272a]">
            {/* Link items would go here */}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid md:grid-cols-3 gap-4 mt-8">
          <Link href="/dashboard/links/new?type=presave" className="block p-6 bg-[#18181b] border border-[#27272a] rounded-2xl hover:border-[#3f3f46] transition-all hover:-translate-y-1">
            <div className="text-3xl mb-3">🚀</div>
            <h3 className="font-semibold mb-1">Create Pre-Save</h3>
            <p className="text-sm text-[#a1a1aa]">Collect saves before your release</p>
          </Link>
          <Link href="/dashboard/links/new?type=smartlink" className="block p-6 bg-[#18181b] border border-[#27272a] rounded-2xl hover:border-[#3f3f46] transition-all hover:-translate-y-1">
            <div className="text-3xl mb-3">🔗</div>
            <h3 className="font-semibold mb-1">Create Smart Link</h3>
            <p className="text-sm text-[#a1a1aa]">One link for all platforms</p>
          </Link>
          <Link href="/dashboard/playlists" className="block p-6 bg-[#18181b] border border-[#27272a] rounded-2xl hover:border-[#3f3f46] transition-all hover:-translate-y-1">
            <div className="text-3xl mb-3">🎵</div>
            <h3 className="font-semibold mb-1">Pitch to Playlists</h3>
            <p className="text-sm text-[#a1a1aa]">Get on curated playlists</p>
          </Link>
        </div>
      </div>
    </DashboardLayout>
  );
}
