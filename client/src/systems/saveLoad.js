/**
 * systems/saveLoad.js
 * Handles communication with the backend save/load API.
 * Also manages the local JWT token in sessionStorage.
 */

const API_BASE = window.GAME_API_BASE || 'http://localhost:3000';

/** @type {string|null} */
let _token = sessionStorage.getItem('pod_token') || null;
/** @type {string|null} */
let _username = sessionStorage.getItem('pod_username') || null;

/**
 * @typedef {Object} SaveSummary
 * @property {number}  slot
 * @property {boolean} [empty]
 * @property {number}  [playtime]
 * @property {string}  [location]
 * @property {Array}   [party]
 */

/**
 * Returns the currently authenticated username, or null.
 * @returns {string|null}
 */
export function getUsername() {
  return _username;
}

/**
 * Returns true if the user is currently logged in.
 * @returns {boolean}
 */
export function isLoggedIn() {
  return Boolean(_token);
}

/**
 * Logs out the current user by clearing the stored token.
 */
export function logout() {
  _token = null;
  _username = null;
  sessionStorage.removeItem('pod_token');
  sessionStorage.removeItem('pod_username');
}

/**
 * Registers a new account.
 * @param {string} username
 * @param {string} passphrase
 * @returns {Promise<{ token: string, username: string }>}
 */
export async function register(username, passphrase) {
  const res = await fetch(`${API_BASE}/api/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, passphrase }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Registration failed');
  _token = data.token;
  _username = data.username;
  sessionStorage.setItem('pod_token', _token);
  sessionStorage.setItem('pod_username', _username);
  return data;
}

/**
 * Logs in with an existing account.
 * @param {string} username
 * @param {string} passphrase
 * @returns {Promise<{ token: string, username: string }>}
 */
export async function login(username, passphrase) {
  const res = await fetch(`${API_BASE}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, passphrase }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Login failed');
  _token = data.token;
  _username = data.username;
  sessionStorage.setItem('pod_token', _token);
  sessionStorage.setItem('pod_username', _username);
  return data;
}

/**
 * Lists all save slot summaries for the current user.
 * @returns {Promise<SaveSummary[]>}
 */
export async function listSaves() {
  const res = await fetch(`${API_BASE}/api/save`, {
    headers: { Authorization: `Bearer ${_token}` },
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Failed to load saves');
  return data;
}

/**
 * Loads a specific save slot.
 * @param {number} slot
 * @returns {Promise<{ slot: number, data: Object }>}
 */
export async function loadSave(slot) {
  const res = await fetch(`${API_BASE}/api/save/${slot}`, {
    headers: { Authorization: `Bearer ${_token}` },
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Failed to load save');
  return data;
}

/**
 * Writes game state to a save slot.
 * @param {number} slot
 * @param {Object} gameState
 * @returns {Promise<{ success: boolean, slot: number }>}
 */
export async function writeSave(slot, gameState) {
  const res = await fetch(`${API_BASE}/api/save/${slot}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${_token}`,
    },
    body: JSON.stringify(gameState),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || 'Failed to save game');
  return data;
}
