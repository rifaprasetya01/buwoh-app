import dotenv from 'dotenv';
dotenv.config();

import app from './app';

const PORT = process.env.PORT || 5000;
const HOST = '0.0.0.0';

app.listen(Number(PORT), HOST, () => {
  // console.log(`Server is running on http://192.168.1.10:${PORT}`);
  console.log(`Local access: http://localhost:${PORT}`);
});
