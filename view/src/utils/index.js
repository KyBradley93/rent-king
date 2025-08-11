/*
export const  = async () => {
    try {
        const res = await fetch('');
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}
*/




//fetch register

//need to match async with the req.body in router
export const register = async (name, password) => {
  try {
    //fetch must match routes properly, consider hierarchy tree of routes
    const res = await fetch('/api/auth/register', {
      //must match what router says
        method: 'POST',
      //idk often needed
        headers: { 'Content-Type': 'application/json' },
      //router can only read json I think
        body: JSON.stringify({ name, password }),
    });

    //collects register data and turns it into json
    const data = await res.json();

    //sets up "token" for authorization
    if (data.token) {
      localStorage.setItem('token', data.token);
    }

    return data;

    } catch (error) {
    return { error: error.message || 'Something went wrong' };
  };
}
//fetch login
export const login = async (name, password) => {
  try {
    const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, password }),
    });
    
    const data = await res.json();

    if (data.token) {
      localStorage.setItem('token', data.token);
    }

    return data;

    } catch (error) {
    return { error: error.message || 'Something went wrong' };
  };
}
//fetch googleLogin
export const googleLogin = async (idToken) => {
  try {
    const res = await fetch('/api/auth/google-login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token: idToken }) // This is the Google ID token
  });

  const data = await res.json();
  
  if (data.token) {
    localStorage.setItem('token', data.token);
  }

  //console.log('Google login token stored:', data.token);

  return data;
  } catch (error) {
    return { error: error.message || 'Unknown error during Google login' };
  }

};

//logout

export const logout = () => {
  //deletes token
  localStorage.removeItem('token');
};

//fetch products
export const products = async () => {
    try {
        const res = await fetch('/api/products');
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
    }
}
//fetch products by furniture type
export const productsByType = async (type) => {
    try {
        const res = await fetch(`/api/products/${type}`);
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}
//fetch add to cart
export const addToCart = async (furniture_item_id, quantity) => {
  //need to have "token" if router has authenticateCustomer middleware
  const token = localStorage.getItem('token'); // ✅ gets token

  if (!token) return { error: 'Not authenticated' };

    try {
        const res = await fetch('/api/cart/items', {
            method: 'POST',
            headers: { 
              'Content-Type': 'application/json',
              //says you have permission
              'Authorization': `Bearer ${token}` 
            },
            body: JSON.stringify({ furniture_item_id, quantity }),
        });
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}   

//fetch cart
export const fetchCart = async () => {
  const token = localStorage.getItem('token'); // ✅ get token

  if (!token) return { error: 'Not authenticated' };

  try {
    const res = await fetch('/api/cart', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}` // ✅ send token
      }
    });

    return res.json();
  } catch (error) {
    return { error: error.message || 'Something went wrong' };
  }
};

//fetch remove from cart (might have to make...)
export const deleteFromCart = async (furniture_item_id) => {
  const token = localStorage.getItem('token'); // ✅ get token  

  if (!token) return { error: 'Not authenticated' };


    try {
        const res = await fetch('/api/cart/items', {
          method: 'DELETE',
          headers: { 
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}` 
          },
          body: JSON.stringify({ furniture_item_id })
        });
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}   
//fetch go to checkout
export const goToCheckout = async (id) => {
  const token = localStorage.getItem('token');
  
    try {
        const res = await fetch(`/api/checkout/${id}`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        if (!res.ok) {
            const text = await res.text();
            return { error: `Request failed: ${res.status} - ${text}` };
        }

        return await res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}
//fetch checkout
export const checkout = async (cartItems, totalPrice) => {
  const token = localStorage.getItem('token');

  if (!token) return { error: 'Not authenticated' };

  try {
    const res = await fetch('http://localhost:5001/api/payment', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${token}`
            },
            body: JSON.stringify({ 
              items: cartItems,
              total_price: totalPrice,
            }),
        });

    return res.json();

  } catch (err) {
    return { error: err.message || 'Something went wrong' };
  }
}
//fetch insert stripe logic

//fetch finalize checkout

//fetch receipt 