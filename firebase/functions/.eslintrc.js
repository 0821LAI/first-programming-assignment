module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'plugin:import/errors',
    'plugin:import/warnings',
    'plugin:import/typescript',
    'google',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: ['tsconfig.json', 'tsconfig.dev.json'],
    sourceType: 'module',
  },
  rules: {
    // Allow longer lines (up to 120 chars), just warn instead of error
    'max-len': ['warn', { 'code': 120 }],

    // Make spacing inside { } less strict
    'object-curly-spacing': ['warn', 'always'],

    // Don’t force parentheses around arrow function arguments
    'arrow-parens': ['warn', 'as-needed'],
  },
};

