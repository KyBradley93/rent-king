const jwt = require('jsonwebtoken');

function authenticateCustomer(req, res, next) {
  //make authorization header neccessary
  const authHeader = req.headers['authorization'];
  //finds process.env.JWT_SECRET code within jwt
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);

  //checks if users token and jwt secret matches
  jwt.verify(token, process.env.JWT_SECRET, (err, customer) => {
    if (err) return res.sendStatus(403);
    req.customer = customer;
    next();
  });
}

module.exports = authenticateCustomer;
