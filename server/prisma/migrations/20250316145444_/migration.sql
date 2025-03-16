/*
  Warnings:

  - You are about to drop the column `userId` on the `TrashReport` table. All the data in the column will be lost.

*/
-- DropForeignKey
ALTER TABLE "TrashReport" DROP CONSTRAINT "TrashReport_userId_fkey";

-- AlterTable
ALTER TABLE "TrashReport" DROP COLUMN "userId",
ADD COLUMN     "firebaseId" TEXT;

-- AddForeignKey
ALTER TABLE "TrashReport" ADD CONSTRAINT "TrashReport_firebaseId_fkey" FOREIGN KEY ("firebaseId") REFERENCES "User"("firebaseId") ON DELETE SET NULL ON UPDATE CASCADE;
