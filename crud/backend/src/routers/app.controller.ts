import { Router } from "express";


const serviceOrderRouter = Router();

serviceOrderRouter.get('/', (req, res) => {
  res.send('Hello World!');
});

export default serviceOrderRouter;
