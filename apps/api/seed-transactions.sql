BEGIN;

INSERT INTO transactions (card_id, amount_minor, currency, merchant, status, created_at)
SELECT
  c.id,
  (random() * 20000 + 100)::bigint,
  'EUR',
  (ARRAY['Uber', 'AWS', 'Lidl', 'Shell', 'Wizz Air', 'Booking.com'])[floor(random() * 6 + 1)],
  'settled',
  now() - random() * interval '90 days'
FROM generate_series(1, 20000) AS g
CROSS JOIN cards c;

COMMIT;

ANALYZE transactions;