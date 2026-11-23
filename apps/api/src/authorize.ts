import type { Pool } from 'pg';

export class NotFoundError extends Error {}

export async function authorize(pool: Pool, cardId: string, amountMinor: number, merchant: string) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Check the limit and reserve the money in ONE statement
    const reserved = await client.query(
      `UPDATE cards
          SET spent_this_month_minor = spent_this_month_minor + $2
        WHERE id = $1
          AND spent_this_month_minor + $2 <= monthly_limit_minor
        RETURNING id`,
      [cardId, amountMinor],
    );
    const status = reserved.rowCount === 1 ? 'authorized' : 'declined';

    // 2. Record the attempt either way. 0 rows inserted = the card doesn't exist
    const inserted = await client.query(
      `INSERT INTO transactions (card_id, amount_minor, currency, merchant, status)
       SELECT id, $2, currency, $3, $4 FROM cards WHERE id = $1
       RETURNING id`,
      [cardId, amountMinor, merchant, status],
    );
    if (inserted.rowCount === 0) throw new NotFoundError('Card not found');

    await client.query('COMMIT');
    return { transactionId: inserted.rows[0].id as string, status };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}