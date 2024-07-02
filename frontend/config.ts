require('dotenv').config()
import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { http  } from 'wagmi'
import { optimism, mode, base } from 'wagmi/chains'

export const config = getDefaultConfig({
    appName: 'NFT Marketplace',
    projectId: '16956586d2d3a2a7372f4b57330c2896',
    chains: [optimism,mode, base],
    transports: {
        [optimism.id]: http(process.env.OPTIMISM_RPC_URL),
        [mode.id]: http(process.env.MODE_RPC_URL),
        [base.id]: http(process.env.BASE_RPC_URL),
    },
});

