import { Schema, model, Document, Types } from "mongoose";

interface ProfileVisitor extends Document {
  profileId: Types.ObjectId;   
  viewerId: Types.ObjectId;   
  visitedAt: Date;
}

const profileVisitorSchema = new Schema<ProfileVisitor>(
  {
    profileId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    viewerId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    visitedAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
)

// Make sure one viewer can only have one entry per profile
profileVisitorSchema.index({ profileId: 1, viewerId: 1 }, { unique: true });

export const ProfileVisitorModel = model<ProfileVisitor>("ProfileVisitor", profileVisitorSchema);
