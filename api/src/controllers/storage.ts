import AWS from "aws-sdk";
import express from "express";
import { getHeadObject } from "utils/get-head";
import randomId from "utils/random-id";

export const s3 = new AWS.S3({
  accessKeyId: process.env.MINIO_ROOT_USER || "minio",
  secretAccessKey: process.env.MINIO_ROOT_PASSWORD || "minio123",
  endpoint: "http://minio:9000",
  s3ForcePathStyle: true,
  signatureVersion: "v4",
});

export const createBucket = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name } = req.body;

    await s3.createBucket({ Bucket: name }).promise();

    res.locals.data = {
      bucketName: name,
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const deleteBucket = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name } = req.params;

    await s3.deleteBucket({ Bucket: name }).promise();

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const listBuckets = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const buckets = await s3.listBuckets().promise();

    res.locals.data = {
      data: buckets.Buckets,
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const uploadObject = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name } = req.params;
    const { key } = req.body;

    if (!req.files) throw new Error("No files were uploaded.");
    const file = req.files.file as any;

    const fileToken = randomId(100);

    await s3
      .upload({
        Bucket: name,
        Key: key,
        Body: file.data,
        ContentType: file.mimetype,
        Metadata: {
          token: fileToken,
        },
      })
      .promise();

    res.locals.data = {
      url: `/storage/b/${name}/o/${encodeURIComponent(key)}?token=${fileToken}`,
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const getObject = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name, key } = req.params;

    if (!req.query.token)
      throw new Error("You are not authorized to download this file.");

    const headObject = await getHeadObject(s3, name, key);

    if (headObject.Metadata?.token !== req.query.token)
      throw new Error("You are not authorized to download this file.");

    const params = {
      Bucket: name,
      Key: key,
    };
    // Split request with stream to be able to abort request on timeout errors
    const request = s3.getObject(params);
    const stream = request.createReadStream().on("error", (err) => {
      console.error(err);
      request.abort();
    });

    // Add the content type to the response (it's not propagated from the S3 SDK)
    res.set("Content-Type", headObject.ContentType);
    res.set("Content-Length", headObject.ContentLength?.toString());
    res.set("Last-Modified", headObject.LastModified?.toUTCString());
    res.set("Content-Disposition", `inline;`);
    res.set("Cache-Control", "private,max-age=31557600");
    res.set("ETag", headObject.ETag);

    // Pipe the s3 object to the response
    stream.pipe(res);
  } catch (err) {
    return next(err);
  }
};

export const deleteObject = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name, key } = req.params;

    await s3
      .deleteObject({
        Bucket: name,
        Key: key,
      })
      .promise();

    res.locals.data = {
      success: true,
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};

export const listObjects = async (
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  try {
    const { name } = req.params;

    const objects = await s3.listObjects({ Bucket: name }).promise();

    res.locals.data = {
      data: objects.Contents
        ? await Promise.all(
            objects.Contents.map(async (o) => ({
              ...o,
              Head: await getHeadObject(s3, name, o.Key as string),
            }))
          )
        : [],
    };
    return next("router");
  } catch (err) {
    return next(err);
  }
};
