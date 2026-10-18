"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const { once } = require("node:events");
const http = require("node:http");
const app = require("../src/app").default;

async function postWithoutAuthentication(path) {
    const server = app.listen(0);
    await once(server, "listening");
    const address = server.address();
    const port = typeof address === "object" && address ? address.port : 0;
    try {
        return await new Promise((resolve, reject) => {
            const payload = "{}";
            const req = http.request({
                hostname: "127.0.0.1",
                port,
                path,
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Content-Length": Buffer.byteLength(payload),
                },
            }, (res) => {
                res.resume();
                res.on("end", () => resolve(res.statusCode ?? 0));
            });
            req.on("error", reject);
            req.write(payload);
            req.end();
        });
    }
    finally {
        server.close();
    }
}

test("SMS dispatch requires authentication", async () => {
    assert.equal(await postWithoutAuthentication("/api/messaging/sms"), 401);
});

test("farmer targeting requires authentication", async () => {
    assert.equal(await postWithoutAuthentication("/api/targeting/match"), 401);
});

test("IVR simulator requires authentication on both route mounts", async () => {
    assert.equal(await postWithoutAuthentication("/api/simulation/ivr/start"), 401);
    assert.equal(await postWithoutAuthentication("/api/messaging/ivr/start"), 401);
});
