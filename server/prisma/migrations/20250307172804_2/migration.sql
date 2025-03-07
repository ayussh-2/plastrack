/*
  Warnings:

  - A unique constraint covering the columns `[firebase_id]` on the table `User` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `firebase_id` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "User" ADD COLUMN     "firebase_id" TEXT NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "User_firebase_id_key" ON "User"("firebase_id");
