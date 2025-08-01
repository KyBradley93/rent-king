const express = require('express');
require('dotenv').config();
const { swaggerUi, swaggerSpec } = require('./swagger');

const app = express();
app.use(express.json());

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use('/auth', require('./controller/routes/auth'));
app.use('/products', require('./controller/routes/products'));
app.use('/cart', require('./controller/routes/cart'));
app.use('/checkout', require('./controller/routes/checkout'));

app.listen(3000, () => console.log('Server running on port 3000, Swagger docs available at http://localhost:3000/api-docs'));
