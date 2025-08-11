import React, { useState, useEffect } from 'react';
import { goToCheckout } from '../utils';
import { useSearchParams } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';

const Checkout = () => {
    const navigate = useNavigate();
    const [checkoutItems, setCheckoutItems] = useState(null);
    const [error, setError] = useState('');
    const [params] = useSearchParams();
    const checkoutId = params.get('id');

    //logout

    const handleLogOut = async () => {
        navigate('/');
    };

    //go to products

    const handleGoToProducts = async () => {
        navigate('/products');
    };
    
    // load checkout
    useEffect(() => {
        const loadCheckout = async () => {
            if (!checkoutId) return setError('Missing checkout ID');

            const res = await goToCheckout(checkoutId);

            if (res.error) {
                setError(res.error);
            } else if (!Array.isArray(res) || res.length === 0) {
                setError('No checkout data found');
            } else {
                setCheckoutItems(res);
            }
        };

        loadCheckout();

    }, [checkoutId]);
    
    if (error) return <p style={{ color: 'red' }}>{error}</p>;
    if (!checkoutItems) return <p>Loading...</p>;

    // All items have the same checkout_id and total_price, so just grab from first item
  const { checkout_id, total_price } = checkoutItems[0];
    
    return (
        <>
            <h1>✅ Payment Successful!</h1>
            <p>Checkout ID: {checkout_id}</p>
            <p>Total: ${(parseFloat(total_price) /100).toFixed(2)}</p>

            <h2>Purchased Items:</h2>
            <ul>
                {checkoutItems.map(item => (
                    <li key={item.furniture_item_id}>
                        {item.name} — Quantity: {item.quantity} — Price: ${(parseFloat(item.unit_price) / 100).toFixed(2)}
                    </li>
                ))}
            </ul>
            <button onClick={handleLogOut}>Log Out</button>
            <button onClick={handleGoToProducts}>Back To Products</button>
        </>
    );
};

export default Checkout;