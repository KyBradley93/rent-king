const express = require('express');
require('dotenv').config();

const app = express();
app.use(express.json());

app.use('/auth', require('./routes/auth'));
app.use('/products', require('./routes/products'));
app.use('/cart', require('./routes/cart'));
app.use('/checkout', require('./routes/checkout'));

app.listen(3000, () => console.log('Server running on port 3000'));
