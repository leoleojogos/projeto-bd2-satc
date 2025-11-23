import express from 'express';
import serviceOrderRouter from './rotuers/app.controller.js';

const hostname = process.env.HTTP_HOST || 'localhost';
const port = process.env.HTTP_PORT ? Number(process.env.HTTP_PORT) : 3000;

console.log(`Starting server with configuration: HTTP_HOST=${hostname}, HTTP_PORT=${port}`);

const app = express();

app.get('/', (req, res) => {
  res.send('Server is running!');
});
app.use("/service-order", serviceOrderRouter);

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
});

export default app;
