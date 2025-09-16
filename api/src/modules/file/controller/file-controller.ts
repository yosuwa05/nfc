import { deliverFile } from "@/lib/file";
// import { getAsBlob } from "@/lib/file-s3";
import Elysia, { t } from "elysia";
// @ts-ignore
import mime from "mime-types";

export const fileController = new Elysia({
  prefix: "/file",
  detail: {
    tags: ["File Controller"],
  },
})
.get(
  "/",
  async ({ query, set }) => {
    try {
      const { key } = query;

      console.log("key", key);

      if (!key) {
        set.status = 404;
        return {
          message: "File not found",
          status: false,
        };
      }
      const { data, ok } = await deliverFile(key);
      // const { data, ok } = await getAsBlob(key);

      if (!ok) {
        set.status = 404;
        return {
          message: "File not found",
          status: false,
        };
      }

      const mimeType = mime.lookup(key) || "application/octet-stream";
      const isImage = mimeType.startsWith("image/");

      set.headers = {
        "content-type": mimeType,
        ...(isImage
          ? {}
          : {
              "content-disposition": `inline; filename=${key}`,
            }),
        "cache-control": "public, max-age=31536000",
        "access-control-allow-origin": "*",
      };

      // @ts-ignore
      return Buffer.from(data);
    } catch (error) {
      console.error(error);
      return {
        error,
        status: false,
      };
    }
  },
  {
    query: t.Object({
      key: t.String(),
    }),
    detail: {
      summary: "Get a file from s3 bucket",
    },
  }
)
.get(
  "/view",
  async ({ set, query }) => {
    try {
      let { key } = query;

      const file = Bun.file(key);

      let buffer = await file.arrayBuffer();

      const blob = new Blob([buffer], {
        type: "image/png",
      });

      set.headers["Content-Type"] = "image/png";

      return blob;
    } catch (error: any) {
      set.status = 400;

      console.error(error);

      return {
        message: error.message,
        ok: false,
      };
    }
  },
  {
    query: t.Object({
      key: t.String(),
    }),
    detail: {
      summary: "View a file",
      description: "View a file",
    },
  }
)
