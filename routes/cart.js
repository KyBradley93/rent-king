const express = require('express');
const router = express.Router();
const pool = require('../db');
const authenticateCustomer = require('../middleware/auth');

/**
 * @swagger
 * /api/cart:
 *   get:
 *     summary: Get all items in the authenticated customer's cart
 *     tags:
 *       - Cart
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: A list of cart items with product details
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: integer
 *                   cart_id:
 *                     type: integer
 *                   furniture_item_id:
 *                     type: integer
 *                   quantity:
 *                     type: integer
 *                   name:
 *                     type: string
 *                   price:
 *                     type: string
 *             examples:
 *               sampleCart:
 *                 value:
 *                   - id: 1
 *                     cart_id: 1
 *                     furniture_item_id: 10
 *                     quantity: 1
 *                     name: pullout_couch
 *                     price: "600.00"
 */


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

/**
 * @swagger
 * /api/cart/items:
 *   post:
 *     summary: Add a furniture item to the authenticated customer's cart
 *     tags:
 *       - Cart
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - furniture_item_id
 *               - quantity
 *             properties:
 *               furniture_item_id:
 *                 type: integer
 *                 example: 10
 *               quantity:
 *                 type: integer
 *                 example: 1
 *     responses:
 *       201:
 *         description: Item added to cart
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Item added to cart
 */


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
