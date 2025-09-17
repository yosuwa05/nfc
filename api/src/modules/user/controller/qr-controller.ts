import { Elysia, t } from "elysia";
import QRCode from "qrcode";
import { BadRequestError } from "@/lib/shared/bad-request";
import { userAuthMacro } from "../user-macro";

import { promises as fs } from "fs"; // Node.js File System (promises API)
import path from "path";
import { UserModel } from "@/schema/user/user-model";

// Hardcoded dummy user data
const dummyUserData = {
  id: "64f123456789abcdef999999",
  username: "dummy_user",
  email: "dummy.user@example.com",
  mobile: "+1234567890",
  company: "Dummy Corp",
  industries: [
    { title: "Civil", tags: ["structural", "surveying"] },
    { title: "Architecture", tags: ["modern", "sustainable"] },
  ],
  links: [
    {
      category: "Social",
      userLinks: [
        { subCategory: "facebook", url: "https://facebook.com/dummyuser", icon: "fa-facebook" },
        { subCategory: "instagram", url: "https://instagram.com/dummyuser", icon: "fa-instagram" },
      ],
    },
    {
      category: "Creativity",
      userLinks: [
        { subCategory: "behance", url: "https://behance.net/dummyuser", icon: "fa-behance" },
        { subCategory: "figma", url: "https://figma.com/@dummyuser", icon: "fa-figma" },
      ],
    },
  ],
};

// Interface for QR Response
interface QRResponse {
  status: boolean;
  message: string;
  qrCode?: string; // Base64-encoded PNG data URI
  userData?: string; // The encoded data for verification
  filePath?: string; // Path to saved QR code file (if saved)
}

export const qrController = new Elysia({
  prefix: "/qr",
  tags: ["QR"],
})
//   .use(userAuthMacro)
//   .guard({ isAuth: true })
  .get(
    "/generate/:userId",
    async ({ params: { userId }, query: { save }, set }) => {
      try {
        // Validate userId
        if (!userId) {
          throw new BadRequestError("User ID is required");
        }

        // Fetch user data
        const user = await UserModel.findById(userId)
          .select("username email mobile businessDetails selectedIndustries attachedLinks")
          .populate({
            path: "selectedIndustries.industryId",
            model: "Industry",
          })
          .populate({
            path: "attachedLinks.categoryId",
            model: "Links",
          });

        if (!user) {
          throw new BadRequestError("User not found");
        }

        // Prepare data for QR code (JSON string with user details)
        const qrData = JSON.stringify({
          id: user._id,
          username: user.username,
          email: user.email,
          mobile: user.mobile,
          company: user.businessDetails?.companyName || "N/A",
          industries: user.selectedIndustries.map((ind) => ({
            title: (ind.industryId as any)?.title || "Unknown",
            tags: ind.tags,
          })),
          links: user.attachedLinks.map((link) => ({
            category: (link.categoryId as any)?.name || "Unknown",
            userLinks: link.userLinks,
          })),
        });

        // Alternative: Use a profile URL
        // const qrData = `https://yourapp.com/profile/${userId}`;

        // Generate QR code as base64 PNG data URI
        const qrImage = await QRCode.toDataURL(qrData, {
          errorCorrectionLevel: "H", // High error correction
          type: "image/png",
          quality: 0.92,
          margin: 1,
          color: {
            dark: "#000000",
            light: "#FFFFFF",
          },
          width: 256,
        });

        // Initialize response
        const response: QRResponse = {
          status: true,
          message: "QR code generated successfully",
          qrCode: qrImage,
          userData: qrData,
        };

        // Save to local filesystem if save=true
        if (save === "true") {
          const qrDir = path.join(__dirname, "qrcodes"); // Directory for QR codes
          const fileName = `qr_${userId}_${Date.now()}.png`; // Unique filename
          const filePath = path.join(qrDir, fileName);

          // Ensure directory exists
          try {
            await fs.mkdir(qrDir, { recursive: true });
          } catch (error) {
            throw new Error("Failed to create QR code directory");
          }

          // Save QR code to file
          await QRCode.toFile(filePath, qrData, {
            errorCorrectionLevel: "H",
            type: "png",
            width: 256,
          });

          response.filePath = filePath; // Add file path to response
          response.message = "QR code generated and saved successfully";
        }

        set.status = 200;
        return response;
      } catch (error) {
        set.status = error instanceof BadRequestError ? 400 : 500;
        return {
          status: false,
          message: error instanceof Error ? error.message : "Unknown error",
        };
      }
    },
    {
      detail: {
        summary: "Generate QR code for a user",
        description: "Generates a QR code containing user data as a base64 PNG data URI. Optionally saves it as a PNG file to the local filesystem if save=true.",
      },
      params: t.Object({
        userId: t.String({
          pattern: "^[0-9a-fA-F]{24}$", // MongoDB ObjectId format
          error: "Invalid user ID format",
        }),
      }),
      query: t.Object({
        save: t.Optional(t.String({ pattern: "^(true|false)$" })),
      }),
    }
  )
  .get(
    "/generate/dummy",
    async ({ set }) => {
      try {
        // Prepare dummy data for QR code
        const qrData = JSON.stringify(dummyUserData);

        // Generate QR code as base64 PNG data URI
        const qrImage = await QRCode.toDataURL(qrData, {
          errorCorrectionLevel: "H",
          type: "image/png",
          quality: 0.92,
          margin: 1,
          color: {
            dark: "#000000",
            light: "#FFFFFF",
          },
          width: 256,
        });

        // Save QR code to local filesystem
        const qrDir = path.join(__dirname, "qrcodes");
        const fileName = `qr_dummy_${Date.now()}.png`;
        const filePath = path.join(qrDir, fileName);

        // Ensure directory exists
        try {
          await fs.mkdir(qrDir, { recursive: true });
        } catch (error) {
          throw new Error("Failed to create QR code directory");
        }

        // Save QR code to file
        await QRCode.toFile(filePath, qrData, {
          errorCorrectionLevel: "H",
          type: "png",
          width: 256,
        });

        set.status = 200;
        return {
          status: true,
          message: "Dummy QR code generated and saved successfully",
          qrCode: qrImage,
          userData: qrData,
          filePath: filePath,
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
        summary: "Generate and save QR code for dummy user data",
        description: "Generates a QR code for hardcoded dummy user data as a base64 PNG data URI and saves it as a PNG file to the local filesystem.",
      },
    }
  );