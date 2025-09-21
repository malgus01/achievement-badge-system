// app/layout.tsx (or wherever your root layout is)

import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

import { headers } from 'next/headers';
import ContextProvider from './context';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Achievement Badge System',
  description: 'A system to manage and display achievement badges.',
};

export default async function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  // Now we await headers()
  const headersList = await headers();
  const cookies = headersList.get('cookie');

  return (
    <html lang="en">
      <body className={inter.className}>
        <ContextProvider cookies={cookies}>
          {children}
        </ContextProvider>
      </body>
    </html>
  );
}