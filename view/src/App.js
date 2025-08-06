import React from 'react';
import { Routes, Route, Link } from 'react-router-dom';
import Auth from './components/Auth';
import Products from './components/Products';
import ProtectedRoute from './components/ProtectedRoute';


export const App = () => {
    return (
        <>
            <nav>
                <ul>
                    <li><Link to="/">Login</Link></li>
                    <li><Link to="/products">Products</Link></li>
                </ul>

            </nav>

            <Routes>
                <Route path='/' element={<Auth />}/>
                <Route path='/products' 
                element={
                    <ProtectedRoute>
                        <Products />
                    </ProtectedRoute>
                } />
            </Routes>

        </>
    );
}

export default App;