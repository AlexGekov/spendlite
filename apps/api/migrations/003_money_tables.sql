CREATE TABLE transactions (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id      uuid        NOT NULL REFERENCES cards(id),
  amount_minor bigint      NOT NULL CHECK (amount_minor > 0),
  currency     char(3)     NOT NULL,
  merchant     text        NOT NULL,
  status       text        NOT NULL CHECK (status IN ('authorized', 'declined', 'settled', 'reversed')),
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX transactions_card_created_idx ON transactions (card_id, created_at DESC);

CREATE TABLE ledger_entries (
  id             bigserial   PRIMARY KEY,
  transaction_id uuid        NOT NULL REFERENCES transactions(id),
  account        text        NOT NULL,
  amount_minor   bigint      NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE outbox (
  id           bigserial   PRIMARY KEY,
  event_id     uuid        NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  topic        text        NOT NULL,
  key          text        NOT NULL,
  payload      jsonb       NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now(),
  published_at timestamptz
);
CREATE INDEX outbox_unpublished_idx ON outbox (id) WHERE published_at IS NULL;

CREATE TABLE processed_events (
  event_id     uuid        PRIMARY KEY,
  processed_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE idempotency_keys (
  company_id    uuid        NOT NULL REFERENCES companies(id),
  key           text        NOT NULL,
  request_hash  text        NOT NULL,
  status        text        NOT NULL CHECK (status IN ('processing', 'completed')),
  response_code int,
  response_body jsonb,
  created_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (company_id, key)
);