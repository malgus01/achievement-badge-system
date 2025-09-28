// components/SignMessage.tsx
'use client';
import { useAccount, useSignMessage } from 'wagmi';
import { useState, useEffect } from 'react';

export default function SignMessage() {
    const { isConnected, address, chainId } = useAccount();
    const { signMessage, isPending, isSuccess, error, data: signature } = useSignMessage();
    const [hasSigned, setHasSigned] = useState(false);
    const [sessionCreated, setSessionCreated] = useState(false);
    const [signedData, setSignedData] = useState<string | null>(null);

    const handleSignMessage = async () => {
        if (!isConnected || !address) return;

        const message = `Welcome to Academic Sandbox!

This signature creates your analytics session.

Address: ${address}
Chain ID: ${chainId}
Timestamp: ${new Date().toISOString()}
Domain: ${window.location.hostname}

By signing this message, you agree to participate in our educational platform.`;

        try {
            await signMessage({
                message,
                account: address // Explicitly pass the account
            });

            console.log("📝 Message signed successfully");
            console.log("✍️ Signature will be available in hook data");

            setHasSigned(true);
            setSignedData(signature || 'signed');

            // Track the signing event for analytics
            try {
                const sessionData = {
                    address,
                    chainId,
                    signature: signature,
                    message,
                    timestamp: new Date().toISOString(),
                    domain: window.location.hostname,
                    projectId: (window as any).reownProjectId
                };

                console.log("📊 Session Data for Analytics:", sessionData);

                // Try to manually create analytics session
                if (typeof window !== 'undefined' && (window as any).appkit) {
                    const appKit = (window as any).appkit;

                    // Attempt different methods to trigger analytics
                    try {
                        if (appKit.track) {
                            appKit.track('session_created', sessionData);
                            console.log("🎯 AppKit track method called");
                        }

                        if (appKit.analytics) {
                            appKit.analytics.track('user_signed_message', sessionData);
                            console.log("🎯 AppKit analytics track method called");
                        }

                        // Try to access the internal analytics instance
                        if (appKit._analytics) {
                            appKit._analytics.track('user_authenticated', sessionData);
                            console.log("🎯 Internal analytics track method called");
                        }

                        setSessionCreated(true);
                        console.log("🎯 Analytics session creation attempted");
                    } catch (trackingError) {
                        const errorMessage = trackingError instanceof Error ? trackingError.message : String(trackingError);
                        console.log("📊 AppKit tracking methods not available:", errorMessage);
                    }
                }

                // Manual analytics event to Reown
                try {
                    const analyticsEndpoint = 'https://analytics.walletconnect.com/events';
                    const analyticsPayload = {
                        projectId: (window as any).reownProjectId,
                        event: 'user_authenticated',
                        properties: {
                            address: address,
                            chainId: chainId,
                            domain: window.location.hostname,
                            timestamp: Date.now(),
                            method: 'message_signature',
                            signature_success: !!signature
                        }
                    };

                    console.log("📡 Attempting manual analytics POST:", analyticsPayload);

                    // Note: This might be blocked by CORS, but worth trying
                    fetch(analyticsEndpoint, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify(analyticsPayload)
                    }).then(response => {
                        console.log("📡 Manual analytics response:", response.status, response.statusText);
                    }).catch(fetchError => {
                        const errorMessage = fetchError instanceof Error ? fetchError.message : String(fetchError);
                        console.log("📡 Manual analytics failed (expected):", errorMessage);
                    });

                } catch (apiError) {
                    const errorMessage = apiError instanceof Error ? apiError.message : String(apiError);
                    console.log("📡 Manual API setup failed:", errorMessage);
                }

            } catch (analyticsError) {
                const errorMessage = analyticsError instanceof Error ? analyticsError.message : String(analyticsError);
                console.error("📊 Analytics tracking error:", errorMessage);
            }

        } catch (signError) {
            const errorMessage = signError instanceof Error ? signError.message : String(signError);
            console.error("❌ Failed to sign message:", errorMessage);
        }
    };

    // Track successful signatures from the hook
    useEffect(() => {
        if (isSuccess && signature && !hasSigned) {
            console.log("🎉 Signature successful from hook:", signature);
            setHasSigned(true);
            setSignedData(signature);
        }
    }, [isSuccess, signature, hasSigned]);

    // Reset state when wallet disconnects
    useEffect(() => {
        if (!isConnected) {
            setHasSigned(false);
            setSessionCreated(false);
            setSignedData(null);
        }
    }, [isConnected]);

    if (!isConnected) return null;

    return (
        <div className="grid bg-white border border-gray-200 rounded-lg overflow-hidden shadow-sm mt-4">
            <h3 className="text-sm font-semibold bg-purple-100 p-2 text-center">
                🔐 Create Analytics Session
            </h3>
            <div className="flex flex-col justify-center items-center p-4 space-y-3">
                <div className="text-center space-y-1">
                    <p className="text-xs text-gray-600">
                        Sign a message to create a tracked session in Reown analytics
                    </p>
                    <p className="text-xs text-blue-600">
                        Connected: {address?.slice(0, 6)}...{address?.slice(-4)}
                    </p>
                </div>

                {error && (
                    <div className="text-red-600 text-xs bg-red-50 p-2 rounded max-w-md">
                        <strong>Error:</strong> {error.message}
                    </div>
                )}

                {!hasSigned ? (
                    <button
                        onClick={handleSignMessage}
                        disabled={isPending}
                        className="bg-purple-500 hover:bg-purple-600 disabled:bg-gray-400 text-white px-6 py-2 rounded-lg text-sm font-medium transition-colors"
                    >
                        {isPending ? '✍️ Signing...' : '🖊️ Sign Welcome Message'}
                    </button>
                ) : (
                    <div className="text-center space-y-2">
                        <div className="text-green-600 text-sm font-medium">
                            ✅ Message signed successfully!
                        </div>
                        {signedData && (
                            <div className="text-xs text-gray-600 bg-gray-50 p-2 rounded">
                                Signature: {signedData.slice(0, 20)}...{signedData.slice(-10)}
                            </div>
                        )}
                        {sessionCreated && (
                            <div className="text-blue-600 text-xs">
                                📊 Analytics session created - check your Reown dashboard!
                            </div>
                        )}
                        <div className="text-xs text-gray-500">
                            It may take 30-60 minutes for data to appear in analytics
                        </div>
                    </div>
                )}

                {hasSigned && (
                    <button
                        onClick={() => {
                            setHasSigned(false);
                            setSessionCreated(false);
                            setSignedData(null);
                        }}
                        className="text-xs text-gray-500 hover:text-gray-700 underline"
                    >
                        Sign again
                    </button>
                )}
            </div>
        </div>
    );
}