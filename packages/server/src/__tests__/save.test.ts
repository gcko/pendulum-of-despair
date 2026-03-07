/**
 * __tests__/save.test.ts
 * Tests for the save/load routes: /api/save
 */

import request from "supertest";
import { describe, test, expect, beforeEach, afterAll } from "vitest";
import { resetDb } from "../db/init.js";
import app from "../app.js";

let token: string;

const SAMPLE_SAVE = {
  party: [
    { id: "terra", name: "Terra", level: 5, hp: 120, mp: 60 },
    { id: "locke", name: "Locke", level: 5, hp: 110, mp: 20 },
  ],
  inventory: [{ itemId: "potion", qty: 3 }],
  gp: 500,
  worldFlags: { intro_complete: true },
  currentMap: "narshe",
  currentPosition: { x: 10, y: 8 },
  playtime: 900,
};

beforeEach(async () => {
  resetDb();
  // Register a fresh user and capture token
  const res = await request(app)
    .post("/api/auth/register")
    .send({ username: "Shadow", passphrase: "interceptor99" });
  token = res.body.token as string;
});

afterAll(() => {
  resetDb();
});

describe("GET /api/save", () => {
  test("returns three empty slots for a new user", async () => {
    const res = await request(app)
      .get("/api/save")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(3);
    expect(res.body.every((s: { empty?: boolean }) => s.empty)).toBe(true);
  });

  test("requires authentication", async () => {
    const res = await request(app).get("/api/save");
    expect(res.status).toBe(401);
  });
});

describe("PUT /api/save/:slot", () => {
  test("saves data to slot 1", async () => {
    const res = await request(app)
      .put("/api/save/1")
      .set("Authorization", `Bearer ${token}`)
      .send(SAMPLE_SAVE);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test("rejects invalid slot numbers", async () => {
    const res = await request(app)
      .put("/api/save/5")
      .set("Authorization", `Bearer ${token}`)
      .send(SAMPLE_SAVE);

    expect(res.status).toBe(400);
  });

  test("rejects array body", async () => {
    const res = await request(app)
      .put("/api/save/1")
      .set("Authorization", `Bearer ${token}`)
      .send([SAMPLE_SAVE]);

    expect(res.status).toBe(400);
  });

  test("requires authentication", async () => {
    const res = await request(app)
      .put("/api/save/1")
      .send(SAMPLE_SAVE);

    expect(res.status).toBe(401);
  });
});

describe("GET /api/save/:slot", () => {
  beforeEach(async () => {
    await request(app)
      .put("/api/save/2")
      .set("Authorization", `Bearer ${token}`)
      .send(SAMPLE_SAVE);
  });

  test("loads saved data from slot 2", async () => {
    const res = await request(app)
      .get("/api/save/2")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    expect(res.body.slot).toBe(2);
    expect(res.body.data.currentMap).toBe("narshe");
    expect(res.body.data.playtime).toBe(900);
  });

  test("returns 404 for an empty slot", async () => {
    const res = await request(app)
      .get("/api/save/3")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(404);
  });

  test("reflects saved data in slot listing", async () => {
    const res = await request(app)
      .get("/api/save")
      .set("Authorization", `Bearer ${token}`);

    expect(res.status).toBe(200);
    const slot2 = res.body.find((s: { slot: number }) => s.slot === 2);
    expect(slot2.empty).toBeFalsy();
    expect(slot2.location).toBe("narshe");
    expect(slot2.playtime).toBe(900);
  });

  test("overwrites existing save on second PUT", async () => {
    await request(app)
      .put("/api/save/2")
      .set("Authorization", `Bearer ${token}`)
      .send({ ...SAMPLE_SAVE, playtime: 1800, currentMap: "opera_house" });

    const res = await request(app)
      .get("/api/save/2")
      .set("Authorization", `Bearer ${token}`);

    expect(res.body.data.playtime).toBe(1800);
    expect(res.body.data.currentMap).toBe("opera_house");
  });
});
