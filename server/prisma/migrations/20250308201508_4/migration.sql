/*
  Warnings:

  - Added the required column `image` to the `TrashReport` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "TrashReport" ADD COLUMN     "image" TEXT NOT NULL;
