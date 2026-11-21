BEGIN;

TRUNCATE companies, employees, cards, transactions, ledger_entries, idempotency_keys CASCADE;

INSERT INTO companies (name) VALUES ('Acme Ltd'), ('Globex EOOD');

INSERT INTO employees (company_id, name)
SELECT c.id, v.name
FROM (VALUES
  ('Acme Ltd',    'Ana'),
  ('Acme Ltd',    'Boris'),
  ('Acme Ltd',    'Vera'),
  ('Globex EOOD', 'Georgi'),
  ('Globex EOOD', 'Dimitar'),
  ('Globex EOOD', 'Elena')
) AS v(company_name, name)
JOIN companies c ON c.name = v.company_name;

-- 5 cards for 6 employees: Elena gets no card on purpose (for query 3)
INSERT INTO cards (company_id, employee_id, currency, monthly_limit_minor)
SELECT e.company_id, e.id, 'EUR', v.limit_minor
FROM (VALUES
  ('Ana',      50000),   -- €500.00
  ('Boris',   100000),   -- €1,000.00
  ('Vera',     20000),   -- €200.00
  ('Georgi',  300000),   -- €3,000.00
  ('Dimitar',  10000)    -- €100.00
) AS v(name, limit_minor)
JOIN employees e ON e.name = v.name;

COMMIT;