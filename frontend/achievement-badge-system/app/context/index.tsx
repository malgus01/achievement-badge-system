"use client";

import { wagmiAdapter, projectId, networks } from "@/app/config";
import { createAppKit } from "@reown/appkit/react";
import { base } from "@reown/appkit/networks";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import React, { ReactNode, useEffect } from "react";
import { cookieToInitialState, WagmiProvider, type Config, useAccount } from "wagmi";

const queryClient = new QueryClient();

if (!projectId) throw new Error("NEXT_PUBLIC_PROJECT_ID is not defined");

console.log("🔧 Project ID:", projectId);
console.log("🌐 Networks:", [base, ...networks]);

const metadata = {
    name: "Achievement Badge System",
    description: "A system to manage and display achievement badges.",
    url: "https://achievement-badge-system.vercel.app", // Removed trailing slash
    icons: ["https://achievement-badge-system.vercel.app/favicon.ico"],
};

console.log("📝 Metadata:", metadata);

// Initialize AppKit with detailed logging
const appKit = createAppKit({
    adapters: [wagmiAdapter],
    projectId,
    networks: [base, ...networks],
    defaultNetwork: base,
    metadata,
    features: {
        analytics: true,
        email: true,
        socials: ["google", "x", "github", "discord", "farcaster"],
        emailShowWallets: true,
    },
    themeMode: "light",
    enableWalletConnect: true, // Explicitly enable WalletConnect
    enableInjected: true, // Explicitly enable injected wallets
    enableCoinbase: true, // Explicitly enable Coinbase
});

console.log("🎯 AppKit initialized:", !!appKit);

// Expose AppKit to window for debugging and analytics
if (typeof window !== 'undefined') {
    (window as any).appkit = appKit;
    console.log("🪟 AppKit exposed to window");
}

// Analytics tracker component
function AnalyticsTracker() {
    const { isConnected, address, chainId } = useAccount();

    useEffect(() => {
        if (isConnected && address) {
            console.log("📊 Analytics Event - Wallet Connected:", {
                address,
                chainId,
                timestamp: new Date().toISOString(),
                url: window.location.href,
            });

            // Force analytics tracking
            try {
                if (window && (window as any).appkit) {
                    console.log("📈 AppKit instance found on window");
                } else {
                    console.log("❌ AppKit instance not found on window");
                }
            } catch (error) {
                console.error("🚨 Analytics tracking error:", error);
            }
        } else if (!isConnected) {
            console.log("🔌 Wallet disconnected");
        }
    }, [isConnected, address, chainId]);

    return null;
}

interface ContextProviderProps {
    children: ReactNode;
    cookies: string | null;
}

function ContextProvider({ children, cookies }: ContextProviderProps) {
    const initialState = cookieToInitialState(wagmiAdapter.wagmiConfig as Config, cookies);

    console.log("🍪 Initial state from cookies:", !!initialState);

    return (
        <WagmiProvider config={wagmiAdapter.wagmiConfig as Config} initialState={initialState}>
            <QueryClientProvider client={queryClient}>
                <AnalyticsTracker />
                {children}
            </QueryClientProvider>
        </WagmiProvider>
    );
}

export default ContextProvider;