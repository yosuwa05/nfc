import { PasetoUtil } from "@/lib/paseto";
import Elysia, { t } from "elysia";
import { AdminModel } from "@/schema/admin/admin-model";
import { BadRequestError } from "@/lib/shared/bad-request";

// Admin Auth Controller
export const adminAuthController = new Elysia({
  prefix: "/admin/auth",
  tags: ["Admin Auth"],
})

.post(
  "/register",
  async ({ body, set }) => {
    try {
      const { email, password } = body;

      // Check if admin already exists
      const existingAdmin = await AdminModel.findOne({ email });
      if (existingAdmin) {
        throw new BadRequestError("Admin already exists");
      }

      // Create new admin (password will be hashed by pre-save hook)
      const admin = new AdminModel({
        email,
        password, // Pass raw password; pre-save hook will hash it
        role: "admin",
      });

      await admin.save();

      set.status = 201;
      return {
        success: true,
        message: "Admin registered successfully",
        data: {
          _id: admin._id,
          email: admin.email,
        },
      };
    } catch (error: any) {
      set.status = 400;
      throw new BadRequestError(error.message || "Registration failed");
    }
  },
  {
    body: t.Object({
      email: t.String({ format: "email" }),
      password: t.String(),
    }),
    detail: {
      summary: "Admin Registration",
      description: "Register a new admin with email, password, and mobile",
    },
  }
)

.post(
  "/login",
  async ({ body, set }) => {
    try {
      const { email, password } = body;
      console.log("Login attempt with email:", email);
      console.log("Provided password:", password); // Log the raw password provided

      // Find admin by email
      const admin = await AdminModel.findOne({ email });
      if (!admin) {
        console.log("No admin found for email:", email);
        throw new BadRequestError("Invalid email or password");
      }

      // Log the stored password hash
      console.log("Stored password hash:", admin.password);

      // Check if password exists and is a valid hash
      if (!admin.password || typeof admin.password !== 'string') {
        console.log("Invalid password data for user:", email);
        throw new BadRequestError("Invalid password data stored for this user");
      }

      // Verify password
      const isPasswordValid = await Bun.password.verify(
        password,
        admin.password,
        "bcrypt"
      ).catch((err) => {
        console.error("Password verification error:", err);
        return false;
      });

      console.log("Password verification result:", isPasswordValid);

      if (!isPasswordValid) {
        console.log("Password verification failed for email:", email);
        throw new BadRequestError("Invalid email or password");
      }

      // Update lastLogin
      admin.lastLogin = new Date();
      await admin.save();

      // Generate token
      const token = await PasetoUtil.encodePaseto(
        {
          email: admin.email,
          role: "admin",
        },
        "admin"
      );

      set.headers["Authorization"] = `Bearer ${token}`;
      set.status = 200;

      return {
        success: true,
        message: "Login successful",
        data: {
          _id: admin._id,
          email: admin.email,
          mobile: admin.mobile,
          isActive: admin.isActive,
          lastLogin: admin.lastLogin,
          token,
        },
      };
    } catch (error: any) {
      console.error("Login error:", error.message);
      set.status = 400;
      throw new BadRequestError(error.message || "Login failed");
    }
  },
  {
    body: t.Object({
      email: t.String({ format: "email" }),
      password: t.String(),
    }),
    detail: {
      summary: "Admin Login",
      description: "Authenticate admin using email and password",
    },
  }
)

