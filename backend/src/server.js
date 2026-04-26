const config = require('./config');
const app = require('./app');

const PORT = config.port;

app.listen(PORT, () => {
  console.log(`
  ╔════════════════════════════════════════╗
  ║                                        ║
  ║   🚀 Buwoh API Server                 ║
  ║   Running on port ${PORT}               ║
  ║   Environment: ${config.nodeEnv}       ║
  ║                                        ║
  ║   Health: http://localhost:${PORT}/api/v1/health  ║
  ║                                        ║
  ╚════════════════════════════════════════╝
  `);
});
