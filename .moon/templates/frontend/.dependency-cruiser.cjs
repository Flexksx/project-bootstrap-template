const base = require('../../config/dependency-cruiser.base.cjs');

/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  ...base,
  forbidden: [
    ...base.forbidden,
    {
      name: 'no-cross-domain-endpoints',
      severity: 'error',
      from: { path: '^src/lib/domains/([^/]+)/contracts/endpoints' },
      to: { path: '^src/lib/domains/([^/]+)/contracts/endpoints', pathNot: '^src/lib/domains/$1/' },
    },
    {
      name: 'no-cross-domain-queries',
      severity: 'error',
      from: { path: '^src/lib/domains/([^/]+)/queries' },
      to: { path: '^src/lib/domains/([^/]+)/queries', pathNot: '^src/lib/domains/$1/' },
    },
    {
      name: 'no-cross-domain-mutations',
      severity: 'error',
      from: { path: '^src/lib/domains/([^/]+)/mutations' },
      to: { path: '^src/lib/domains/([^/]+)/mutations', pathNot: '^src/lib/domains/$1/' },
    },
    {
      name: 'no-components-import-endpoints',
      severity: 'error',
      from: { path: '\\.(svelte|vue)$' },
      to: { path: '/contracts/endpoints' },
    },
  ],
};
