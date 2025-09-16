import { Schema, model, Document } from "mongoose";

interface Admin extends Document {
  email: string;
  password?: string;
  role: string; // will always be "admin"
  profileImage?: string;
  lastLogin?: Date;
  isActive: boolean;
  mobile?: string;
  fcmToken?: string;
}

const adminSchema = new Schema<Admin>(
  {
    email: { type: String, unique: true, lowercase: true, required: true },
    password:{ type: String, required: true },
    role: { type: String, default: "admin" },
    profileImage: { type: String, default: "" },
    lastLogin: { type: Date, default: null },
    isActive: { type: Boolean, default: true },
    mobile: { type: String },
    fcmToken: { type: String, default: "" },
  },
  { timestamps: true }
);

adminSchema.pre("save", async function (next) {
    const admin = this;
  
    if (!admin.isModified("password")) {
      return next();
    }
  
    admin.password = await Bun.password.hash(admin.password, "bcrypt");
  
    next();
  });
  
  adminSchema.methods.comparePassword = async function (password: string) {
    return await Bun.password.verify(password, this.password, "bcrypt");
  };
  
export const AdminModel = model<Admin>("Admin", adminSchema);
