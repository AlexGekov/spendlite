import express, { type NextFunction, type Request, type Response } from 'express';
import type { Pool } from 'pg';
import { z } from 'zod';
import { authorize, NotFoundError } from './authorize.js';

const AuthorizeParams = z.object({ cardId: z.uuid() });
const AuthorizeBody = z.object({
  amountMinor: z.number().int().positive(),
  merchant: z.string().min(1).max(200),
});

export function createApp(pool: Pool) {
  const app = express();
  app.use(express.json());

  app.get('/health/live', (_req, res) => {
    res.json({ ok: true });
  });

  app.get('/health/ready', async (_req, res) => {
    try {
      await pool.query('SELECT 1');
      res.json({ ok: true });
    } catch {
      res.status(503).json({ ok: false });
    }
  });

  app.post('/cards/:cardId/authorize', async (req, res) => {
    const { cardId } = AuthorizeParams.parse(req.params);
    const body = AuthorizeBody.parse(req.body);
    const result = await authorize(pool, cardId, body.amountMinor, body.merchant);
    res.json(result);
  });

  // Error middleware: exactly 4 arguments. Express 5 sends errors from async handlers here.
  app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
    if (err instanceof z.ZodError) {
      res.status(400).json({ error: 'Invalid request', issues: err.issues });
      return;
    }
    if (err instanceof NotFoundError) {
      res.status(404).json({ error: err.message });
      return;
    }
    console.error(err);
    res.status(500).json({ error: 'Internal error' });
  });

  return app;
}