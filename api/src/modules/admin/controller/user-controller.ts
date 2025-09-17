import { BadRequestError } from "@/lib/shared/bad-request";
import { UserModel } from "@/schema/user/user-model";
import Elysia, { t } from "elysia";
import { convertTime } from "@/lib/timeConversion";
import { deleteFile, saveFile } from "@/lib/file";
import { adminAuthMacro } from "../admin-macro";
import { IndustryModel } from "@/schema/admin/industries-model";
import { linkModel } from "@/schema/admin/link-model";

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
  interface CategoryRequest {
  name: string;
  subCategories: SubCategory[];
  isActive?: boolean;
}
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

export const userController = new Elysia({
    prefix: "/user",
    tags: ["Admin-User"],
  })
  .use(adminAuthMacro)
  .guard({ isAuth: true }) 
 
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

  
  .post(
    "/",
    async ({ body, set }) => {
      try {
        const { name, subCategories, isActive } = body;

        // Validate subcategory names are unique
        const subCategoryNames = subCategories.map((sub) => sub.name);
        const uniqueSubCategoryNames = new Set(subCategoryNames);
        if (uniqueSubCategoryNames.size !== subCategoryNames.length) {
          throw new BadRequestError("Subcategory names must be unique within a category");
        }

        // Check if category name already exists
        const existingCategory = await linkModel.findOne({ name, isActive: true });
        if (existingCategory) {
          throw new BadRequestError("Category name already exists");
        }

        const newCategory = new linkModel({
          name,
          subCategories,
          isActive: isActive !== undefined ? isActive : true,
        });

        await newCategory.save();

        set.status = 201;
        return {
          status: true,
          message: "Category created successfully",
          data: newCategory,
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
        summary: "Create a new category",
        description: "Creates a new category with subcategories",
      },
      body: t.Object({
        name: t.String({
          minLength: 1,
          maxLength: 50,
          error: "Category name is required and must not exceed 50 characters",
        }),
        subCategories: t.Array(
          t.Object({
            name: t.String({
              minLength: 1,
              maxLength: 50,
              error: "Subcategory name is required and must not exceed 50 characters",
            }),
            icon: t.Optional(t.String()),
            isActive: t.Optional(t.Boolean()),
          })
        ),
        isActive: t.Optional(t.Boolean()),
      }),
    }
  )
  .get(
    "/",
    async ({ query, set }) => {
      try {
        const { isActive } = query;

        const filter: { isActive?: boolean } = {};
        if (isActive !== undefined) {
          filter.isActive = isActive === "true";
        }

        const categories = await linkModel.find(filter).sort({ createdAt: -1 });

        set.status = 200;
        return {
          status: true,
          message: "Categories retrieved successfully",
          data: categories,
        };
      } catch (error) {
        set.status = 500;
        return {
          status: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Get all categories",
        description: "Retrieve a list of categories, optionally filtered by isActive status",
      },
      query: t.Object({
        isActive: t.Optional(t.String({ pattern: "^(true|false)$" })),
      }),
    }
  )
  .get(
    "/:id",
    async ({ params, set }) => {
      try {
        const { id } = params;

        const category = await linkModel.findById(id);
        if (!category) {
          throw new BadRequestError("Category not found");
        }

        set.status = 200;
        return {
          status: true,
          message: "Category retrieved successfully",
          data: category,
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
        summary: "Get a category by ID",
        description: "Retrieve a single category by its ID",
      },
      params: t.Object({
        id: t.String(),
      }),
    }
  )
  .patch(
    "/:id",
    async ({ params, body, set }) => {
      try {
        const { id } = params;
        const { name, subCategories, isActive } = body;

        // Check if category exists
        const category = await linkModel.findById(id);
        if (!category) {
          throw new BadRequestError("Category not found");
        }

        // If updating name, check for uniqueness
        if (name && name !== category.name) {
          const existingCategory = await linkModel.findOne({ name, isActive: true });
          if (existingCategory) {
            throw new BadRequestError("Category name already exists");
          }
        }

        // If updating subcategories, ensure names are unique
        if (subCategories) {
          const subCategoryNames = subCategories.map((sub) => sub.name);
          const uniqueSubCategoryNames = new Set(subCategoryNames);
          if (uniqueSubCategoryNames.size !== subCategoryNames.length) {
            throw new BadRequestError("Subcategory names must be unique within a category");
          }
        }

        // Update fields
        const updateData: Partial<CategoryRequest> = {};
        if (name) updateData.name = name;
        if (subCategories) updateData.subCategories = subCategories;
        if (isActive !== undefined) updateData.isActive = isActive;

        const updatedCategory = await linkModel.findByIdAndUpdate(
          id,
          { $set: updateData },
          { new: true }
        );

        if (!updatedCategory) {
          throw new BadRequestError("Failed to update category");
        }

        set.status = 200;
        return {
          status: true,
          message: "Category updated successfully",
          data: updatedCategory,
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
        summary: "Update a category",
        description: "Update a category's name, subcategories, or active status",
      },
      params: t.Object({
        id: t.String(),
      }),
      body: t.Object({
        name: t.Optional(
          t.String({
            minLength: 1,
            maxLength: 50,
            error: "Category name must not exceed 50 characters",
          })
        ),
        subCategories: t.Optional(
          t.Array(
            t.Object({
              name: t.String({
                minLength: 1,
                maxLength: 50,
                error: "Subcategory name is required and must not exceed 50 characters",
              }),
              icon: t.Optional(t.String()),
              isActive: t.Optional(t.Boolean()),
            })
          )
        ),
        isActive: t.Optional(t.Boolean()),
      }),
    }
  )
  .delete(
    "/:id",
    async ({ params, query, set }) => {
      try {
        const { id } = params;
        const { hardDelete } = query;

        const category = await linkModel.findById(id);
        if (!category) {
          throw new BadRequestError("Category not found");
        }

        if (hardDelete === "true") {
          // Hard delete
          await linkModel.deleteOne({ _id: id });
          set.status = 200;
          return {
            status: true,
            message: "Category permanently deleted",
          };
        } else {
          // Soft delete (set isActive to false)
          const updatedCategory = await linkModel.findByIdAndUpdate(
            id,
            { isActive: false },
            { new: true }
          );
          if (!updatedCategory) {
            throw new BadRequestError("Failed to soft delete category");
          }
          set.status = 200;
          return {
            status: true,
            message: "Category soft deleted successfully",
            data: updatedCategory,
          };
        }
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
        summary: "Delete a category",
        description: "Soft delete (set isActive to false) or hard delete a category",
      },
      params: t.Object({
        id: t.String(),
      }),
      query: t.Object({
        hardDelete: t.Optional(t.String({ pattern: "^(true|false)$" })),
      }),
    }
  )



  .post(
  "/upload-image",
  async ({ body, set }) => {
    try {
      const { image } = body;

      // Validate image
      if (!image || !(image instanceof File)) {
        throw new BadRequestError("Image is required and must be a valid file");
      }

      // Save the image
      const parentFolder = "industry-images";
      const saveResult = await saveFile(image, parentFolder);

      if (!saveResult.ok || !saveResult.filename) {
        throw new BadRequestError("Failed to save image");
      }

      set.status = 201;
      return {
        success: true,
        message: "Image uploaded successfully",
        data: {
          filename: saveResult.filename,
        },
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
      summary: "Upload Industry Image",
      description: "Upload an image to the industry-images folder",
    },
    body: t.Object({
      image: t.File({
        type: ["image/png", "image/jpeg", "image/gif"],
      }),
    }),
  }
);