CREATE TABLE [dbo].[dnn_ContentItems_MetaData] (
    [ContentItemMetaDataID] INT            IDENTITY (1, 1) NOT NULL,
    [ContentItemID]         INT            NOT NULL,
    [MetaDataID]            INT            NOT NULL,
    [MetaDataValue]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dnn_Content_MetaData] PRIMARY KEY CLUSTERED ([ContentItemMetaDataID] ASC),
    CONSTRAINT [FK_dnn_ContentItems_MetaData_dnn_ContentItems] FOREIGN KEY ([ContentItemID]) REFERENCES [dbo].[dnn_ContentItems] ([ContentItemID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_dnn_ContentItems_MetaDatadnn_MetaData] FOREIGN KEY ([MetaDataID]) REFERENCES [dbo].[dnn_MetaData] ([MetaDataID]) ON DELETE CASCADE ON UPDATE CASCADE
);

