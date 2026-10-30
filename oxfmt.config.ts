import config from '@froko/oxfmt-config'
import { defineConfig } from 'oxfmt'

export default defineConfig({
  ...config,
  // Generated code lives in `generated/` folders and is rewritten by its generator
  ignorePatterns: ['CHANGELOG.md', 'pnpm-lock.yaml', '**/generated/**'],
  overrides: [
    ...(config.overrides ?? []),
    // Agent and skill files: keep frontmatter values such as `description` on
    // one line, as the agent tooling expects
    { files: ['.claude/**/*.md'], options: { proseWrap: 'preserve' } },
  ],
})
