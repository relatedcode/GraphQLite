import axios from "axios";
import { getIdToken } from "../auth";
import { SERVER_URL } from "../utils";

export async function uploadFile(
  bucketName: string,
  filePath: string,
  file: File
): Promise<string> {
  const body = new FormData();
  body.append("key", filePath);
  body.append("file", file);

  const res = await axios.post(
    `${SERVER_URL}/storage/b/${bucketName}/upload`,
    body,
    {
      headers: {
        Authorization: `Bearer ${await getIdToken()}`,
        "Content-Type": "multipart/form-data",
      },
    }
  );

  return res.data.url;
}

export function getFileURL(path: string) {
  return `${SERVER_URL}${path}`;
}
