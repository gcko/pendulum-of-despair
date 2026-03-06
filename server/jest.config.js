/**
 * jest.config.js
 * Jest configuration for the Pendulum of Despair server tests.
 */

'use strict';

module.exports = {
  testEnvironment: 'node',
  forceExit: true,
  setupFiles: ['./jest.setup.js'],
};
