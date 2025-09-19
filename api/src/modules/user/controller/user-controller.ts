import Elysia, { t } from "elysia";
import { BadRequestError } from "@/lib/shared/bad-request";
import { userAuthMacro } from "../user-macro";
import { convertTime } from "@/lib/timeConversion";
import { deleteFile, saveFile } from "@/lib/file";
import { IndustryModel } from "@/schema/admin/industries-model";
import { linkModel } from "@/schema/admin/link-model";
import { UserModel } from "@/schema/user/user-model";
import { Types } from "mongoose";

// Interface for SubCategory
interface SubCategory {
  name: string;
  icon?: string;
  isActive?: boolean;
}

// Interface for Category (Links)
interface Category extends Document {
  name: string;
  subCategories: SubCategory[];
  isActive?: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

// Interface for Industry
interface Industry extends Document {
  title: string;
  image: string;
  tags: string[]; // Added tags field
  isActive: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}
// Interface for Create/Update Request Body
interface CategoryRequest {
  name: string;
  subCategories: SubCategory[];
  isActive?: boolean;
}

// Interface for Response
interface CategoryResponse {
  status: boolean;
  message: string;
  data?: Category | Category[];
}
// Interface for BusinessDetails
interface BusinessDetails {
  companyName: string;
  companyAddress: string;
  companyMobile: string;
  companyEmail: string;
  companyWebsite: string;
}

// Interface for SocialMedia
interface SocialMedia {
  facebook: string;
  x: string;
  whatsapp: string;
  youtube: string;
  instagram: string;
}

// Interface for User
interface User extends Document {
  username: string;
  email: string;
  role: string;
  profileImage?: string;
  lastLogin?: Date;
  isActive: boolean;
  permissions: string[];
  isDeleted: boolean;
  fcmToken?: string;
  mobile?: string;
  department?: string;
  slug?: string;
  businessDetails?: BusinessDetails;
  socialMedia?: SocialMedia;
  subscriptionPlan?: string;
  selectedIndustries: Types.ObjectId[]; // Reference to IndustryModel
  attachedLinks: Types.ObjectId[]; // Reference to linkModel
  businessImages: string[];
}


// User Controller
export const userController = new Elysia({
  prefix: "/user",
  tags: ["User"],
})
  .use(userAuthMacro)
  .guard({ isAuth: true })
  .get(
    "/details",
    async ({ query, set }) => {
      try {
        const { userId } = query;

        if (!userId) {
          throw new BadRequestError("User ID is required");
        }

        const existingUser = await UserModel.findOne({
          _id: userId,
          isDeleted: false,
        })
          // .populate("selectedIndustries")
          // .populate("attachedLinks");

        if (!existingUser) {
          throw new BadRequestError("User not found");
        }

        set.status = 200;
        const { _id, ...rest } = existingUser.toObject();
        return {
          status: true,
          message: "User retrieved successfully",
           data: {
    ...rest,
    userId: _id, // rename _id → userId
  },
        };
      } catch (error) {
        set.status = 400;
        return {
          status: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Retrieve a user by user ID",
      },
      query: t.Object({
        userId: t.String(),
      }),
    }
  )
  .get(
    "/flags",
    async ({ query, set }) => {
      try {
        const { userId } = query;

        if (!userId) {
          throw new BadRequestError("User ID is required");
        }

        const existingUser = await UserModel.findOne({
          _id: userId,
          isDeleted: false,
        })
          .populate("selectedIndustries")
          .populate("attachedLinks") as any;

        if (!existingUser) {
          throw new BadRequestError("User not found");
        }

        // Define flags and check their status
        const businessDetailsFlag = !!(
          existingUser.businessDetails &&
          existingUser.businessDetails.companyName
        );

        const profilePictureFlag = !!existingUser.profileImage;

        const selectedIndustriesFlag =
          Array.isArray(existingUser.selectedIndustries) &&
          existingUser.selectedIndustries.length > 0;

        const attachedLinksFlag =
          Array.isArray(existingUser.attachedLinks) &&
          existingUser.attachedLinks.length > 0;

        const businessImagesFlag =
          Array.isArray(existingUser.businessImages) &&
          existingUser.businessImages.length > 0;

        set.status = 200;
        return {
          status: true,
          message: "User retrieved successfully",
          flags: {
            businessDetails: businessDetailsFlag,
            profilePicture: profilePictureFlag,
            selectedIndustries: selectedIndustriesFlag,
            attachedLinks: attachedLinksFlag,
            businessImages: businessImagesFlag,
          },
          data: {
            businessDetails: existingUser.businessDetails ?? {},
            profilePicture: existingUser.profileImage ?? "",
            selectedIndustries: existingUser.selectedIndustries ?? [],
            attachedLinks: existingUser.attachedLinks ?? [],
            businessImages: existingUser.businessImages ?? [],
          },
        };
      } catch (error) {
        set.status = 400;
        return {
          status: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Retrieve a user by user ID and check specified flags",
      },
      query: t.Object({
        userId: t.String(),
      }),
    }
  )
 .patch(
  "/business-details",
  async ({ query, body, set }) => {
    try {
      const { userId } = query;
      const { businessDetails } = body;

      if (!userId || !businessDetails) {
        throw new BadRequestError("User ID and business details are required");
      }

      const user = await UserModel.findById(userId);
      if (!user) {
        throw new BadRequestError("User not found");
      }

      // Initialize with existing logo if no new logo provided
      let logoFilename = user.businessDetails?.companyLogo;
      let shouldUpdateLogo = false;

      // Handle logo if provided in businessDetails
      if (businessDetails.companyLogo) {
        const parentFolder = "company-logos";
        const saveResult = saveFile(businessDetails.companyLogo, parentFolder);

        if (!saveResult.ok || !saveResult.filename) {
          throw new BadRequestError("Failed to save company logo");
        }

        logoFilename = saveResult.filename;
        shouldUpdateLogo = true;
      }

      // Prepare updated business details
      const updatedBusinessDetails = {
        ...businessDetails,
        companyLogo: logoFilename // Use either new or existing logo
      };

      // Update user
      const updatedUser = await UserModel.findByIdAndUpdate(
        userId,
        {
          businessDetails: updatedBusinessDetails,
          updatedAt: convertTime(),
        },
        { new: true }
      );

      if (!updatedUser) {
        // Clean up new logo if update failed
        if (shouldUpdateLogo && logoFilename) {
          await deleteFile(logoFilename, "company-logos");
        }
        throw new BadRequestError("Failed to update business details");
      }

      // Delete old logo if we successfully updated with a new one
      if (shouldUpdateLogo && user.businessDetails?.companyLogo) {
        const deleteResult = await deleteFile(user.businessDetails.companyLogo, "company-logos");
        if (!deleteResult.ok) {
          console.warn(`Failed to delete old company logo: ${user.businessDetails.companyLogo}`);
        }
      }

      set.status = 200;
      return {
        status: true,
        message: "Business details updated successfully",
        data: updatedUser.businessDetails,
      };
    } catch (error) {
      set.status = 400;
      return {
        status: false,
        message: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
  {
    detail: {
      summary: "Update business details of a user",
      description: "Updates all business details including company logo (handles file upload and replacement)",
    },
    query: t.Object({
      userId: t.String(),
    }),
    body: t.Object({
      businessDetails: t.Object({
        companyName: t.String(),
        companyAddress: t.String(),
        companyMobile: t.String(),
        companyEmail: t.String(),
        companyWebsite: t.String(),
        companyLogo: t.Optional(t.Any()), 
      }),
    }),
  }
)

  .post(
    "/profile-image",
    async ({ query, body, set }) => {
      try {
        const { userId } = query;
        const { profileImage } = body;

        if (!userId || !profileImage) {
          throw new BadRequestError("User ID and profile image are required");
        }

        const user = await UserModel.findById(userId);
        if (!user) {
          throw new BadRequestError("User not found");
        }

        const parentFolder = "profile-images";
        const saveResult = saveFile(profileImage, parentFolder);
        if (!saveResult.ok || !saveResult.filename) {
          throw new BadRequestError("Failed to save profile image");
        }

        if (user.profileImage) {
          const deleteResult = await deleteFile(user.profileImage, parentFolder);
          if (!deleteResult.ok) {
            console.warn(`Failed to delete old profile image: ${user.profileImage}`);
          }
        }

        const updatedUser = await UserModel.findByIdAndUpdate(
          userId,
          {
            profileImage: saveResult.filename,
            updatedAt: convertTime(),
          },
          { new: true }
        );

        if (!updatedUser) {
          await deleteFile(saveResult.filename, parentFolder);
          throw new BadRequestError("Failed to update user profile");
        }

        set.status = 200;
        return {
          status: true,
          message: "Profile image updated successfully",
        };
      } catch (error) {
        set.status = 400;
        return {
          status: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Update profile image of a user",
        description: "Handles file upload for user profile image, deletes old image if exists, and updates user record",
      },
      query: t.Object({
        userId: t.String(),
      }),
      body: t.Object({
        profileImage: t.Any(),
      }),
    }
  )
.patch(
  "/selected-industries",
  async ({ query, body, set }) => {
    try {
      const { userId } = query;
      const { selectedIndustries } = body; // Expects: [{ industry: ObjectId, tags: string[] }]

      if (!userId || !selectedIndustries) {
        throw new BadRequestError("User ID and selected industries are required");
      }

      // Validate industries exist
      const industryIds = selectedIndustries.map((item: any) => item.industry);
      const industriesExist = await IndustryModel.find({ _id: { $in: industryIds } });
      if (industriesExist.length !== industryIds.length) {
        throw new BadRequestError("One or more industries not found");
      }

      // Update the user's selectedIndustries (replaces the entire array)
      const updatedUser = await UserModel.findByIdAndUpdate(
        userId,
        { selectedIndustries }, // Directly assign the new array
        { new: true }
      ).populate("selectedIndustries.industry");

      if (!updatedUser) {
        throw new BadRequestError("User not found");
      }

      set.status = 200;
      return {
        status: true,
        message: "Selected industries updated successfully",
        data: updatedUser.selectedIndustries,
      };
    } catch (error) {
      set.status = 400;
      return {
        status: false,
        message: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
  {
    detail: { summary: "Update selected industries of a user" },
    query: t.Object({ userId: t.String() }),
    body: t.Object({
      selectedIndustries: t.Array(
        t.Object({
          industry: t.String(), // ObjectId as string
          tags: t.Array(t.String())
        })
      )
    }),
  }
)

.patch(
  "/attached-links",
  async ({ query, body, set }) => {
    try {
      const { userId } = query;
      const { attachedLinks } = body;

      if (!userId || !attachedLinks) {
        throw new BadRequestError("User ID and attached links are required");
      }

      // Validate categories exist
      const categoryIds = attachedLinks.map((item: any) => item.category);
      const categoriesExist = await linkModel.find({ _id: { $in: categoryIds } });
      if (categoriesExist.length !== categoryIds.length) {
        throw new BadRequestError("One or more categories not found");
      }

      // Validate subcategories exist and belong to their parent category
      for (const link of attachedLinks) {
        const category = await linkModel.findById(link.category);
        if (!category) continue;

        for (const sub of link.subCategories) {
          const subExists = category.subCategories.some(
            (sc: any) => sc._id.toString() === sub.subCategoryId.toString()
          );
          if (!subExists) {
            throw new BadRequestError(
              `Subcategory ${sub.subCategoryId} not found in category ${link.category}`
            );
          }
        }
      }

      // Update the user's attachedLinks
      const updatedUser = await UserModel.findByIdAndUpdate(
        userId,
        { attachedLinks },
        { new: true }
      ).populate({
        path: 'attachedLinks.category',
        model: 'Links'
      });

      if (!updatedUser) {
        throw new BadRequestError("User not found");
      }

      set.status = 200;
      return {
        status: true,
        message: "Attached links updated successfully",
        data: updatedUser.attachedLinks,
      };
    } catch (error) {
      set.status = 400;
      return {
        status: false,
        message: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
  {
    detail: { summary: "Update attached links of a user" },
    query: t.Object({ userId: t.String() }),
    body: t.Object({
      attachedLinks: t.Array(
        t.Object({
          category: t.String(), // Category ObjectId
          subCategories: t.Array(
            t.Object({
              subCategoryId: t.String(), // SubCategory ObjectId
              url: t.String()           // URL for the subcategory
            })
          )
        })
      )
    }),
  }
)

.patch(
  "/business-images",
  async ({ query, body, set }) => {
    try {
      const { userId } = query;
      const { businessImages } = body;

      if (!userId || !businessImages) {
        throw new BadRequestError("User ID and business images are required");
      }

      const user = await UserModel.findById(userId);
      if (!user) {
        throw new BadRequestError("User not found");
      }

      const parentFolder = "business-images";
      const savedFilenames: string[] = [];
      const oldFilenames = user.businessImages || [];

      // Save new images and track successful uploads
      for (const image of businessImages) {
        const saveResult = await saveFile(image, parentFolder);
        if (!saveResult.ok || !saveResult.filename) {
          // Clean up any already saved files if one fails
          for (const filename of savedFilenames) {
            await deleteFile(filename, parentFolder);
          }
          throw new BadRequestError("Failed to save business images");
        }
        savedFilenames.push(saveResult.filename);
      }

      // Update user with new image filenames
      const updatedUser = await UserModel.findByIdAndUpdate(
        userId,
        { businessImages: savedFilenames },
        { new: true }
      );

      if (!updatedUser) {
        // Clean up new images if update failed
        for (const filename of savedFilenames) {
          await deleteFile(filename, parentFolder);
        }
        throw new BadRequestError("Failed to update business images");
      }

      // Delete old images after successful update
      for (const oldFilename of oldFilenames) {
        const deleteResult = await deleteFile(oldFilename, parentFolder);
        if (!deleteResult.ok) {
          console.warn(`Failed to delete old business image: ${oldFilename}`);
        }
      }

      set.status = 200;
      return {
        status: true,
        message: "Business images updated successfully",
        data: updatedUser.businessImages ?? [],
      };
    } catch (error) {
      set.status = 400;
      return {
        status: false,
        message: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
  {
    detail: {
      summary: "Update business images of a user",
      description: "Handles file upload, replacement, and cleanup for business images",
    },
    query: t.Object({
      userId: t.String(),
    }),
    body: t.Object({
      businessImages: t.Array(t.Any()), // Changed from t.String() to t.Any() to accept file data
    }),
  }
)

  .get(
    "/industries",
    async ({ set }) => {
      try {
        const industries = await IndustryModel.find().sort({ createdAt: -1 });

        set.status = 200;
        return {
          success: true,
          message: "Industries fetched successfully",
          data: industries,
        };
      } catch (error) {
        set.status = 500;
        return {
          success: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Get All Industries",
        description: "Fetch a list of all industries with their images and tags",
      },
    }
  )
  .get(
  "/links",
  async ({ set }) => {
    try {
      // Fetch all categories with subcategories, sorted by creation date (newest first)
      const links = await linkModel
        .find({ isActive: true }) // Optional: Only active categories
        .sort({ createdAt: -1 })
        .lean();

      set.status = 200;
      return {
        success: true,
        message: "Links fetched successfully",
        data: links,
      };
    } catch (error) {
      set.status = 500;
      return {
        success: false,
        message: error instanceof Error ? error.message : "Unknown error",
      };
    }
  },
  {
    detail: {
      summary: "Get All Links",
      description: "Fetch a list of all categories and their subcategories (e.g., Social, Technology)",
    },
  }
)

  .patch(
    "/industry-tags",
    async ({ query, body, set }) => {
      try {
        const { industryId } = query;
        const { tags } = body;

        if (!industryId || !tags) {
          throw new BadRequestError("Industry ID and tags are required");
        }

        const updatedIndustry = await IndustryModel.findByIdAndUpdate(
          industryId,
          { tags },
          { new: true }
        );

        if (!updatedIndustry) {
          throw new BadRequestError("Industry not found");
        }

        set.status = 200;
        return {
          status: true,
          message: "Industry tags updated successfully",
          data: updatedIndustry.tags,
        };
      } catch (error) {
        set.status = 400;
        return {
          status: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Update tags for an industry",
      },
      query: t.Object({
        industryId: t.String(),
      }),
      body: t.Object({
        tags: t.Array(t.String()),
      }),
    }
  )
