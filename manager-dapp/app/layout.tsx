'use client'

import { AptosWalletProvider } from '@razorlabs/wallet-kit';
import '@razorlabs/wallet-kit/style.css';
import { Toaster } from "sonner";
import "./globals.css";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh">
      <body>
        <AptosWalletProvider>
          {children}
          <Toaster />
        </AptosWalletProvider>
      </body>
    </html>
  );
}
