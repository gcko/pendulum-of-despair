/** POST /api/auth/register & /api/auth/login request body */
export interface AuthRequestBody {
  username: string;
  passphrase: string;
}

/** POST /api/auth/register response (201) */
export interface AuthResponse {
  token: string;
  username: string;
}

/** JWT payload (decoded token) */
export interface JwtPayload {
  sub: number;
  username: string;
  iat: number;
  exp: number;
}

/** Generic API error response */
export interface ApiError {
  error: string;
}

/** PUT /api/save/:slot success response */
export interface SaveSuccessResponse {
  success: true;
  slot: number;
}

/** Health check response */
export interface HealthResponse {
  status: "ok";
}

/** Valid save slot numbers */
export type SaveSlot = 1 | 2 | 3;
export const VALID_SLOTS: readonly SaveSlot[] = [1, 2, 3] as const;
export const MAX_SAVE_BYTES = 512 * 1024;

/** Auth validation constants */
export const USERNAME_MIN = 3;
export const USERNAME_MAX = 32;
export const PASSPHRASE_MIN = 6;
export const PASSPHRASE_MAX = 128;
