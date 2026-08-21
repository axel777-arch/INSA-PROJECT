/**
 * Auth controllers — Member 3
 *
 * Thin layer: request context extraction → service → standard response.
 * Success responses use the agreed wrapper: { "data": ... }
 * Errors are thrown as AppError subclasses and shaped by error.middleware.
 */
import type { Request } from 'express';
import { asyncHandler } from '../../utils/async-handler.js';
import * as authService from './auth.service.js';
import type { LoginInput, RefreshTokenInput, RegisterInput } from './auth.schemas.js';
import type { RequestContext } from './auth.types.js';

function requestContext(req: Request): RequestContext {
  return {
    userAgent: req.headers['user-agent'],
    ip: req.ip,
  };
}

// POST /api/auth/register
export const registerHandler = asyncHandler(async (req, res) => {
  const result = await authService.register(req.body as RegisterInput, requestContext(req));
  res.status(201).json({ data: result });
});

// POST /api/auth/login
export const loginHandler = asyncHandler(async (req, res) => {
  const result = await authService.login(req.body as LoginInput, requestContext(req));
  res.status(200).json({ data: result });
});

// POST /api/auth/refresh  — exchange a refresh token for a new token pair
export const refreshHandler = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body as RefreshTokenInput;
  const result = await authService.refresh(refreshToken);
  res.status(200).json({ data: result });
});

// POST /api/auth/logout — revoke the presented refresh token
export const logoutHandler = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body as RefreshTokenInput;
  await authService.logout(refreshToken);
  res.status(200).json({ data: { message: 'Logged out successfully' } });
});

// GET /api/auth/me — requires a valid (non-expired) access token
export const meHandler = asyncHandler(async (req, res) => {
  const user = await authService.getMe(req.user!.id); // requireAuth guarantees req.user
  res.status(200).json({ data: { user } });
});
