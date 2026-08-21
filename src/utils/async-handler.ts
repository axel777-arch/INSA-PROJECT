/**
 * asyncHandler — wraps async Express handlers so rejected promises reach the
 * centralized error middleware instead of crashing the process.
 *
 * Team convention (agreed controller pattern):
 *   export const myHandler = asyncHandler(async (req, res) => { ... });
 */
import type { NextFunction, Request, RequestHandler, Response } from 'express';

type AsyncRequestHandler = (req: Request, res: Response, next: NextFunction) => Promise<unknown>;

export function asyncHandler(fn: AsyncRequestHandler): RequestHandler {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
