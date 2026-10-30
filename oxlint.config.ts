import config from '@froko/oxlint-config'
import { defineConfig } from 'oxlint'

export default defineConfig({
  extends: [config],
  ignorePatterns: ['**/generated/**'],
})
