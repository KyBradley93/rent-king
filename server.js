const express = require('express');
const path = require('path');
require('dotenv').config();
const { swaggerUi, swaggerSpec } = require('./swagger');
const cors = require('cors');

const app = express();

// 🔥 Stripe webhook route needs raw body — mount first!
app.use('/api/payment', require('./controller/routes/stripeWebhook'));

app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.path}`);
  next();
});

app.use(cors({
  origin: 'http://localhost:3000',
  credentials: true,
}));

app.options('*', cors()); // 🔥 This handles preflight requests!


app.use(express.json());

app.use((req, res, next) => {
  res.removeHeader("Cross-Origin-Opener-Policy");
  next();
});

// Serve the built React app

app.use(express.static(path.join(__dirname, 'build')));

//starts swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
// In Express middleware (server.js)
app.use((req, res, next) => {
  res.removeHeader("Cross-Origin-Opener-Policy");
  next();
});


app.use('/api/auth', require('./controller/routes/auth'));
app.use('/api/products', require('./controller/routes/products'));
app.use('/api/cart', require('./controller/routes/cart'));
app.use('/api/checkout', require('./controller/routes/checkout'));
app.use('/api/payment', require('./controller/routes/payments'));

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

const PORT = process.env.PORT || 5001;

app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
