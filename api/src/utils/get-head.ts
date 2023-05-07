export const getHeadObject = async (
  s3: AWS.S3,
  bucket: string,
  key: string
) => {
  const params = {
    Bucket: bucket,
    Key: key,
  };
  return await s3.headObject(params).promise();
};
