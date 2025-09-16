import { config } from "dotenv";
import { app } from "./setup";

config();

const PORT = 4000;
<<<<<<< HEAD
const HOST ="localhost"
// const HOST ="0.0.0.0"
=======
// const HOST ="localhost"
const HOST ="0.0.0.0"
>>>>>>> e7b4c2eaf2335985e3921c13a23ecf6e3c6bafb6

app.listen({ port: PORT, hostname: HOST }, () => {
  console.log(`Listening on http://${HOST}:${PORT}`);
  console.log(`Checkout the docs at http://${HOST}:${PORT}/docs`);
});