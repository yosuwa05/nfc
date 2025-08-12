import { Schema, model, Document } from "mongoose";

interface User extends Document {
  username: string;
  email: string;
  role: string;
  profileImage?: string;
  lastLogin?: Date;
  isActive: boolean;
  permissions: string[]
  isDeleted: boolean;
  fcmToken?: string;
  mobile?: string;
  department?: string;
  slug?: string;
  businessDetails?: BusinessDetails;
  socialMedia?: SocialMedia;
  subscriptionPlan?: string;
}

interface BusinessDetails {
  companyName: string;
  companyAddress: string;
  companyMobile: string;
  companyEmail: string;
  companyWebsite: string;
}

interface SocialMedia {
  facebook: string;
  x: string;
  whatsapp: string;
  youtube: string;
  instagram: string;
}

const businessDetailsSchema = new Schema<BusinessDetails>({
  companyName: { type: String, default: '' },
  companyAddress: { type: String, default: '' },
  companyMobile: { type: String, default: '' },
  companyEmail: { type: String, default: '' },
  companyWebsite: { type: String, default: '' },
});

const socialMediaSchema = new Schema<SocialMedia>({
  facebook: { type: String, default: '' },
  x: { type: String, default: '' },
  whatsapp: { type: String, default: '' },
  youtube: { type: String, default: '' },
  instagram: { type: String, default: '' },
});

const userSchema = new Schema<User>(
  {
    username: { type: String, default: '',required: true },
    isDeleted: { type: Boolean, default: false },
    email: { type: String, unique: true, lowercase: true, default: '' },
    profileImage: { type: String, default: '' },
    lastLogin: { type: Date, default: null },
    isActive: { type: Boolean, default: true },
    permissions: { type: [String], default: [] },
    fcmToken: { type: String, default: '' },
    mobile: { type: String, unique: true, required: true, default: '' },
    department: { type: String, default: '' },
    subscriptionPlan: { type: String, enum: ['basic', 'pro', 'pro+'], default: 'basic' },
    slug: { type: String, unique: true, default: '' },
    businessDetails: { type: businessDetailsSchema, default: {} },
    socialMedia: { type: socialMediaSchema, default: {} },
  },
  { timestamps: true }
);

export const UserModel = model<User>("User", userSchema);
