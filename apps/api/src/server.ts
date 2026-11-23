import 'dotenv/config';
import { Pool } from 'pg';
import { createApp } from './app.js';

const pool = new Pool({ connectionString: process.env.DATABASE_URL, connectionTimeoutMillis: 2000 });

createApp(pool).listen(3000, () => console.log('API on http://localhost:3000'));