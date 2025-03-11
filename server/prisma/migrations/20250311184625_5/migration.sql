-- CreateTable
CREATE TABLE "TrashFeedback" (
    "id" SERIAL NOT NULL,
    "reportId" INTEGER NOT NULL,
    "feedback" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TrashFeedback_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "TrashFeedback" ADD CONSTRAINT "TrashFeedback_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "TrashReport"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
