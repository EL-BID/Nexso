CREATE TABLE [dbo].[dnn_FolderMappingsSettings] (
    [FolderMappingID]      INT             NOT NULL,
    [SettingName]          NVARCHAR (50)   NOT NULL,
    [SettingValue]         NVARCHAR (2000) NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    CONSTRAINT [PK_dnn_FolderMappingsSettings] PRIMARY KEY CLUSTERED ([FolderMappingID] ASC, [SettingName] ASC),
    CONSTRAINT [FK_dnn_FolderMappingsSettings_dnn_FolderMappings] FOREIGN KEY ([FolderMappingID]) REFERENCES [dbo].[dnn_FolderMappings] ([FolderMappingID]) ON DELETE CASCADE
);

