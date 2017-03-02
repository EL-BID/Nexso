CREATE TABLE [dbo].[dnn_ModuleDefinitions] (
    [ModuleDefID]          INT            IDENTITY (1, 1) NOT NULL,
    [FriendlyName]         NVARCHAR (128) NOT NULL,
    [DesktopModuleID]      INT            NOT NULL,
    [DefaultCacheTime]     INT            CONSTRAINT [DF_dnn_ModuleDefinitions_DefaultCacheTime] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    [DefinitionName]       NVARCHAR (128) NOT NULL,
    CONSTRAINT [PK_dnn_ModuleDefinitions] PRIMARY KEY CLUSTERED ([ModuleDefID] ASC),
    CONSTRAINT [FK_dnn_ModuleDefinitions_dnn_DesktopModules] FOREIGN KEY ([DesktopModuleID]) REFERENCES [dbo].[dnn_DesktopModules] ([DesktopModuleID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_ModuleDefinitions]
    ON [dbo].[dnn_ModuleDefinitions]([DefinitionName] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ModuleDefinitions_1]
    ON [dbo].[dnn_ModuleDefinitions]([DesktopModuleID] ASC);

