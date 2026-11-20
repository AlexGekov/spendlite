import 'dotenv/config'
import express from 'express'
import {Pool} from 'pg'

const pool = new Pool({connectionString: process.env.DATABASE_URL})
const app = express()
app.use(express)

app.get("/health/live", (_req, res) => {
    res.json({"ok": true})
})

app.get("/health/readyness", async (_req, res) => {
    try{
        await pool.query('SELECT1')
        res.json({"ok": true})
    }catch{
        res.status(503).json({"ok": false})         
    }
})

app.listen(3000, () => console.log('API on http://localhost:3000'));