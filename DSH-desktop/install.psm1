pnpm run build:native-system
pnpm exec tsx scripts/generate-typert.ts
tsc -b <tsconfig.host.json references>
tsdown --env.DSH_BUILD_FACE host
pnpm --filter @deepseek-ai/dsh-desktop run bundle
tsc -b <tsconfig.client.json references>
tsdown --env.DSH_BUILD_FACE client
pnpm run build:web
