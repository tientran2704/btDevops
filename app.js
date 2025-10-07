// app.js
const express = require('express');
const path = require('path');
const app = express();
const defaultPort = 3000;
const port = process.env.PORT || defaultPort;

const PORT = Number(process.env.PORT) || 3000;
const HOST = '0.0.0.0';

// Serve static files from ./public
app.use(express.static(path.join(__dirname, 'public')));

// Simple health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    pid: process.pid,
    uptime: process.uptime(),
    timestamp: Date.now()
  });
});

// Fallback: for SPA or unknown routes that accept HTML, return index.html
app.get('*', (req, res) => {
  // if client expects HTML, return index.html
  if (req.accepts('html')) {
    return res.sendFile(path.join(__dirname, 'public', 'index.html'));
  }
  // otherwise 404 JSON
  res.status(404).json({ error: 'Not found' });
});

// Graceful shutdown
const shutdown = (signal) => {
  console.log(`Received ${signal}. Closing server...`);
  server.close(() => {
    console.log('Server closed. Exiting process.');
    process.exit(0);
  });
  // Force exit if not closed within 10s
  setTimeout(() => {
    console.error('Forcing shutdown.');
    process.exit(1);
  }, 10000).unref();
};

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

// Serve static files from 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Basic error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Improved server startup with error handling
const server = app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
}).on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${port} is already in use. Try these steps:`);
    console.log('1. Find the process using the port:');
    console.log('   netstat -ano | findstr :3000');
    console.log('2. Kill the process (replace PID with the process ID):');
    console.log('   taskkill /F /PID <PID>');
    
    // Try alternative port
    const altPort = port + 1;
    console.log(`\nTrying alternative port ${altPort}...`);
    server.listen(altPort);
  } else {
    console.error('Server error:', err);
    process.exit(1);
  }
});
