/**
 * __tests__/auth.test.ts
 * Tests for the authentication routes: /api/auth/register and /api/auth/login
 */

import request from "supertest";
import { describe, test, expect, beforeEach, afterAll } from "vitest";
import { resetDb } from "../db/init.js";
import app from "../app.js";

beforeEach(() => {
  resetDb();
});

afterAll(() => {
  resetDb();
});

describe("POST /api/auth/register", () => {
  test("creates a new user and returns a token", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "Terra", passphrase: "espers123" });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty("token");
    expect(res.body.username).toBe("Terra");
  });

  test("rejects duplicate username (case-insensitive)", async () => {
    await request(app)
      .post("/api/auth/register")
      .send({ username: "Terra", passphrase: "espers123" });

    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "terra", passphrase: "different123" });

    expect(res.status).toBe(409);
    expect(res.body).toHaveProperty("error");
  });

  test("rejects username that is too short", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "ab", passphrase: "espers123" });

    expect(res.status).toBe(400);
  });

  test("rejects username with invalid characters", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "Terra Branford!", passphrase: "espers123" });

    expect(res.status).toBe(400);
  });

  test("rejects passphrase that is too short", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({ username: "Locke", passphrase: "hi" });

    expect(res.status).toBe(400);
  });

  test("rejects missing body fields", async () => {
    const res = await request(app)
      .post("/api/auth/register")
      .send({});

    expect(res.status).toBe(400);
  });
});

describe("POST /api/auth/login", () => {
  beforeEach(async () => {
    await request(app)
      .post("/api/auth/register")
      .send({ username: "Celes", passphrase: "magitek456" });
  });

  test("returns token on valid credentials", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Celes", passphrase: "magitek456" });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("token");
    expect(res.body.username).toBe("Celes");
  });

  test("rejects wrong passphrase", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Celes", passphrase: "wrongpass" });

    expect(res.status).toBe(401);
  });

  test("rejects unknown username", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Kefka", passphrase: "chaos123" });

    expect(res.status).toBe(401);
  });

  test("rejects missing fields", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .send({ username: "Celes" });

    expect(res.status).toBe(400);
  });
});
