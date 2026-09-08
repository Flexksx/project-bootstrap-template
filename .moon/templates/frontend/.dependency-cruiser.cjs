const base = require('../../config/dependency-cruiser.base.cjs');

/** @type {import('dependency-cruiser').IConfiguration} */
module.exports = {
  ...base,
  forbidden: [
    ...base.forbidden,
  ],
};
