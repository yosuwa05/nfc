import Elysia from "elysia";
import { PasetoUtil } from "@/lib/paseto";
import { validateToken } from "@/lib/utils";
import { adminAuthController } from "./adminAuth-controller";


export const adminBaseRouter = new Elysia({
  prefix: "/admin",
  tags: ["Admin Routes"],
})
.use(adminAuthController)