const express = require('express');
const router = express.Router();
const pool = require('../db');
const authenticateCustomer = require('../middleware/auth');

router.post('/', authenticateCustomer, async (req, res) => {
  const customerId = req.customer.id;

  const cartRes = await pool.query('SELECT id FROM cart WHERE customer_id = $1', [customerId]);
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

router.get('/:id', authenticateCustomer, async (req, res) => {
  const checkoutId = req.params.id;

  const result = await pool.query(`
    SELECT c.id AS checkout_id, c.total_price, c.created_at,
           ci.furniture_item_id, af.name, ci.quantity, ci.unit_price
    FROM checkout c
    JOIN checkout_items ci ON c.id = ci.checkout_id
    JOIN all_furniture af ON ci.furniture_item_id = af.id
    WHERE c.id = $1 AND c.customer_id = $2
  `, [checkoutId, req.customer.id]);

  res.json(result.rows);
});


module.exports = router;
