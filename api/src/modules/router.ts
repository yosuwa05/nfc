import Elysia from "elysia";
import { fileController } from "./file/controller/file-controller";
import { userBaseRouter } from "./user/controller/user-router";
<<<<<<< HEAD
import { adminBaseRouter } from "./admin/controller/admin-router";
=======
>>>>>>> e7b4c2eaf2335985e3921c13a23ecf6e3c6bafb6


export const baseRouter = new Elysia({
  prefix: "/api",
  tags: ["Base Routes"],
});

baseRouter.use(fileController)
<<<<<<< HEAD
baseRouter.use(adminBaseRouter)
=======
>>>>>>> e7b4c2eaf2335985e3921c13a23ecf6e3c6bafb6
baseRouter.use(userBaseRouter)
