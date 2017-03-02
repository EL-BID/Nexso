CREATE TABLE [dbo].[dnn_Folders] (
    [FolderID]             INT              IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT              NULL,
    [FolderPath]           NVARCHAR (300)   NOT NULL,
    [StorageLocation]      INT              CONSTRAINT [DF_dnn_Folders_StorageLocation] DEFAULT ((0)) NOT NULL,
    [IsProtected]          BIT              CONSTRAINT [DF_dnn_Folders_IsProtected] DEFAULT ((0)) NOT NULL,
    [IsCached]             BIT              CONSTRAINT [DF_dnn_Folders_IsCached] DEFAULT ((0)) NOT NULL,
    [LastUpdated]          DATETIME         NULL,
    [CreatedByUserID]      INT              NULL,
    [CreatedOnDate]        DATETIME         NULL,
    [LastModifiedByUserID] INT              NULL,
    [LastModifiedOnDate]   DATETIME         NULL,
    [UniqueId]             UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Folders_UniqueId] DEFAULT (newid()) NOT NULL,
    [VersionGuid]          UNIQUEIDENTIFIER CONSTRAINT [DF_dnn_Folders_VersionGuid] DEFAULT (newid()) NOT NULL,
    [FolderMappingID]      INT              NOT NULL,
    [ParentID]             INT              NULL,
    [IsVersioned]          BIT              DEFAULT ((0)) NOT NULL,
    [WorkflowID]           INT              NULL,
    [MappedPath]           NVARCHAR (300)   NULL,
    CONSTRAINT [PK_dnn_Folders] PRIMARY KEY CLUSTERED ([FolderID] ASC),
    CONSTRAINT [FK_dnn_Folders_dnn_ContentWorkflows] FOREIGN KEY ([WorkflowID]) REFERENCES [dbo].[dnn_ContentWorkflows] ([WorkflowID]) ON DELETE SET NULL,
    CONSTRAINT [FK_dnn_Folders_dnn_FolderMappings] FOREIGN KEY ([FolderMappingID]) REFERENCES [dbo].[dnn_FolderMappings] ([FolderMappingID]),
    CONSTRAINT [FK_dnn_Folders_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_FolderPath] UNIQUE NONCLUSTERED ([PortalID] ASC, [FolderPath] ASC),
    CONSTRAINT [IX_dnn_Folders_UniqueId] UNIQUE NONCLUSTERED ([UniqueId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Folders_FolderID]
    ON [dbo].[dnn_Folders]([FolderID] ASC)
    INCLUDE([PortalID], [FolderPath], [StorageLocation], [IsCached], [FolderMappingID]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Folders_ParentID]
    ON [dbo].[dnn_Folders]([PortalID] ASC, [ParentID] ASC, [FolderPath] ASC)
    INCLUDE([FolderID]);

