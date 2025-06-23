const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');

router.post('/register', async (req, res) => {
  const { name, password } = req.body;
  try {
    const userCheck = await pool.query('SELECT * FROM customers WHERE name = $1', [name]);
    if (userCheck.rows.length > 0) return res.status(400).json({ error: 'Customer already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);
    await pool.query('INSERT INTO customers (name, password) VALUES ($1, $2)', [name, hashedPassword]);

    res.status(201).json({ message: 'Registered successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

router.post('/login', async (req, res) => {
  const { name, password } = req.body;
  try {
    const result = await pool.query('SELECT * FROM customers WHERE name = $1', [name]);
    const customer = result.rows[0];
    if (!customer) return res.status(400).json({ error: 'Invalid name or password' });

    const isValid = await bcrypt.compare(password, customer.password);
    if (!isValid) return res.status(400).json({ error: 'Invalid name or password' });

    const token = jwt.sign({ id: customer.id, name: customer.name }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ message: 'Login successful', token });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
