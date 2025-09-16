import { BadRequestError } from "@/lib/shared/bad-request";
import { UserModel } from "@/schema/user/user-model";
import Elysia, { t } from "elysia";
import { convertTime } from "@/lib/timeConversion";
import { deleteFile, saveFile } from "@/lib/file";
import { adminAuthMacro } from "../admin-macro";
import { IndustryModel } from "@/schema/admin/industries-model";

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
    prefix: "/user",
    tags: ["User"],
  })
  .use(adminAuthMacro)
  .guard({ isAuth: true }) 
  
  // Add these endpoints to your industryController

// POST endpoint for creating an industry with image
.post(
    "/",
    async ({ body, set }) => {
      try {
        const { title, image } = body;
  
        if (!title || !image) {
          throw new BadRequestError("Title and image are required");
        }
  
        // Save the industry image
        const parentFolder = "industry-images";
        const saveResult = saveFile(image, parentFolder);
  
        if (!saveResult.ok || !saveResult.filename) {
          throw new BadRequestError("Failed to save industry image");
        }
  
        // Create new industry with image path
        const industry = new IndustryModel({
          title,
          image: saveResult.filename,
        });
  
        await industry.save();
  
        set.status = 201;
        return {
          success: true,
          message: "Industry created successfully",
          data: industry,
        };
      } catch (error) {
        set.status = 400;
        return {
          success: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Create Industry with Image",
        description: "Create a new industry with title and image upload",
      },
      body: t.Object({
        title: t.String({ minLength: 1, maxLength: 100 }),
        image: t.Any(), // Blob or file input
      }),
    }
  )
  
  // PUT endpoint for updating an industry image
  .put(
    "/:id/image",
    async ({ params: { id }, body, set }) => {
      try {
        const { image } = body;
  
        if (!id || !image) {
          throw new BadRequestError("Industry ID and image are required");
        }
  
        const industry = await IndustryModel.findById(id);
        if (!industry) {
          throw new BadRequestError("Industry not found");
        }
  
        // Save the new industry image
        const parentFolder = "industry-images";
        const saveResult = saveFile(image, parentFolder);
  
        if (!saveResult.ok || !saveResult.filename) {
          throw new BadRequestError("Failed to save industry image");
        }
  
        // Delete the old industry image if it exists
        if (industry.image) {
          const deleteResult = await deleteFile(industry.image, parentFolder);
          if (!deleteResult.ok) {
            console.warn(`Failed to delete old industry image: ${industry.image}`);
          }
        }
  
        // Update industry with new image path
        const updatedIndustry = await IndustryModel.findByIdAndUpdate(
          id,
          {
            image: saveResult.filename,
            updatedAt: convertTime(),
          },
          { new: true }
        );
  
        if (!updatedIndustry) {
          // Cleanup: delete the newly saved file if industry update fails
          await deleteFile(saveResult.filename, parentFolder);
          throw new BadRequestError("Failed to update industry image");
        }
  
        set.status = 200;
        return {
          success: true,
          message: "Industry image updated successfully",
          data: updatedIndustry,
        };
      } catch (error) {
        set.status = 400;
        return {
          success: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Update Industry Image",
        description: "Update the image of an existing industry",
      },
      params: t.Object({
        id: t.String({ format: "objectid" }),
      }),
      body: t.Object({
        image: t.Any(), // Blob or file input
      }),
    }
  )
  .get(
  "/",
  async ({ set }) => {
    try {
      // Fetch all industries from the database
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
      description: "Fetch a list of all industries with their images",
    },
  }
)

  