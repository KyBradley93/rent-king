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
    const res = await fetch('/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(name, password),
    });
    return res.json();
    } catch (error) {
    return { error: error.message || 'Something went wrong' };
  };
}
//fetch login
export const login = async (name, password) => {
  try {
    const res = await fetch('/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(name, password),
    });
    return res.json();
    } catch (error) {
    return { error: error.message || 'Something went wrong' };
  };
}
//fetch google login

//fetch products

//fetch products by furniture type

//fetch add to cart
    
//fetch go to cart

//fetch cart

//fetch remove from cart (might have to make...)
    
//fetch go to checkout

//fetch checkout

//fetch insert stripe logic

//fetch finalize checkout

//fetch receipt 