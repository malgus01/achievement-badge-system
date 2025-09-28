// app/context/index.tsx
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

// Initialize AppKit with enhanced analytics configuration
const appKit = createAppKit({
    adapters: [wagmiAdapter],
    projectId,
    networks: [base, ...networks],
    defaultNetwork: base,
    metadata,
    features: {
        analytics: true, // This is crucial
        email: true,
        socials: ["google", "x", "github", "discord", "farcaster"],
        emailShowWallets: true,
    },
    themeMode: "light",
    enableWalletConnect: true,
    enableInjected: true,
    enableCoinbase: true,
    // Add these additional options for better tracking
    allWallets: "SHOW", // Show all available wallets
    includeWalletIds: [], // Include all wallets
    excludeWalletIds: [], // Don't exclude any wallets
});

console.log("🎯 AppKit initialized:", !!appKit);

// Enhanced Analytics and Session Tracker
function AnalyticsTracker() {
    const { isConnected, address, chainId } = useAccount();

    useEffect(() => {
        if (isConnected && address) {
            console.log("📊 Analytics Event - Wallet Connected:", {
                address: address.slice(0, 6) + "..." + address.slice(-4), // Log truncated for privacy
                chainId,
                timestamp: new Date().toISOString(),
                url: window.location.href,
            });

            // Track connection event explicitly
            try {
                // Force a session creation by interacting with AppKit
                if (typeof window !== 'undefined') {
                    const appKitInstance = (window as any).appkit || appKit;

                    // Log additional connection details
                    console.log("📈 Session Details:", {
                        projectId,
                        domain: window.location.hostname,
                        connected: isConnected,
                        network: chainId,
                    });

                    // Manual analytics event dispatch
                    try {
                        // Attempt to trigger analytics tracking
                        if (appKitInstance && typeof appKitInstance.track === 'function') {
                            appKitInstance.track({
                                event: 'wallet_connected',
                                properties: {
                                    address: address,
                                    chainId: chainId,
                                    projectId: projectId,
                                    timestamp: Date.now()
                                }
                            });
                            console.log("🎯 Manual analytics event sent");
                        }
                    } catch (trackError) {
                        console.log("📊 Manual tracking not available:", trackError instanceof Error ? trackError.message : String(trackError));
                    }
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

// Domain verification component
function DomainVerification() {
    useEffect(() => {
        if (typeof window !== 'undefined') {
            console.log("🌐 Domain Verification:", {
                hostname: window.location.hostname,
                origin: window.location.origin,
                projectId,
                configuredDomain: "https://achievement-badge-system.vercel.app"
            });
        }
    }, []);

    return null;
}

// AppKit Event Listener
function AppKitEventTracker() {
    useEffect(() => {
        if (typeof window !== 'undefined' && appKit) {
            // Listen for AppKit events if available
            try {
                const handleConnect = (event: any) => {
                    console.log("🔗 AppKit Connect Event:", event);
                };

                const handleDisconnect = (event: any) => {
                    console.log("🔌 AppKit Disconnect Event:", event);
                };

                // Try to add event listeners
                if (appKit.subscribeEvents) {
                    appKit.subscribeEvents((event: any) => {
                        console.log("📡 AppKit Event:", event);
                    });
                }

                return () => {
                    // Cleanup if needed
                };
            } catch (error) {
                console.log("📡 Event listener setup not available:", error instanceof Error ? error.message : String(error));
            }
        }
    }, []);

    return null;
}

interface ContextProviderProps {
    children: ReactNode;
    cookies: string | null;
}

function ContextProvider({ children, cookies }: ContextProviderProps) {
    const initialState = cookieToInitialState(wagmiAdapter.wagmiConfig as Config, cookies);

    console.log("🍪 Initial state from cookies:", !!initialState);

    // Expose AppKit globally for debugging
    useEffect(() => {
        if (typeof window !== 'undefined') {
            (window as any).appkit = appKit;
            (window as any).reownProjectId = projectId;
            console.log("🪟 AppKit exposed to window for debugging");
            console.log("🔑 Project ID exposed for debugging");
        }
    }, []);

    return (
        <WagmiProvider config={wagmiAdapter.wagmiConfig as Config} initialState={initialState}>
            <QueryClientProvider client={queryClient}>
                <DomainVerification />
                <AnalyticsTracker />
                <AppKitEventTracker />
                {children}
            </QueryClientProvider>
        </WagmiProvider>
    );
}

export default ContextProvider;