const express = require('express');
const router = express.Router();
const pool = require('../../model/db');
const authenticateCustomer = require('../../middleware/auth');

/**
 * @swagger
 * /api/checkout:
 *   post:
 *     summary: Finalize a customer's checkout
 *     tags:
 *       - Checkout
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       201:
 *         description: Checkout successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 checkout_id:
 *                   type: integer
 *             example:
 *               message: Checkout successful
 *               checkout_id: 5
 *       400:
 *         description: No cart found
 *       500:
 *         description: Checkout failed
 */


router.post('/', authenticateCustomer, async (req, res) => {
  //found by authenticateCustomer
  const customerId = req.customer.id;

  //finds cart id
  const cartRes = await pool.query('SELECT id FROM cart WHERE customer_id = $1', [customerId]);
  if (cartRes.rows.length === 0) return res.status(400).json({ error: 'No cart found' });

  const cartId = cartRes.rows[0].id;

  //triggers db function that will update checkout and checkout_items db
  try {
    const result = await pool.query('SELECT finalize_checkout($1, $2) AS checkout_id', [cartId, customerId]);
    res.status(201).json({ message: 'Checkout successful', checkout_id: result.rows[0].checkout_id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Checkout failed' });
  }
});

/**
 * @swagger
 * /api/checkout/{id}:
 *   get:
 *     summary: Get checkout details by ID
 *     tags:
 *       - Checkout
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: Checkout ID
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Checkout details
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   checkout_id:
 *                     type: integer
 *                   total_price:
 *                     type: string
 *                   created_at:
 *                     type: string
 *                     format: date-time
 *                   furniture_item_id:
 *                     type: integer
 *                   name:
 *                     type: string
 *                   quantity:
 *                     type: integer
 *                   unit_price:
 *                     type: string
 *             example:
 *               - checkout_id: 5
 *                 total_price: "850.00"
 *                 created_at: "2025-06-24T14:40:13.187Z"
 *                 furniture_item_id: 10
 *                 name: pullout_couch
 *                 quantity: 1
 *                 unit_price: "600.00"
 *               - checkout_id: 5
 *                 total_price: "850.00"
 *                 created_at: "2025-06-24T14:40:13.187Z"
 *                 furniture_item_id: 5
 *                 name: seashell
 *                 quantity: 1
 *                 unit_price: "250.00"
 *       404:
 *         description: Not found
 *       500:
 *         description: Server error
 */


router.get('/:id', authenticateCustomer, async (req, res) => {
  //console.log('🧪 Authenticated customer ID:', req.customer?.id);
  //console.log('🧪 Requesting checkout ID:', req.params.id);
  const checkoutId = req.params.id;

  //console.log(`Fetching checkout ID ${checkoutId} for customer ${req.customer.id}`);

  //finds checkout data in db to display by checkout id and customer id
  const result = await pool.query(`
    SELECT c.id AS checkout_id, c.total_price, c.created_at,
           ci.furniture_item_id, af.name, ci.quantity, ci.unit_price
    FROM checkout c
    JOIN checkout_items ci ON c.id = ci.checkout_id
    JOIN all_furniture af ON ci.furniture_item_id = af.id
    WHERE c.id = $1 AND c.customer_id = $2
  `, [checkoutId, req.customer.id]);

  if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Checkout not found' });
    }

  res.json(result.rows);
});


module.exports = router;
