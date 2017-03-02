CREATE TABLE [dbo].[dnn_EasyDNNNewsDocuments] (
    [DocEntryID]        INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]          INT             NULL,
    [UserID]            INT             NULL,
    [DateUploaded]      DATETIME        NULL,
    [FilePath]          NVARCHAR (1000) NOT NULL,
    [Title]             NVARCHAR (250)  NULL,
    [Description]       NVARCHAR (1500) NULL,
    [NumberOfDownloads] INT             CONSTRAINT [DF_dnn_EasyDNNNewsDocuments_NumberOfDownloads] DEFAULT ((0)) NOT NULL,
    [FileSize]          BIGINT          CONSTRAINT [DF_dnn_EasyDNNNewsDocuments_FileSize] DEFAULT ((0)) NOT NULL,
    [FileExtension]     NVARCHAR (15)   CONSTRAINT [DF_dnn_EasyDNNNewsDocuments_FileExtension] DEFAULT ('') NOT NULL,
    [FileName]          NVARCHAR (255)  CONSTRAINT [DF_dnn_EasyDNNNewsDocuments_FileName] DEFAULT ('') NOT NULL,
    [AllLanguages]      BIT             CONSTRAINT [DF_dnn_EasyDNNNewsDocuments_AllLanguages] DEFAULT ((1)) NOT NULL,
    [Visible]           BIT             CONSTRAINT [DF_dnn_EasyDNNNewsDocuments_Visible] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsDocuments] PRIMARY KEY CLUSTERED ([DocEntryID] ASC)
);

