import React, { useState, useEffect } from 'react';
import { register, login, googleLogin } from '../utils/index';


const Auth = () => {
    const [name, setName] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState();
    const [response, setResponse] = useState();

    const handleGoogleCredential = async (response) => {
    if (!response.credential) {
      setError('No Google credential received.');
      return;
    }

    const res = await googleLogin(response.credential);

    if (res.error) {
      setError(res.error);
    } else {
      setResponse(res);
    }
  };

  const handleRegister = async (e) => {
    e.preventDefault();
    const res = await register(name, password);
    if (res.error) {
      setError(res.error);
    } else {
      setResponse(res);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    const res = await login(name, password);
    if (res.error) {
      setError(res.error);
    } else {
      setResponse(res);
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
                    client_id: process.env.GOOGLE_CLIENT_ID,
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
}, []);

    
    
    
    return (
        <div>
            <h1>fuck</h1>
            <h2>Register</h2>
            <form onSubmit={handleRegister}>
                <input
                    type="text"
                    name="name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                >
                </input>
                <input
                    type="text"
                    name="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                >
                </input>
            </form>
            <h2>Login</h2>
            <form onSubmit={handleLogin}>
                <input
                    type="text"
                    name="name"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                >
                </input>
                <input
                    type="text"
                    name="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                >
                </input>
            </form>
            <h2>Google Login</h2>
            <div id="g_id_signin" style={{ marginTop: '20px' }}></div>

            {error && <p style={{ color: 'red' }}>Error: {error}</p>}
            {response && <p style={{ color: 'green' }}>{response.message || 'Success'}</p>}
        </div>
    );
};