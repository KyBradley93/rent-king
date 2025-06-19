const jwt = require('jsonwebtoken');

function authenticateCustomer(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, customer) => {
    if (err) return res.sendStatus(403);
    req.customer = customer;
    next();
  });
}

module.exports = authenticateCustomer;
