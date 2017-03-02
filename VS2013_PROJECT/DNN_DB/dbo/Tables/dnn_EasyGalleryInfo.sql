CREATE TABLE [dbo].[dnn_EasyGalleryInfo] (
    [EntryID] INT            IDENTITY (1, 1) NOT NULL,
    [Info1]   NVARCHAR (300) NOT NULL,
    [Info2]   NVARCHAR (300) NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryInfoPrimary] PRIMARY KEY CLUSTERED ([EntryID] ASC)
);

