CREATE TABLE [dbo].[dnn_DesktopModules] (
    [DesktopModuleID]         INT             IDENTITY (1, 1) NOT NULL,
    [FriendlyName]            NVARCHAR (128)  NOT NULL,
    [Description]             NVARCHAR (2000) NULL,
    [Version]                 NVARCHAR (8)    NULL,
    [IsPremium]               BIT             NOT NULL,
    [IsAdmin]                 BIT             NOT NULL,
    [BusinessControllerClass] NVARCHAR (200)  NULL,
    [FolderName]              NVARCHAR (128)  NOT NULL,
    [ModuleName]              NVARCHAR (128)  NOT NULL,
    [SupportedFeatures]       INT             CONSTRAINT [DF_dnn_DesktopModules_SupportedFeatures] DEFAULT ((0)) NOT NULL,
    [CompatibleVersions]      NVARCHAR (500)  NULL,
    [Dependencies]            NVARCHAR (400)  NULL,
    [Permissions]             NVARCHAR (400)  NULL,
    [PackageID]               INT             CONSTRAINT [DF_dnn_DesktopModules_PackageID] DEFAULT ((-1)) NOT NULL,
    [CreatedByUserID]         INT             NULL,
    [CreatedOnDate]           DATETIME        NULL,
    [LastModifiedByUserID]    INT             NULL,
    [LastModifiedOnDate]      DATETIME        NULL,
    [ContentItemId]           INT             CONSTRAINT [DF_dnn_DesktopModules_ContentItemId] DEFAULT ((-1)) NOT NULL,
    [Shareable]               INT             CONSTRAINT [DF_dnn_DesktopModules_Shareable] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_DesktopModules] PRIMARY KEY CLUSTERED ([DesktopModuleID] ASC),
    CONSTRAINT [FK_dnn_DesktopModules_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [IX_dnn_DesktopModules_ModuleName] UNIQUE NONCLUSTERED ([ModuleName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_DesktopModules_FriendlyName]
    ON [dbo].[dnn_DesktopModules]([FriendlyName] ASC);

