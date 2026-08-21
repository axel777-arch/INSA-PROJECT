"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireRole = requireRole;
exports.requirePermission = requirePermission;
const permissions_js_1 = require("../config/permissions.js");
const errors_js_1 = require("../utils/errors.js");
function requireRole(...roles) {
    return (req, _res, next) => {
        if (!req.user) {
            return next(new errors_js_1.UnauthorizedError());
        }
        if (!roles.includes(req.user.role)) {
            return next(new errors_js_1.ForbiddenError(`This action requires one of the following roles: ${roles.join(', ')}`));
        }
        return next();
    };
}
function requirePermission(permission) {
    return (req, _res, next) => {
        if (!req.user) {
            return next(new errors_js_1.UnauthorizedError());
        }
        if (!(0, permissions_js_1.hasPermission)(req.user.role, permission)) {
            return next(new errors_js_1.ForbiddenError(`Missing required permission: ${permission}`));
        }
        return next();
    };
}
