import React, { useState, useEffect } from 'react';
import { fetchCart, deleteFromCart } from '../utils';
import CheckoutButton from './CheckoutButton';
import { useNavigate } from 'react-router-dom';

const Cart = () => {
    const navigate = useNavigate();
    const [cart, setCart] = useState([])
    const [error, setError] = useState('');

    
    // remove from cart (might have to make...)
    const handleDelete = async (e, furniture_item_id) => {
        e.preventDefault();

        const res = await deleteFromCart(furniture_item_id);

        if (res.error) {
            setError(res.error)
        } else {
            const res = await fetchCart();
            setCart(res);
        }
    };

    //log out

    const handleLogOut = async () => {
        navigate('/');
    };

    //go to products

    const handleGoToProducts = async () => {
        navigate('/products');
    };
    
    // go to checkout

    // cart
    useEffect(() => {
        const getCart = async () => {
            try {
                const res = await fetchCart();

                if (res.error) {
                    setError(res.error);
                };

                setCart(res);
            } catch (err) {
                setError('Failed to fetch cart')
            }
        };

        getCart();
    }, []);

    
    
    return (
        <>
            <button onClick={handleLogOut}>Log Out</button>
            <button onClick={handleGoToProducts}>Back To Products</button>
            <h1>CART</h1>
            {error && <p style={{ color: 'red' }}>{error}</p>}
            <ul>
                { cart.map((item) => (
                    <li key={item.id}>
                        {item.name} - {item.price} - {item.quantity}
                        <button onClick={(e) => handleDelete(e, item.furniture_item_id)}>Delete</button>
                    </li>
                ))}
            </ul>
            <CheckoutButton cartItems={cart.map(item => ({
                id: item.furniture_item_id,
                name: item.name,
                price: item.price * 100,
                quantity: item.quantity,
            }))}
            />
        </>
    );
};

export default Cart;