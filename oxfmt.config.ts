import config from '@froko/oxfmt-config'
import { defineConfig } from 'oxfmt'

export default defineConfig({
  ...config,
  // Generated code lives in `generated/` folders and is rewritten by its generator
  ignorePatterns: ['CHANGELOG.md', 'pnpm-lock.yaml', '**/generated/**'],
})
