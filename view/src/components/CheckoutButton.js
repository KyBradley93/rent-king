import React from 'react';
//import { loadStripe } from '@stripe/stripe-js';
import { checkout } from '../utils';

//const stripePromise = loadStripe('pk_test_51Rta3HE65fIwmUTf2KNj2QscOt9HS2PrfYTnlQWlSs1hdE0PiUyXUVHLukhfZPWafARfJph2apQC9f32Kg69Seec005W19ZI0V');

//needs cart items to work
const CheckoutButton = ({ cartItems }) => {
    //console.log("📦 Sending to backend:", cartItems);

    const handleClick = async () => {

        // Calculate total price from cart items
        const totalPrice = cartItems.reduce(
            (acc, item) => acc + item.price * item.quantity,
            0
        );

        //runs checkout function and gets url and error 
       const { url, error } = await checkout(cartItems, totalPrice);

        if (error) {
            console.error('Checkout error:', error);
            return;
        }

        if (url) {
            //send you to success or cancel url page
            window.location.href = url;
        } 
    }

    return (
        <button onClick={handleClick}>
            Checkout
        </button>
    );
};

export default CheckoutButton;