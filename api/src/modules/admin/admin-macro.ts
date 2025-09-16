import { PasetoUtil } from "@/lib/paseto";
import Elysia from "elysia";

export const adminAuthMacro = new Elysia({}).macro({
    isAuth: {
      async resolve({ headers, set }) {
        try {
          let token = headers["x-admin"];

          if (!token && headers.authorization?.startsWith("Bearer ")) {
            token = headers.authorization.slice(7);
          }

          if (!token) {
            set.status = 401;
            throw new Error("Unauthorized");
          }
          if (!token.startsWith("v4.local")) {
            set.status = 401;
            throw new Error("Invalid token");
          }
          const payload = await PasetoUtil.decodePaseto(token, "admin");
          if (!payload) {
            set.status = 401;
            throw new Error("Invalid token");
          }

          return { user: payload };
        } catch (error) {
          console.error("Error during authentication:", error);
          if (error && typeof error === "object" && "status" in error) {
            throw error;
          }
          throw { status: 401, message: "Invalid token" };
        }
      },
    },
  });