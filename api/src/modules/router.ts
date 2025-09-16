import Elysia from "elysia";
import { fileController } from "./file/controller/file-controller";
import { userBaseRouter } from "./user/controller/user-router";


export const baseRouter = new Elysia({
  prefix: "/api",
  tags: ["Base Routes"],
});

baseRouter.use(fileController)
baseRouter.use(adminBaseRouter)
baseRouter.use(userBaseRouter)
