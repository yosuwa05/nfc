import { config } from "dotenv";
import { app } from "./setup";

config();

const PORT = 4000;
// const HOST ="localhost"
const HOST ="0.0.0.0"

app.listen({ port: PORT, hostname: HOST }, () => {
  console.log(`Listening on http://${HOST}:${PORT}`);
  console.log(`Checkout the docs at http://${HOST}:${PORT}/docs`);
});