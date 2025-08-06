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
export const register = async (name, password) => {
  try {
    const res = await fetch('/api/auth/register', {
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
  const token = localStorage.getItem('token'); // ✅ get token

  if (!token) return { error: 'Not authenticated' };

    try {
        const res = await fetch('/api/cart/items', {
            method: 'POST',
            headers: { 
              'Content-Type': 'application/json',
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
            body: JSON.stringify({ furniture_item_id }),
        });
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}   
//fetch go to checkout
export const goToCheckout = async (id) => {
    try {
        const res = await fetch(`/api/checkout/${id}`);
        return res.json();
    } catch (error) {
        return { error: error.message || 'Something went wrong' };
  }
}
//fetch checkout

//fetch insert stripe logic

//fetch finalize checkout

//fetch receipt 