CREATE TABLE employees (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid NOT NULL REFERENCES companies(id),
  name       text NOT NULL
);

CREATE TABLE cards (
  id                     uuid    PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id             uuid    NOT NULL REFERENCES companies(id),
  employee_id            uuid    NOT NULL REFERENCES employees(id),
  currency               char(3) NOT NULL,
  monthly_limit_minor    bigint  NOT NULL CHECK (monthly_limit_minor >= 0),
  spent_this_month_minor bigint  NOT NULL DEFAULT 0 CHECK (spent_this_month_minor >= 0)
);