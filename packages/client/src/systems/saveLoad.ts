/**
 * systems/saveLoad.ts
 * Handles communication with the backend save/load API.
 * Also manages the local JWT token in sessionStorage.
 */

import type { AuthResponse, SaveSlotSummary, SaveSlotFull, SaveSuccessResponse, GameSaveState } from "@pendulum/shared";

const API_BASE = (window as { GAME_API_BASE?: string }).GAME_API_BASE ?? "";

let _token: string | null = sessionStorage.getItem("pod_token");
let _username: string | null = sessionStorage.getItem("pod_username");

/**
 * Returns the currently authenticated username, or null.
 */
export function getUsername(): string | null {
  return _username;
}

/**
 * Returns true if the user is currently logged in.
 */
export function isLoggedIn(): boolean {
  return Boolean(_token);
}

/**
 * Logs out the current user by clearing the stored token.
 */
export function logout(): void {
  _token = null;
  _username = null;
  sessionStorage.removeItem("pod_token");
  sessionStorage.removeItem("pod_username");
}

/**
 * Registers a new account.
 */
export async function register(username: string, passphrase: string): Promise<AuthResponse> {
  const res = await fetch(`${API_BASE}/api/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, passphrase }),
  });
  const data: unknown = await res.json();
  if (!res.ok) {
    const err = data as { error?: string };
    throw new Error(err.error ?? "Registration failed");
  }
  const authData = data as AuthResponse;
  _token = authData.token;
  _username = authData.username;
  sessionStorage.setItem("pod_token", _token);
  sessionStorage.setItem("pod_username", _username);
  return authData;
}

/**
 * Logs in with an existing account.
 */
export async function login(username: string, passphrase: string): Promise<AuthResponse> {
  const res = await fetch(`${API_BASE}/api/auth/login`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, passphrase }),
  });
  const data: unknown = await res.json();
  if (!res.ok) {
    const err = data as { error?: string };
    throw new Error(err.error ?? "Login failed");
  }
  const authData = data as AuthResponse;
  _token = authData.token;
  _username = authData.username;
  sessionStorage.setItem("pod_token", _token);
  sessionStorage.setItem("pod_username", _username);
  return authData;
}

/**
 * Lists all save slot summaries for the current user.
 */
export async function listSaves(): Promise<SaveSlotSummary[]> {
  if (!_token) throw new Error("Not authenticated");
  const res = await fetch(`${API_BASE}/api/save`, {
    headers: { Authorization: `Bearer ${_token}` },
  });
  const data: unknown = await res.json();
  if (!res.ok) {
    const err = data as { error?: string };
    throw new Error(err.error ?? "Failed to load saves");
  }
  return data as SaveSlotSummary[];
}

/**
 * Loads a specific save slot.
 */
export async function loadSave(slot: number): Promise<SaveSlotFull> {
  if (!_token) throw new Error("Not authenticated");
  const res = await fetch(`${API_BASE}/api/save/${slot}`, {
    headers: { Authorization: `Bearer ${_token}` },
  });
  const data: unknown = await res.json();
  if (!res.ok) {
    const err = data as { error?: string };
    throw new Error(err.error ?? "Failed to load save");
  }
  return data as SaveSlotFull;
}

/**
 * Writes game state to a save slot.
 */
export async function writeSave(slot: number, gameState: GameSaveState): Promise<SaveSuccessResponse> {
  if (!_token) throw new Error("Not authenticated");
  const res = await fetch(`${API_BASE}/api/save/${slot}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${_token}`,
    },
    body: JSON.stringify(gameState),
  });
  const data: unknown = await res.json();
  if (!res.ok) {
    const err = data as { error?: string };
    throw new Error(err.error ?? "Failed to save game");
  }
  return data as SaveSuccessResponse;
}
