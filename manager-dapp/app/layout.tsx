'use client'

import { AptosWalletProvider } from '@razorlabs/wallet-kit';
import '@razorlabs/wallet-kit/style.css';
import { Toaster } from "sonner";
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';
import { Inter } from 'next/font/google';
import { motion, AnimatePresence } from 'framer-motion';
import "./globals.css";

// Initialize Inter font
const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
});

// Page transition variants
const pageVariants = {
  initial: {
    opacity: 0,
    y: 20,
  },
  animate: {
    opacity: 1,
    y: 0,
  },
  exit: {
    opacity: 0,
    y: -20,
  },
};

interface RootLayoutProps {
  children: React.ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
        <meta name="description" content="MoveDID - Your Digital Identity on Movement" />
        <meta name="theme-color" content="#2563eb" />
        <link rel="icon" href="/favicon.ico" />
      </head>
      <body className="min-h-screen bg-[var(--pixel-background)] text-[var(--pixel-text)] antialiased">
        <AptosWalletProvider>
          <AnimatePresence mode="wait">
            <motion.main
              initial="initial"
              animate="animate"
              exit="exit"
              variants={pageVariants}
              transition={{ duration: 0.3, ease: "easeOut" }}
              className="flex flex-col min-h-screen"
            >
              {children}
            </motion.main>
          </AnimatePresence>

          {/* Enhanced Toaster with better positioning and animations */}
          <Toaster
            position="bottom-right"
            toastOptions={{
              style: {
                background: 'var(--pixel-card)',
                border: '2px solid var(--pixel-surface)',
                borderRadius: '0.75rem',
                color: 'var(--pixel-text)',
              },
              className: 'toast-custom',
            }}
          />
        </AptosWalletProvider>

        {/* Performance monitoring */}
        <Analytics />
        <SpeedInsights />

        {/* Backdrop blur for modals */}
        <div id="modal-backdrop" className="fixed inset-0 bg-black/50 backdrop-blur-sm hidden" />
      </body>
    </html>
  );
}

// Add these styles to your globals.css
const styles = `
  /* Custom scrollbar */
  ::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  ::-webkit-scrollbar-track {
    background: var(--pixel-surface);
  }

  ::-webkit-scrollbar-thumb {
    background: var(--pixel-text-muted);
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb:hover {
    background: var(--pixel-text-secondary);
  }

  /* Smooth scrolling */
  html {
    scroll-behavior: smooth;
  }

  /* Better font rendering */
  body {
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-rendering: optimizeLegibility;
  }

  /* Toast custom styles */
  .toast-custom {
    animation: toast-slide-in 0.2s ease-out;
  }

  @keyframes toast-slide-in {
    from {
      transform: translateX(100%);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  /* Focus outline */
  :focus-visible {
    outline: 2px solid var(--pixel-accent);
    outline-offset: 2px;
  }

  /* Selection color */
  ::selection {
    background: var(--pixel-accent);
    color: white;
  }
`;

export { styles as layoutStyles };
