const express = require('express');
const bcrypt = require('bcryptjs');
const app = express()
const port = 3000
const pool = require('.');

app.use(express.json());

app.get('/', async (req, res) => {
  try {
    const results = await pool.query('SELECT * FROM tvs');
    const tvs = results.rows;
    res.send(`
    <h1>Hello Fucking World!</h1>
    <h2>Test Data from "tvs"</h2>
    <pre>${JSON.stringify(tvs, null, 2)}</pre>
  `);
  } catch (err) {
    console.error('error querying tvs', err);
    res.status(500).send('Error: Could not query tvs table')
  }
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})


