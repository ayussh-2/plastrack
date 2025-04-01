-- CreateTable
CREATE TABLE "VirtualTree" (
    "id" SERIAL NOT NULL,
    "firebaseId" TEXT NOT NULL,
    "count" INTEGER NOT NULL,
    "tokensSpent" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VirtualTree_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RealTreePlanting" (
    "id" SERIAL NOT NULL,
    "status" TEXT NOT NULL,
    "treesPlanted" INTEGER NOT NULL DEFAULT 0,
    "scheduledDate" TIMESTAMP(3) NOT NULL,
    "completedDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RealTreePlanting_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Badge" (
    "firebaseId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "awardedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Badge_pkey" PRIMARY KEY ("firebaseId","type")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" SERIAL NOT NULL,
    "firebaseId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Truck" (
    "id" SERIAL NOT NULL,
    "truckNumber" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Truck_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CleanupTask" (
    "id" SERIAL NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "reportCount" INTEGER NOT NULL,
    "avgSeverity" DOUBLE PRECISION NOT NULL,
    "status" TEXT NOT NULL,
    "reportIds" INTEGER[],
    "truckId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CleanupTask_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RecyclingMaterial" (
    "id" SERIAL NOT NULL,
    "cleanupTaskId" INTEGER NOT NULL,
    "plasticWeight" DOUBLE PRECISION NOT NULL,
    "paperWeight" DOUBLE PRECISION NOT NULL,
    "glassWeight" DOUBLE PRECISION NOT NULL,
    "metalWeight" DOUBLE PRECISION NOT NULL,
    "organicWeight" DOUBLE PRECISION NOT NULL,
    "otherWeight" DOUBLE PRECISION NOT NULL,
    "destinationType" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RecyclingMaterial_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Truck_truckNumber_key" ON "Truck"("truckNumber");

-- CreateIndex
CREATE UNIQUE INDEX "RecyclingMaterial_cleanupTaskId_key" ON "RecyclingMaterial"("cleanupTaskId");

-- AddForeignKey
ALTER TABLE "CleanupTask" ADD CONSTRAINT "CleanupTask_truckId_fkey" FOREIGN KEY ("truckId") REFERENCES "Truck"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RecyclingMaterial" ADD CONSTRAINT "RecyclingMaterial_cleanupTaskId_fkey" FOREIGN KEY ("cleanupTaskId") REFERENCES "CleanupTask"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
