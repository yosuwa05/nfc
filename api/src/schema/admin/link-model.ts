import { Schema, model, Document } from "mongoose";

interface SubCategory {
  name: string;
  icon?: string; // Optional field for icon URL or name
  isActive?: boolean; // Optional field to toggle subcategory status
}

interface Category extends Document {
  name: string;
  subCategories: SubCategory[];
  isActive?: boolean; // Optional field to toggle category status
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
    default: "", // Optional icon URL or name
  },
  isActive: {
    type: Boolean,
    default: true, // Subcategory is active by default
  },
});

const categorySchema = new Schema<Category>(
  {
    name: {
      type: String,
      required: [true, "Category name is required"],
      trim: true,
      maxlength: [50, "Category name cannot exceed 50 characters"],
      unique: true, // Ensure category names are unique
    },
    subCategories: [subCategorySchema], // Array of subcategories
    isActive: {
      type: Boolean,
      default: true, // Category is active by default
    },
  },
  {
    timestamps: true, // Automatically adds createdAt and updatedAt
  }
);

export const CategoryModel = model<Category>("Category", categorySchema);