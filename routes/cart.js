const express = require('express');
const router = express.Router();
const pool = require('../db');
const authenticateCustomer = require('../middleware/auth');

router.get('/', authenticateCustomer, async (req, res) => {
  const result = await pool.query(`
    SELECT ci.*, af.name, af.price
    FROM cart_items ci
    JOIN all_furniture af ON ci.furniture_item_id = af.id
    JOIN cart c ON ci.cart_id = c.id
    WHERE c.customer_id = $1
  `, [req.customer.id]);
  res.json(result.rows);
});

router.post('/items', authenticateCustomer, async (req, res) => {
  const { furniture_item_id, quantity } = req.body;

  // Ensure cart exists
  let cartResult = await pool.query('SELECT * FROM cart WHERE customer_id = $1', [req.customer.id]);
  let cartId;
  if (cartResult.rows.length === 0) {
    const newCart = await pool.query('INSERT INTO cart (customer_id) VALUES ($1) RETURNING id', [req.customer.id]);
    cartId = newCart.rows[0].id;
  } else {
    cartId = cartResult.rows[0].id;
  }

  await pool.query(
    'INSERT INTO cart_items (cart_id, furniture_item_id, quantity) VALUES ($1, $2, $3)',
    [cartId, furniture_item_id, quantity]
  );
  res.status(201).json({ message: 'Item added to cart' });
});

module.exports = router;
