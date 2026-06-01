/*
  Warnings:

  - You are about to drop the `Test` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "PresentationStatus" AS ENUM ('DRAFT', 'GENERATING', 'COMPLETED', 'FAILED');

-- DropTable
DROP TABLE "Test";

-- CreateTable
CREATE TABLE "Todo" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Todo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "presentation" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "prompt" TEXT NOT NULL,
    "slideCount" INTEGER NOT NULL,
    "style" TEXT NOT NULL,
    "tone" TEXT NOT NULL,
    "layout" TEXT NOT NULL,
    "status" "PresentationStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "presentation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "slide" (
    "id" TEXT NOT NULL,
    "presentationId" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "notes" TEXT,
    "imageUrl" TEXT,
    "imagePrompt" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "slide_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "presentation_userId_idx" ON "presentation"("userId");

-- CreateIndex
CREATE INDEX "slide_presentationId_idx" ON "slide"("presentationId");

-- AddForeignKey
ALTER TABLE "presentation" ADD CONSTRAINT "presentation_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "slide" ADD CONSTRAINT "slide_presentationId_fkey" FOREIGN KEY ("presentationId") REFERENCES "presentation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
