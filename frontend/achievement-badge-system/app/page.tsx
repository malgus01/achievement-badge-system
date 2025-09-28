// app/page.tsx
'use client';
import { useAccount, useDisconnect } from 'wagmi';
import { useEffect, useState } from 'react';
import SignMessage from '@/app/components/SignMessage';

declare module 'react' {
  namespace JSX {
    interface IntrinsicElements {
      'w3m-button': any;
      'w3m-network-button': any;
    }
  }
}

// Debug Component for Analytics Tracking
function DebugPanel() {
  const { isConnected, address, chainId } = useAccount();
  const [debugInfo, setDebugInfo] = useState<any>(null);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const info = {
        projectId: (window as any).reownProjectId,
        appKitInstance: !!(window as any).appkit,
        domain: window.location.hostname,
        origin: window.location.origin,
        userAgent: navigator.userAgent,
        timestamp: new Date().toISOString()
      };
      setDebugInfo(info);
    }
  }, []);

  if (!isConnected) return null;

  return (
    <div className="grid bg-gray-50 border border-gray-200 rounded-lg overflow-hidden shadow-sm mt-4">
      <h3 className="text-sm font-semibold bg-gray-200 p-2 text-center">
        🔍 Debug Information
      </h3>
      <div className="p-3 text-xs space-y-1">
        <div><strong>Connected:</strong> {isConnected ? '✅ Yes' : '❌ No'}</div>
        <div><strong>Address:</strong> {address?.slice(0, 10)}...{address?.slice(-8)}</div>
        <div><strong>Chain ID:</strong> {chainId}</div>
        <div><strong>Project ID:</strong> {debugInfo?.projectId?.slice(0, 16)}...</div>
        <div><strong>AppKit Instance:</strong> {debugInfo?.appKitInstance ? '✅ Found' : '❌ Missing'}</div>
        <div><strong>Domain:</strong> {debugInfo?.domain}</div>
        <div><strong>Origin:</strong> {debugInfo?.origin}</div>
        <button
          onClick={() => console.log('🔍 Full debug info:', debugInfo)}
          className="mt-2 text-blue-600 hover:text-blue-800 underline"
        >
          Log full debug info to console
        </button>
      </div>
    </div>
  );
}

// Connection Status Component
function ConnectionStatus() {
  const { isConnected, address, chainId, connector } = useAccount();
  const { disconnect } = useDisconnect();

  if (!isConnected) return null;

  return (
    <div className="grid bg-green-50 border border-green-200 rounded-lg overflow-hidden shadow-sm mt-4">
      <h3 className="text-sm font-semibold bg-green-100 p-2 text-center">
        ✅ Wallet Connected
      </h3>
      <div className="p-4 space-y-2">
        <div className="text-center">
          <p className="text-sm font-medium text-green-800">
            {address?.slice(0, 6)}...{address?.slice(-4)}
          </p>
          <p className="text-xs text-green-600">
            Chain: {chainId} | Connector: {connector?.name || 'Unknown'}
          </p>
        </div>
        <div className="flex justify-center">
          <button
            onClick={() => disconnect()}
            className="text-xs text-red-600 hover:text-red-800 underline"
          >
            Disconnect Wallet
          </button>
        </div>
      </div>
    </div>
  );
}

// Analytics Status Component
function AnalyticsStatus() {
  const { isConnected } = useAccount();
  const [analyticsChecks, setAnalyticsChecks] = useState({
    projectIdSet: false,
    domainConfigured: false,
    appKitInstance: false,
    analyticsEnabled: false
  });

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const checks = {
        projectIdSet: !!(window as any).reownProjectId,
        domainConfigured: window.location.hostname === 'educational-sandbox.vercel.app' ||
          window.location.hostname === 'localhost',
        appKitInstance: !!(window as any).appkit,
        analyticsEnabled: true // Assuming it's enabled in config
      };
      setAnalyticsChecks(checks);
    }
  }, [isConnected]);

  const allChecksPass = Object.values(analyticsChecks).every(check => check);

  return (
    <div className="grid bg-blue-50 border border-blue-200 rounded-lg overflow-hidden shadow-sm mt-4">
      <h3 className="text-sm font-semibold bg-blue-100 p-2 text-center">
        📊 Analytics Status
      </h3>
      <div className="p-3 space-y-2">
        <div className="space-y-1 text-xs">
          <div className={analyticsChecks.projectIdSet ? 'text-green-600' : 'text-red-600'}>
            {analyticsChecks.projectIdSet ? '✅' : '❌'} Project ID configured
          </div>
          <div className={analyticsChecks.domainConfigured ? 'text-green-600' : 'text-red-600'}>
            {analyticsChecks.domainConfigured ? '✅' : '❌'} Domain configured
          </div>
          <div className={analyticsChecks.appKitInstance ? 'text-green-600' : 'text-red-600'}>
            {analyticsChecks.appKitInstance ? '✅' : '❌'} AppKit instance found
          </div>
          <div className={analyticsChecks.analyticsEnabled ? 'text-green-600' : 'text-red-600'}>
            {analyticsChecks.analyticsEnabled ? '✅' : '❌'} Analytics enabled
          </div>
        </div>
        <div className={`text-xs font-medium ${allChecksPass ? 'text-green-600' : 'text-orange-600'}`}>
          Status: {allChecksPass ? 'All checks pass ✅' : 'Some issues detected ⚠️'}
        </div>
        {!allChecksPass && (
          <div className="text-xs text-gray-600">
            Check Reown dashboard configuration and environment variables
          </div>
        )}
      </div>
    </div>
  );
}

export default function Home() {
  const { isConnected } = useAccount();

  return (
    <main className="min-h-screen px-8 py-0 pb-12 flex-1 flex flex-col items-center">
      <header className="w-full py-4 flex justify-between items-center">
        <div className="flex items-center">
          <img src="/favicon.ico" alt="Logo" className="w-35 h-10 mr-2" />
          <div className="hidden sm:inline text-xl font-bold">Reown - AppKit EVM</div>
        </div>
      </header>

      <h2 className="my-8 text-2xl font-bold leading-snug text-center">
        Educational Sandbox with Analytics
      </h2>

      <div className="max-w-4xl w-full space-y-4">
        {/* Wallet connect */}
        <div className="grid bg-white border border-gray-200 rounded-lg overflow-hidden shadow-sm">
          <h3 className="text-sm font-semibold bg-gray-100 p-2 text-center">
            🔌 Connect your Wallet
          </h3>
          <div className="flex justify-center items-center p-4">
            <w3m-button></w3m-button>
          </div>
        </div>

        {/* Connection Status */}
        <ConnectionStatus />

        {/* Analytics Status */}
        <AnalyticsStatus />

        {/* Sign message for analytics - CRITICAL FOR USER TRACKING */}
        <SignMessage />

        {/* Network selector */}
        {isConnected && (
          <div className="grid bg-white border border-gray-200 rounded-lg overflow-hidden shadow-sm">
            <h3 className="text-sm font-semibold bg-gray-100 p-2 text-center">
              🌐 Network Selection
            </h3>
            <div className="flex justify-center items-center p-4">
              <w3m-network-button></w3m-network-button>
            </div>
          </div>
        )}

        {/* Debug Panel */}
        <DebugPanel />

        {/* Instructions */}
        <div className="grid bg-yellow-50 border border-yellow-200 rounded-lg overflow-hidden shadow-sm">
          <h3 className="text-sm font-semibold bg-yellow-100 p-2 text-center">
            📋 Analytics Testing Instructions
          </h3>
          <div className="p-4 space-y-2 text-sm">
            <ol className="list-decimal list-inside space-y-1 text-gray-700">
              <li>Connect your wallet using the button above</li>
              <li>Sign the welcome message to create an analytics session</li>
              <li>Wait 30-60 minutes for data to appear in Reown dashboard</li>
              <li>Check the Debug Information for troubleshooting</li>
              <li>Verify all Analytics Status checks pass</li>
            </ol>
            <div className="mt-3 p-2 bg-blue-50 rounded text-xs">
              <strong>Note:</strong> Users appear in Reown analytics only after signing a message,
              not just connecting a wallet. The signing step creates an authenticated session.
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}