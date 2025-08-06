const express = require('express');
const path = require('path');
require('dotenv').config();
const { swaggerUi, swaggerSpec } = require('./swagger');

const app = express();
app.use(express.json());

// Serve the built React app

app.use(express.static(path.join(__dirname, 'build')));

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
// In Express middleware (server.js)
app.use((req, res, next) => {
  res.removeHeader("Cross-Origin-Opener-Policy");
  next();
});


app.use('/api/auth', require('./controller/routes/auth'));
app.use('/api/products', require('./controller/routes/products'));
app.use('/api/cart', require('./controller/routes/cart'));
//app.use('/api/checkout', require('./controller/routes/checkout'));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

const PORT = process.env.PORT || 5001;

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
