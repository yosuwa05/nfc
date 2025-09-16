import { Schema, model, Document } from "mongoose";

interface Industry extends Document {
  title: string;
  image: string;
  isActive: boolean;
  createdAt?: Date; // Provided by timestamps
  updatedAt?: Date; // Provided by timestamps
}

const industrySchema = new Schema<Industry>(
  {
    title: {
      type: String,
      required: [true, "Title is required"],
      trim: true,
      maxlength: [100, "Title cannot exceed 100 characters"],
      unique: true
    },
    image: {
      type: String,
      required: [true, "Image URL is required"],
      trim: true,
      default: ""
    },
    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

export const IndustryModel = model<Industry>("Industry", industrySchema);
