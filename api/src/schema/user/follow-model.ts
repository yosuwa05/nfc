import { Schema, model } from "mongoose";

const followSchema = new Schema({
  follower: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  following: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  status: {
    type: String,
    enum: ['active', 'pending', 'rejected'],
    default: 'active'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Compound index for uniqueness (can't follow same user multiple times)
followSchema.index({ follower: 1, following: 1 }, { unique: true });

// Index for faster queries
followSchema.index({ follower: 1 });
followSchema.index({ following: 1 });
followSchema.index({ status: 1 });
followSchema.index({ createdAt: -1 });

export const FollowModel = model("Follow", followSchema);