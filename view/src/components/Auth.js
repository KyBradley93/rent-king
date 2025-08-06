import React, { useState, useEffect, useCallback } from 'react';
import { register, login, googleLogin } from '../utils/index';
import { useNavigate } from 'react-router-dom';

const Auth = () => {
  //console.log("Google Client ID:", process.env.REACT_APP_GOOGLE_CLIENT_ID);

  const navigate = useNavigate();
  const [loginName, setLoginName] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [registerName, setRegisterName] = useState('');
  const [registerPassword, setRegisterPassword] = useState('');
  const [error, setError] = useState();
  const [response, setResponse] = useState();

  const handleGoogleCredential = useCallback(async (response) => {
    if (!response.credential) {
      setError('No Google credential received.');
      return;
    }

    const res = await googleLogin(response.credential);

    if (res.error) {
      setError(res.error);
    } else {
      setResponse(res);
      localStorage.setItem('token', res.token);
      navigate('/products');
    }
  }, [navigate]);

  
  const handleRegister = async (e) => {
    e.preventDefault();
    const res = await register(registerName, registerPassword);
    if (res.error) {
      setError(res.error);
      console.log(error);
    } else {
      setResponse(res);
      localStorage.setItem('token', res.token);
      setRegisterName('');
      setRegisterPassword('');
      navigate('/');
      alert('Register Succesful. Log In Bitch');
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    const res = await login(loginName, loginPassword);
    if (res.error) {
      setError(res.error);
    } else {
      setResponse(res);
      localStorage.setItem('token', res.token);
      navigate('/products');
    }
  };


  useEffect(() => {     
    const loadGoogleScript = () => {
      const script = document.createElement('script');
      script.src = 'https://accounts.google.com/gsi/client';
      script.async = true;
      script.defer = true;
      script.onload = () => {
        /* global google */
        if (window.google) {
          google.accounts.id.initialize({
          client_id: process.env.REACT_APP_GOOGLE_CLIENT_ID,
          callback: handleGoogleCredential,
        });

        google.accounts.id.renderButton(
          document.getElementById('g_id_signin'),
          { theme: 'outline', size: 'large' }
        );
      }

      };
        document.body.appendChild(script);
    };

    loadGoogleScript();
}, [handleGoogleCredential]);

    
    
    
    return (
        <div>
            <h1>fuck</h1>
            <h2>Register</h2>
            <form onSubmit={handleRegister}>
                <input
                    type="text"
                    name="name"
                    value={registerName}
                    onChange={(e) => setRegisterName(e.target.value)}
                >
                </input>
                <input
                    type="text"
                    name="password"
                    value={registerPassword}
                    onChange={(e) => setRegisterPassword(e.target.value)}
                >
                </input>
                <button type="submit">Register</button>
            </form>
            <h2>Login</h2>
            <form onSubmit={handleLogin}>
                <input
                    type="text"
                    name="name"
                    value={loginName}
                    onChange={(e) => setLoginName(e.target.value)}
                >
                </input>
                <input
                    type="text"
                    name="password"
                    value={loginPassword}
                    onChange={(e) => setLoginPassword(e.target.value)}
                >
                </input>
                <button type="submit">Login</button>
            </form>
            <h2>Google Login</h2>
            <div id="g_id_signin" style={{ marginTop: '20px' }}></div>

            {error && <p style={{ color: 'red' }}>Error: {error}</p>}
            {response && <p style={{ color: 'green' }}>{response.message || 'Success'}</p>}
        </div>
    );
};

export default Auth;
