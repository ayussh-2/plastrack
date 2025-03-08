-- CreateTable
CREATE TABLE "TrashReport" (
    "id" SERIAL NOT NULL,
    "latitude" DECIMAL(10,8) NOT NULL,
    "longitude" DECIMAL(11,8) NOT NULL,
    "trashType" TEXT,
    "severity" INTEGER NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT,

    CONSTRAINT "TrashReport_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "TrashReport" ADD CONSTRAINT "TrashReport_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
