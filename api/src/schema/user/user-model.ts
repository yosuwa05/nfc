import { Schema, model, Document, Types } from "mongoose";

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
  subscriptionPlan?: string;
  selectedIndustries: Array<{
    industry: Types.ObjectId; // Reference to Industry
    tags: string[];           // Custom tags for this industry
  }>;
   attachedLinks: Array<{
    category: Types.ObjectId; // Reference to Category (e.g., "Social")
    subCategories: Array<{
      subCategoryId: Types.ObjectId; // Reference to SubCategory (e.g., WhatsApp)
      url: string;                   // URL for the subcategory (e.g., "https://wa.me/1234567890")
    }>;
  }>;
}

interface BusinessDetails {
  companyName: string;
  companyAddress: string;
  companyMobile: string;
  companyEmail: string;
  companyWebsite: string;
  companyLogo:string;
}


const businessDetailsSchema = new Schema<BusinessDetails>({
  companyName: { type: String, default: '' },
  companyAddress: { type: String, default: '' },
  companyMobile: { type: String, default: '' },
  companyEmail: { type: String, default: '' },
  companyWebsite: { type: String, default: '' },
  companyLogo:{ type: String, default: '' }
});


const userSchema = new Schema<User>(
  {
    username: { type: String, default: ''},
    isDeleted: { type: Boolean, default: false },
    email: { type: String, unique: true, lowercase: true, default: '' },
    profileImage: { type: String, default: '' },
    lastLogin: { type: Date, default: null },
    isActive: { type: Boolean, default: true },
    permissions: { type: [String], default: [] },
    fcmToken: { type: String, default: '' },
    mobile: { type: String, unique: true, required: true, default: '' },
    department: { type: String, default: '' },
      selectedIndustries: [
      {
        industry: {
          type: Schema.Types.ObjectId,
          ref: 'Industry',  // Explicit ref for population
          required: true
        },
        tags: {
          type: [String],
          default: []
        }
      }
    ],

    attachedLinks: [
      {
        category: {
          type: Schema.Types.ObjectId,
          ref: 'Links',
          required: true
        },
        subCategories: [
          {
            subCategoryId: {
              type: Schema.Types.ObjectId,
              required: true
            },
            url: {
              type: String,
              required: true,
              trim: true,
              validate: {
                validator: (v: string) => /^https?:\/\/.+/.test(v),
                message: 'URL must start with http:// or https://'
              }
            }
          }
        ]
      }
    ],
    subscriptionPlan: { type: String, enum: ['basic', 'pro', 'pro+'], default: 'basic' },
    slug: { type: String, unique: true, default: '' },
    businessDetails: { type: businessDetailsSchema, default: {} },
  },
  { timestamps: true }
);

export const UserModel = model<User>("User", userSchema);
