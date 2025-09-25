// app/config/index.tsx
import { cookieStorage, createStorage } from "wagmi";
import { WagmiAdapter } from "@reown/appkit-adapter-wagmi";
import { mainnet, base, optimism } from "@reown/appkit/networks";

export const projectId = process.env.NEXT_PUBLIC_PROJECT_ID;

if (!projectId) {
    throw new Error("NEXT_PUBLIC_PROJECT_ID is not defined");
}

export const networks = [mainnet, optimism, base];

export const wagmiAdapter = new WagmiAdapter({
    storage: createStorage({
        storage: cookieStorage,
    }),
    ssr: true,
    networks,
    projectId,
});

export const config = wagmiAdapter.wagmiConfig;