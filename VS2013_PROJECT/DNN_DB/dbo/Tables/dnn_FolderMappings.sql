CREATE TABLE [dbo].[dnn_FolderMappings] (
    [FolderMappingID]      INT           IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT           NULL,
    [MappingName]          NVARCHAR (50) NOT NULL,
    [FolderProviderType]   NVARCHAR (50) NOT NULL,
    [Priority]             INT           NULL,
    [CreatedByUserID]      INT           NULL,
    [CreatedOnDate]        DATETIME      NULL,
    [LastModifiedByUserID] INT           NULL,
    [LastModifiedOnDate]   DATETIME      NULL,
    CONSTRAINT [PK_dnn_FolderMappings] PRIMARY KEY CLUSTERED ([FolderMappingID] ASC),
    CONSTRAINT [FK_dnn_FolderMappings_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_FolderMappings] UNIQUE NONCLUSTERED ([PortalID] ASC, [MappingName] ASC)
);

