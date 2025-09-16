import * as crypto from "node:crypto";
import { Footer, Payload } from "paseto-ts/lib/types";
import { decrypt, encrypt, generateKeys } from "paseto-ts/v4";

type Roles = "admin" | "user" ;
class PasetoUtil {
  private static secretKey: string = process.env.PASETO_SECRET_KEY || "";
  private static adminSecretKey: string =
    process.env.PASETO_ADMIN_SECRET_KEY || "";
  private static getRandomValues(array: Uint8Array): Uint8Array {
    const bytes = crypto.randomBytes(array.length);
    array.set(bytes);
    return array;
  }

  public static getKey(): string {
    return generateKeys("local", {
      format: "paserk",
      getRandomValues: PasetoUtil.getRandomValues,
    });
  }

  public static async encodePaseto(
    payload: Record<string, string>,
    role: Roles
  ): Promise<string | null> {
    try {
      const key =
        role === "admin"
          ? PasetoUtil.adminSecretKey
            : PasetoUtil.secretKey;
      return encrypt(key, payload, {
        addExp: false,
      });
    } catch (error) {
      console.error("Failed to encode Paseto token:", error);
      return null;
    }
  }

// Update the decodePaseto return type to match your usage
public static async decodePaseto(
  token: string,
  role: Roles
): Promise<{
  payload: Payload & { 
    rootAdmin: string | boolean;
    [key: string]: any 
  };
  footer: Footer | string;
} | null> {
  try {
    const key = role === "admin" 
      ? PasetoUtil.adminSecretKey 
      : PasetoUtil.secretKey;
    const decrypted = await decrypt(key, token);
    
    // Ensure rootAdmin is properly typed in the payload
    return {
      payload: {
        ...decrypted.payload,
        rootAdmin: decrypted.payload.rootAdmin || false // Default to false if undefined
      },
      footer: decrypted.footer
    };
  } catch (error) {
    console.error("Failed to decode Paseto token:", error);
    return null;
  }
}
}

export { PasetoUtil };
