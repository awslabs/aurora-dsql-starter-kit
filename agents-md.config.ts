import type { AgentsMdConfig } from 'agents-md'

export default {
  include: [
    '**/agents-md/**/*.md',
    '**/*.agents.md',
    'documentation/docs/**/*.md',
    'README.md',
  ],
  exclude: [
    'documentation/docs/.snippets/**',
    'node_modules/**',
    'site/**',
    '.cache/**',
  ],
} satisfies AgentsMdConfig
