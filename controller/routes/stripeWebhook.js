const express = require('express');
const router = express.Router();
const pool = require('../../model/db');
const Stripe = require('stripe');
//unlocks stripe with key
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

//webhooks can't be json???
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  //console.log('⚡ Webhook received');
  

  //makes stripe-signature neccessary
  const sig = req.headers['stripe-signature'];
  let event;

  try {

    //builds new event and maybe verifies if everything matches???
    event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    console.error('❌ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }


  //builds new session from new event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    //console.log('Session object received from webhook:', session);
    //console.log('Session metadata:', session.metadata);

    // Update your DB: order paid

    //finds id from new session to update db
    const checkoutId = session.metadata.checkout_id;

    try {
      //updates checkout in db with id
      const result = await pool.query(
        'UPDATE checkout SET payment_status = $1 WHERE id = $2',
        ['paid', checkoutId]
      );
      
      //console.log(`DB update affected ${result.rowCount} row(s)`);
      //console.log(`✅ Checkout ${checkoutId} marked as paid.`);
      //console.log('checkoutId from metadata:', checkoutId);

      // Remove items from the cart for this checkout


      // finds cart with checkout id
      const cartRes = await pool.query(
        'SELECT cart_id FROM checkout WHERE id = $1',
        [checkoutId]
      );

      //finds cart id with found cart
      const cartId = cartRes.rows[0]?.cart_id;

      //deletes cart items from db
      if (cartId) {
        await pool.query(
          'DELETE FROM cart_items WHERE cart_id = $1',
          [cartId]
        );
        //console.log(`🗑️ Cart items for cart_id ${cartId} removed after payment.`);
      };


    } catch (dbError) {
      console.error('❌ Failed to update checkout row:', dbError);
    }
  }

  res.json({ received: true });
});

module.exports = router;