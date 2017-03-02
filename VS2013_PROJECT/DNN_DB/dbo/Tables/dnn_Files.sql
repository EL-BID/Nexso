CREATE TABLE [dbo].[dnn_Files] (
    [FileId]               INT              IDENTITY (1, 1) NOT NULL,
    [PortalId]             INT              NULL,
    [FileName]             NVARCHAR (246)   NOT NULL,
    [Extension]            NVARCHAR (100)   NOT NULL,
    [Size]                 INT              NOT NULL,
    [Width]                INT              NULL,
    [Height]               INT              NULL,
    [ContentType]          NVARCHAR (200)   NOT NULL,
    [FolderID]             INT              NOT NULL,
    [Content]              IMAGE            NULL,
    [CreatedByUserID]      INT              NULL,
    [CreatedOnDate]        DATETIME         NULL,
    [LastModifiedByUserID] INT              NULL,
    [LastModifiedOnDate]   DATETIME         NULL,
    [UniqueId]             UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Files_UniqueId] DEFAULT (newid()) NOT NULL,
    [VersionGuid]          UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Files_VersionGuid] DEFAULT (newid()) NOT NULL,
    [SHA1Hash]             VARCHAR (40)     NULL,
    [LastModificationTime] DATETIME         CONSTRAINT [DF__dnn_Files__LastM__629A9179] DEFAULT (getdate()) NOT NULL,
    [Folder]               AS               ([dbo].[dnn_GetFileFolderFunc]([FolderID])),
    [Title]                NVARCHAR (256)   NULL,
    [StartDate]            DATE             DEFAULT (getdate()) NOT NULL,
    [EnablePublishPeriod]  BIT              DEFAULT ((0)) NOT NULL,
    [EndDate]              DATE             NULL,
    [PublishedVersion]     INT              DEFAULT ((1)) NOT NULL,
    [ContentItemID]        INT              NULL,
    CONSTRAINT [PK_dnn_File] PRIMARY KEY CLUSTERED ([FileId] ASC),
    CONSTRAINT [FK_dnn_Files_dnn_ContentItems] FOREIGN KEY ([ContentItemID]) REFERENCES [dbo].[dnn_ContentItems] ([ContentItemID]),
    CONSTRAINT [FK_dnn_Files_dnn_Folders] FOREIGN KEY ([FolderID]) REFERENCES [dbo].[dnn_Folders] ([FolderID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Files_dnn_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[dnn_Portals] ([PortalID]),
    CONSTRAINT [IX_dnn_Files_UniqueId] UNIQUE NONCLUSTERED ([UniqueId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Files_ContentID]
    ON [dbo].[dnn_Files]([ContentItemID] ASC)
    INCLUDE([FileId], [FolderID], [FileName], [PublishedVersion]) WHERE ([ContentItemId] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Files_FileID]
    ON [dbo].[dnn_Files]([FileId] ASC)
    INCLUDE([PortalId], [FolderID], [FileName], [PublishedVersion]) WHERE ([ContentItemId] IS NOT NULL);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Files_PortalID]
    ON [dbo].[dnn_Files]([PortalId] ASC, [FolderID] ASC, [FileName] ASC)
    INCLUDE([FileId], [PublishedVersion]);

