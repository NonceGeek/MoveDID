"use client";

import { AptosConnectButton } from "@razorlabs/wallet-kit";
import Link from "next/link";

export function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-[var(--pixel-card)] shadow-md border-b border-[var(--pixel-surface)]">
      <nav className="container mx-auto flex h-16 items-center justify-between px-4 lg:px-8">
        {/* Logo and Brand */}
        <Link
          href="/"
          className="flex items-center gap-2 hover:opacity-90 transition-opacity"
        >
          <span className="text-xl font-semibold bg-gradient-to-r from-[var(--pixel-primary)] to-[var(--pixel-accent)] bg-clip-text text-transparent">
            MoveDID
          </span>
        </Link>

        {/* Navigation and Actions */}
        <div className="flex items-center gap-6">
          <div className="hidden md:flex items-center gap-6">
            <Link
              href="https://x.com/intent/follow?screen_name=MoveDIDBooster"
              target="_blank"
              rel="noopener noreferrer"
              className="text-[var(--pixel-text-secondary)] hover:text-[var(--pixel-text-primary)] transition-colors"
            >
              Twitter
            </Link>
            <Link
              href="https://github.com/thopatevijay/MoveDIDBooster"
              target="_blank"
              rel="noopener noreferrer"
              className="text-[var(--pixel-text-secondary)] hover:text-[var(--pixel-text-primary)] transition-colors"
            >
              GitHub
            </Link>
          </div>
          {/* Connect Button */}
          <AptosConnectButton
            className="pixel-button bg-[var(--pixel-primary)] text-white font-medium
              px-4 py-2 rounded-lg hover:shadow-md transition-all duration-200
              hover:bg-[color-mix(in_srgb,var(--pixel-primary)_90%,white)]"
          />
        </div>
      </nav>
    </header>
  );
} 