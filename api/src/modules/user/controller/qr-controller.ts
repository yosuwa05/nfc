import { Elysia, t } from "elysia";
import QRCode from "qrcode";
import { BadRequestError } from "@/lib/shared/bad-request";
import { userAuthMacro } from "../user-macro";

import { promises as fs } from "fs"; // Node.js File System (promises API)
import path from "path";
import { UserModel } from "@/schema/user/user-model";

// Interface for QR Response
interface QRResponse {
  status: boolean;
  message: string;
  qrCode?: string; // Base64-encoded PNG data URI
  userData?: string; // The encoded data for verification
  filePath?: string; // Path to saved QR code file (if saved)
}
const PLACEHOLDER_IMAGE_PATH = path.join(__dirname, 'qr', 'placeholder-profile.png'); // Adjust as needed

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

      // Fetch user data - CORRECTED populate paths
      const user = await UserModel.findById(userId)
        .select("username email mobile businessDetails selectedIndustries attachedLinks profileImage slug")
        .populate({
          path: "selectedIndustries.industry", // CORRECTED: industry instead of industryId
          model: "Industry",
        })
        .populate({
          path: "attachedLinks.category", // CORRECTED: category instead of categoryId
          model: "Links",
        });

      if (!user) {
        throw new BadRequestError("User not found");
      }

      // Use the slug from the schema
      const profileSlug = user.slug || user.username.toLowerCase().replace(/\s+/g, '-');
      const qrData = `https://kingschic.com/profile?slug=${profileSlug}`;

      // Determine logo path
      let logoPath: string;
      if (user.profileImage) {
        logoPath = user.profileImage.startsWith('http') 
          ? await downloadImage(user.profileImage, `temp_${userId}.jpg`)
          : user.profileImage;
      } else {
        logoPath = PLACEHOLDER_IMAGE_PATH;
      }

      // Generate QR code
      const qrBuffer = await QRCode.toBuffer(qrData, {
        errorCorrectionLevel: "H",
        type: "png",
        quality: 0.92,
        margin: 1,
        color: {
          dark: "#000000",
          light: "#FFFFFF",
        },
        width: 256,
      });

      // Use Jimp to overlay the logo
      const qrImage = await Jimp.read(qrBuffer);
      const logoImage = await Jimp.read(logoPath);

      const logoSize = Math.floor(qrImage.bitmap.width * 0.2);
      logoImage.resize(logoSize, logoSize);
      logoImage.circle();

      const x = (qrImage.bitmap.width - logoSize) / 2;
      const y = (qrImage.bitmap.height - logoSize) / 2;

      qrImage.composite(logoImage, x, y);

      const qrBase64 = await qrImage.getBase64Async(Jimp.MIME_PNG);

      const response: QRResponse = {
        status: true,
        message: "QR code generated successfully",
        qrCode: qrBase64,
        userData: qrData,
      };

      // Save to local filesystem if save=true
      if (save === "true") {
        const qrDir = path.join(__dirname, "qrcodes");
        const fileName = `qr_${userId}_${Date.now()}.png`;
        const filePath = path.join(qrDir, fileName);

        try {
          await fs.mkdir(qrDir, { recursive: true });
        } catch (error) {
          throw new Error("Failed to create QR code directory");
        }

        await qrImage.writeAsync(filePath);
        response.filePath = filePath;
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
      description: "Generates a QR code containing the user's profile URL (using slug) as a base64 PNG data URI with profile image (or placeholder) overlaid in the center. Optionally saves it as a PNG file to the local filesystem if save=true.",
    },
    params: t.Object({
      userId: t.String({
        pattern: "^[0-9a-fA-F]{24}$",
        error: "Invalid user ID format",
      }),
    }),
    query: t.Object({
      save: t.Optional(t.String({ pattern: "^(true|false)$" })),
    }),
  }
)

  async function downloadImage(url: string, filename: string): Promise<string> {
  const https = require('https');
  const fs = require('fs');
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(filename);
    https.get(url, (response: { pipe: (arg0: any) => void; }) => {
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve(filename);
      });
    }).on('error', (err: any) => {
      fs.unlink(filename, () => {}); // Delete partial file
      reject(err);
    });
  });
}