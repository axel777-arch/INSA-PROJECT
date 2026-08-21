"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = void 0;
const token_service_js_1 = require("../modules/auth/token.service.js");
const errors_js_1 = require("../utils/errors.js");
const requireAuth = (req, _res, next) => {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
        return next(new errors_js_1.UnauthorizedError('Missing or malformed Authorization header (expected "Bearer <token>")'));
    }
    const token = header.slice('Bearer '.length).trim();
    if (!token) {
        return next(new errors_js_1.UnauthorizedError('Missing access token'));
    }
    try {
        const payload = (0, token_service_js_1.verifyAccessToken)(token);
        req.user = { id: payload.sub, role: payload.role };
        return next();
    }
    catch (err) {
        // verifyAccessToken already throws AppError subclasses with the right codes
        // (TOKEN_EXPIRED for expired, UNAUTHENTICATED for invalid).
        return next(err);
    }
};
exports.requireAuth = requireAuth;
