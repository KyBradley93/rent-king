require('dotenv').config();
const express = require('express');
const pool = require('../../model/db');
const router = express.Router();
const Stripe = require('stripe');
//matches key to unlock stripe
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);
const authenticateCustomer = require('../../middleware/auth');

router.post('', authenticateCustomer, async (req, res) => {
  //from utils/index
  const { items, total_price } = req.body;
  //from authenticateCustomer
  const customer_id = req.customer.id;
    
  try {

    //finds cart
    const cartResult = await pool.query(
      'SELECT id FROM cart WHERE customer_id = $1 ORDER BY id DESC LIMIT 1',
      [customer_id]
    );

    //finds cart id from cart
    const cart_id = cartResult.rows[0]?.id;

    /*console.log('🟡 Received checkout request:', {
    customer_id,
    cart_id,
    total_price,
    items
  });*/

    

    //adds new checkout to database with customer_id, cart_id, and total_price
    const checkoutResult = await pool.query(
      `INSERT INTO checkout (customer_id, cart_id, total_price)
      VALUES ($1, $2, $3)
      RETURNING id`,
      [customer_id, cart_id, total_price]
    );

    //gets id of new checkout
    const checkoutId = checkoutResult.rows[0].id;

    //loops through each "item" from items (cartItems in utils/index) and adds each to checkout_items database
    for (const item of items) {
      await pool.query(
        `INSERT INTO checkout_items (checkout_id, furniture_item_id, quantity, unit_price)
        VALUES ($1, $2, $3, $4)`,
        [checkoutId, item.id, item.quantity, item.price]
      );
    }


    //maps name, price, quantity in correct order for stripe to work
    const line_items = items.map(item => ({
      price_data: {
        currency:'usd',
        product_data: {
          name: item.name,
        },
        unit_amount: item.price,
      },
      quantity: item.quantity,
    }));

    //stripe session logic to send payment
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'payment',
      line_items,
      success_url: `http://localhost:3000/success?id=${checkoutId}`,
      cancel_url: 'http://localhost:3000/',
      metadata: {
        checkout_id: checkoutId.toString(),
      },
    });

    //sends back url, either success or cancel
    res.json({url: session.url});

    } catch (err) {
      console.error('❌ Error in /api/payment:', err);
      res.status(500).json({ error: 'Failed to create checkout session'})
    }
});


module.exports = router;


