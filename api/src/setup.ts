import cors from "@elysiajs/cors";
import { swagger } from "@elysiajs/swagger";
import { logger } from "@rasla/logify";
import { Elysia } from "elysia";
import mongoose, { Types } from "mongoose";
// import { TokenGenerator } from "./lib/tokenGen";
import { baseRouter } from "./modules/router";



const URL = process.env.DB_URL;

try {
  await mongoose.connect(URL as string, {
    dbName: "NFC",
    maxConnecting: 10,
  });

  console.log("Connected to Database");
} catch (e) {
  console.log(e);
}

const app = new Elysia();
const isProd = process.env.ENV === 'PROD';
app.use(cors());

app.use(

  swagger({
    path: "/docs",
    exclude: ["/docs", "/docs/json"],
    theme: "dark",
    documentation: {
      servers: [
        {
          url: "http://localhost:4000/"
        },
      ],
      info: {
        title: "NFC API",
        version: "1.0.0",
      },
      components: {
        securitySchemes: {
          bearerAuth: {
            scheme: "bearer",
            type: "http",
            bearerFormat: "JWT",
          },
        },
      },
    },
  })
);

app.use(
  logger({
    level: "info",
    format:
      "[{timestamp}] {level} [{method}] {path} - {statusCode} {duration}ms{ip}",
  })
);
// const token = TokenGenerator.generateKey();
// console.log('Generated Token:', token);
app.use(baseRouter);

app.onError(({ code, error }) => {
  if (code === "VALIDATION") {
    return {
      status: 400,
      body: error.all,
    };
  }
});

export { app };
