import { Schema, model, Document } from "mongoose";

interface SubCategory {
  _id?: string;       // Add this to include the generated ID in your TypeScript interface
  name: string;
  icon?: string;
  isActive?: boolean;
}

interface Category extends Document {
  name: string;
  subCategories: SubCategory[];
  isActive?: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

const subCategorySchema = new Schema<SubCategory>({
  name: {
    type: String,
    required: [true, "Subcategory name is required"],
    trim: true,
    maxlength: [50, "Subcategory name cannot exceed 50 characters"],
  },
  icon: {
    type: String,
    trim: true,
    default: "",
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, { _id: true });  // ← This is the critical addition

const linkSchema = new Schema<Category>(
  {
    name: {
      type: String,
      required: [true, "Category name is required"],
      trim: true,
      maxlength: [50, "Category name cannot exceed 50 characters"],
      unique: true,
    },
    subCategories: [subCategorySchema],
    isActive: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

export const linkModel = model<Category>("Links", linkSchema);
