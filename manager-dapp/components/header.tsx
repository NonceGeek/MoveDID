"use client";

import { ConnectButton } from "@razorlabs/razorkit";

export function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 border-b border-[var(--pixel-accent)] bg-[var(--pixel-background)] shadow-lg">
      <div className="container flex h-16 items-center justify-between px-4">
        <div className="flex items-center gap-2 font-pixel">
          <span className="text-xl text-[var(--pixel-accent)] pixel-text">&lt; MoveDID &gt;</span>
        </div>
        <div className="flex items-center gap-4">
          <ConnectButton 
            className="w-[22rem] pixel-button !bg-[var(--pixel-accent)] !text-black font-pixel text-sm px-4 py-2 !rounded-none"
            style={{
              border: 'var(--pixel-border) solid #b39700',
              textShadow: '1px 1px 0 rgba(255,255,255,0.4)',
              boxShadow: 'var(--pixel-border) var(--pixel-border) 0 rgba(0,0,0,0.5)'
            }}
            label="Connect"
          />
        </div>
      </div>
    </header>
  );
} 