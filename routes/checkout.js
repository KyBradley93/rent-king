const express = require('express');
const router = express.Router();
const pool = require('../db');
const authenticateCustomer = require('../middleware/auth');

router.post('/', authenticateCustomer, async (req, res) => {
  const customerId = req.customer.id;

  const cartRes = await pool.query('SELECT id FROM carts WHERE customer_id = $1', [customerId]);
  if (cartRes.rows.length === 0) return res.status(400).json({ error: 'No cart found' });

  const cartId = cartRes.rows[0].id;

  try {
    const result = await pool.query('SELECT finalize_checkout($1, $2) AS checkout_id', [cartId, customerId]);
    res.status(201).json({ message: 'Checkout successful', checkout_id: result.rows[0].checkout_id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Checkout failed' });
  }
});

module.exports = router;
