const express = require('express');
const router = express.Router();
const pool = require('../db');

const validTypes = ['beds', 'night_stands', 'dressers', 'couches', 'tvs', 'tables'];

router.get('/', async (req, res) => {
  const result = await pool.query('SELECT * FROM all_furniture');
  res.json(result.rows);
});

router.get('/:type', async (req, res) => {
  const { type } = req.params;
  if (!validTypes.includes(type)) return res.status(400).json({ error: 'Invalid category' });

  const result = await pool.query(`SELECT * FROM ${type}`);
  res.json(result.rows);
});

router.get('/:type/:id', async (req, res) => {
  const { type, id } = req.params;
  if (!validTypes.includes(type)) return res.status(400).json({ error: 'Invalid category' });

  const result = await pool.query(`SELECT * FROM ${type} WHERE id = $1`, [id]);
  if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
  res.json(result.rows[0]);
});

module.exports = router;
