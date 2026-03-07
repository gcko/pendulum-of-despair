/**
 * index.ts
 * Entry point for the Pendulum of Despair API server.
 */

import { getDb } from "./db/init.js";
import app from "./app.js";

getDb(); // Ensures tables are created on startup

const PORT = parseInt(process.env["PORT"] ?? "3000", 10);
app.listen(PORT, () => {
  console.log(`[server] Pendulum of Despair API listening on http://localhost:${String(PORT)}`);
});
