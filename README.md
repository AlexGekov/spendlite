# Spendlite

## Indexing experiment

Query: latest 20 transactions for one card (100k rows, 5 cards)

- **Without index:** Seq Scan + Sort, 14.387 ms (80,000 rows removed by filter)
- **With `(card_id, created_at DESC)`:** Index Scan, 0.119 ms (~121× faster, no sort)