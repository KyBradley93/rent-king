import React, { useState, useEffect } from 'react';
import { products, productsByType, addToCart } from '../utils/index'; 
import { useNavigate } from 'react-router-dom';

const Products = () => {
    const navigate = useNavigate();
    const [allProducts, setAllProducts] = useState([]);
    const [filteredProducts, setFilteredProducts] = useState([]);
    const [type, setType] = useState('');
    const [error, setError] = useState('');
    

    // add to cart
    const handleAddToCart = async (e, furniture_item_id, quantity) => {
        e.preventDefault();
        const res = await addToCart(furniture_item_id, quantity);

        if (res.error) {
            setError(res.error);
        };
        
        alert('Item added');
    };

    // go to cart
    const handleGoToCart = async () => {
        navigate('/cart');
    };

    //logout

    const handleLogOut = async () => {
        navigate('/');
    };

    // products
    useEffect(() => {
        const fetchProducts = async () => {
            try {
                const res = await products();

                if (res.error) {
                    setError(res.error);
                } else {
                    setAllProducts(res);
                    setFilteredProducts(res);
                }
            } catch (err) {
                setError('Failed to fetch products')
            }
        };

        fetchProducts();

    }, []);
    // products by furniture type
     useEffect(() => {
        const fetchProductsByType = async () => {
            if(!type) {
                setFilteredProducts(allProducts);
                return;
            }

            try {
                const res = await productsByType(type);

                if (res.error) {
                    setError(res.error)
                } else {
                    setFilteredProducts(res)
                };
                
            } catch (err) {
                setError(err.response);
            }
        };

        fetchProductsByType();

    }, [type, allProducts]);
    
    
    return (
        <div>
            <h1>CLICK BUTTON TO ADD TO YOUR CART</h1>
            <h2>Products</h2>
            <select value={type} onChange={(e) => setType(e.target.value)}>
                <option value="">All Furniture</option>
                <option value="beds">Beds</option>
                <option value="night_stands">Night Stands</option>
                <option value="dressers">Dressers</option>
                <option value="tvs">TVs</option>
                <option value="tables">Tables</option>
                <option value="couches">Couches</option>
            </select>

            {error && <p style={{ color: 'red' }}>{error}</p>}

            <ul>
                {filteredProducts.map((product) => (
                    <li key={product.id}>
                        {product.name} - ${product.price}
                        <button onClick={(e) => handleAddToCart(e, product.id, 1)}>Add To Cart</button>
                    </li>
                ))}
            </ul>
            <button onClick={handleGoToCart}>Go To Cart</button>
            <button onClick={handleLogOut}>Log Out</button>
            
        </div>
        
    );
    

};

export default Products;