import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Auth from './components/Auth';
import Products from './components/Products';
import Cart from './components/Cart';
import Checkout from './components/Checkout';
import ProtectedRoute from './components/ProtectedRoute';


export const App = () => {
    return (
        <>
            <Routes>
                <Route path='/' element={<Auth />}/>
                <Route path='/products' 
                    element={
                        <ProtectedRoute>
                            <Products />
                        </ProtectedRoute>
                    } />
                <Route path='/cart' 
                    element={
                        <ProtectedRoute>
                            <Cart />
                        </ProtectedRoute>
                    } />
                <Route path='/success' 
                    element={
                        <ProtectedRoute>
                            <Checkout />
                        </ProtectedRoute>
                    } />
            </Routes>

        </>
    );
}

export default App;