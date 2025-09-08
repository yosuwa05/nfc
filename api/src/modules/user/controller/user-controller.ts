import { BadRequestError } from "@/lib/shared/bad-request";
import { UserModel } from "@/schema/user-model";
import Elysia, { t } from "elysia";
import { userAuthMacro } from "../user-macro";
import { convertTime } from "@/lib/timeConversion";
import { deleteFile, saveFile } from "@/lib/file";

interface UserResponse {
    businessImages: boolean;
    attachedLinks: boolean;
    selectedIndustries: boolean;
    profileImage: any;
    businessDetails: any;
    status: boolean;
    message: string;
    flags: {
      businessDetails: boolean;
      profilePicture: boolean;
      selectedIndustries: boolean;
      attachedLinks: boolean;
      businessImages: boolean;
    };
    filledValues: {
      businessDetails: {
        companyName: string;
        companyAddress: string;
        companyMobile: string;
        companyEmail: string;
        companyWebsite: string;
      };
      profilePicture: string;
      selectedIndustries: string[];
      attachedLinks: string[];
      businessImages: string[];
    };
  }

export const userController = new Elysia({
    prefix: "/",
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
      });

      if (!existingUser) {
        throw new BadRequestError("User not found");
      }

      set.status = 200;
      return {
        status: true,
        message: "User retrieved successfully",
        data: existingUser,
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
      }) as UserResponse;

      if (!existingUser) {
        throw new BadRequestError("User not found");
      }

      // Define flags and check their status
      const businessDetailsFlag = !!(
        existingUser.businessDetails &&
        existingUser.businessDetails.companyName
      );

      const profilePictureFlag = !!existingUser.profileImage;

      const selectedIndustriesFlag = !!(
        existingUser.selectedIndustries &&
        Array.isArray(existingUser.selectedIndustries) &&
        existingUser.selectedIndustries.length > 0
      );

      const attachedLinksFlag = !!(
        existingUser.attachedLinks &&
        Array.isArray(existingUser.attachedLinks) &&
        existingUser.attachedLinks.length > 0
      );

      const businessImagesFlag = !!(
        existingUser.businessImages &&
        Array.isArray(existingUser.businessImages) &&
        existingUser.businessImages.length > 0
      );

      // Return results
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

        const updatedUser = await UserModel.findByIdAndUpdate(
          userId,
          { businessDetails },
          { new: true }
        );

        if (!updatedUser) {
          throw new BadRequestError("User not found");
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
  
        // Find the user to get the existing profile image (if any)
        const user = await UserModel.findById(userId);
        if (!user) {
          throw new BadRequestError("User not found");
        }
  
        // Save the new profile image
        const parentFolder = "profile-images";
        const saveResult = saveFile(profileImage, parentFolder);
        if (!saveResult.ok || !saveResult.filename) {
          throw new BadRequestError("Failed to save profile image");
        }
  
        // Delete the old profile image if it exists
        if (user.profileImage) {
          const deleteResult = await deleteFile(user.profileImage, parentFolder);
          if (!deleteResult.ok) {
            console.warn(`Failed to delete old profile image: ${user.profileImage}`);
          }
        }
  
        // Update user with new profile image path and last updated time
        const updatedUser = await UserModel.findByIdAndUpdate(
          userId,
          {
            profileImage: saveResult.filename,
            updatedAt: convertTime(),
          },
          { new: true }
        );
  
        if (!updatedUser) {
          // Cleanup: delete the newly saved file if user update fails
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
        profileImage: t.Any(), // Blob or file input
      }),
    }
  )
  .patch(
    "/selected-industries",
    async ({ query, body, set }) => {
      try {
        const { userId } = query;
        const { selectedIndustries } = body;

        if (!userId || !selectedIndustries) {
          throw new BadRequestError("User ID and selected industries are required");
        }

        const updatedUser = await UserModel.findByIdAndUpdate(
          userId,
          { selectedIndustries },
          { new: true }
        );

        if (!updatedUser) {
          throw new BadRequestError("User not found");
        }

        set.status = 200;
        return {
          status: true,
          message: "Selected industries updated successfully",
          data: (updatedUser as any).selectedIndustries,
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
        summary: "Update selected industries of a user",
      },
      query: t.Object({
        userId: t.String(),
      }),
      body: t.Object({
        selectedIndustries: t.Array(t.String()),
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

        const updatedUser = await UserModel.findByIdAndUpdate(
          userId,
          { attachedLinks },
          { new: true }
        );

        if (!updatedUser) {
          throw new BadRequestError("User not found");
        }

        set.status = 200;
        return {
          status: true,
          message: "Attached links updated successfully",
          data: (updatedUser as any).attachedLinks,
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
        summary: "Update attached links of a user",
      },
      query: t.Object({
        userId: t.String(),
      }),
      body: t.Object({
        attachedLinks: t.Array(t.String()),
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

        const updatedUser = await UserModel.findByIdAndUpdate(
          userId,
          { businessImages },
          { new: true }
        );

        if (!updatedUser) {
          throw new BadRequestError("User not found");
        }

        set.status = 200;
        return {
          status: true,
          message: "Business images updated successfully",
          data: (updatedUser as any).businessImages ?? [],
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
      },
      query: t.Object({
        userId: t.String(),
      }),
      body: t.Object({
        businessImages: t.Array(t.String()),
      }),
    }
  )
  