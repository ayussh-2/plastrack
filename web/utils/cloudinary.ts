export const uploadToCloudinary = async (file: File): Promise<string> => {
  const config = useRuntimeConfig();
  const cloudName = config.public.cloudinaryCloudName;
  const uploadPreset = config.public.cloudinaryUploadPreset;

  const formData = new FormData();
  formData.append("file", file);
  formData.append("upload_preset", uploadPreset);

  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`,
    {
      method: "POST",
      body: formData,
    }
  );

  if (!response.ok) {
    throw new Error("Failed to upload image to Cloudinary");
  }

  const data = await response.json();
  return data.secure_url;
};
