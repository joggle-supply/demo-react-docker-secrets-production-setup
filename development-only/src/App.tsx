import React from 'react';
import './App.css';

const App: React.FC = () => {
  // Using standard process.env - works with both local .env files and Docker runtime polyfill
  const envVars = [
    { key: 'NAME', value: process.env.REACT_APP_NAME || 'Not Set' },
    { key: 'API_URL', value: process.env.REACT_APP_API_URL || 'Not Set' },
    { key: 'ENVIRONMENT', value: process.env.REACT_APP_ENVIRONMENT || 'Not Set' },
    { key: 'VERSION', value: process.env.REACT_APP_VERSION || 'Not Set' }
  ];

  const getStatusColor = (value: string) => {
    if (value === 'Not Set') return '#ff6b6b';
    if (value === 'true' || value === 'production') return '#51cf66';
    if (value === 'false' || value === 'development') return '#ffd43b';
    return '#74c0fc';
  };
  
  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 React Docker Swarm App</h1>
        <h2>Configuration Dashboard</h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', 
          gap: '20px', 
          marginTop: '30px',
          width: '100%',
          maxWidth: '1200px'
        }}>
          {envVars.map(({ key, value }) => (
            <div key={key} style={{
              background: 'rgba(255, 255, 255, 0.1)',
              padding: '20px',
              borderRadius: '10px',
              border: '1px solid rgba(255, 255, 255, 0.2)',
              backdropFilter: 'blur(10px)'
            }}>
              <div style={{ 
                fontSize: '14px', 
                color: '#aaa', 
                marginBottom: '5px',
                textTransform: 'uppercase',
                letterSpacing: '1px'
              }}>
                {key}
              </div>
              <div style={{ 
                fontSize: '18px', 
                fontWeight: 'bold',
                color: getStatusColor(value),
                wordBreak: 'break-all'
              }}>
                {value}
              </div>
            </div>
          ))}
        </div>
        
        <div style={{
          marginTop: '40px',
          padding: '20px',
          background: 'rgba(255, 255, 255, 0.05)',
          borderRadius: '10px',
          fontSize: '14px',
          color: '#ccc',
          maxWidth: '800px'
        }}>
          <h3>🔐 Configuration Priority</h3>
          <ol style={{ textAlign: 'left' }}>
            <li><strong>Docker Secrets</strong> - Highest priority, runtime polyfill</li>
            <li><strong>Environment Variables</strong> - Local .env file or container env</li>
            <li><strong>Default Values</strong> - Fallback configuration</li>
          </ol>
        </div>
      </header>
    </div>
  );
}

export default App;