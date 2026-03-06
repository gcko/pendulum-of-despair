/**
 * jest.setup.js
 * Environment setup run before each test module is loaded.
 * Ensures the test DB uses an in-memory SQLite database.
 */

'use strict';

process.env.DB_PATH = ':memory:';
process.env.JWT_SECRET = 'test-secret-key';
process.env.NODE_NO_WARNINGS = '1';
