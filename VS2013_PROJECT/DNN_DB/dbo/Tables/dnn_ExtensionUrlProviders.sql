CREATE TABLE [dbo].[dnn_ExtensionUrlProviders] (
    [ExtensionUrlProviderID] INT             IDENTITY (1, 1) NOT NULL,
    [ProviderName]           NVARCHAR (150)  NOT NULL,
    [ProviderType]           NVARCHAR (1000) NOT NULL,
    [SettingsControlSrc]     NVARCHAR (1000) NULL,
    [IsActive]               BIT             NOT NULL,
    [RewriteAllUrls]         BIT             NOT NULL,
    [RedirectAllUrls]        BIT             NOT NULL,
    [ReplaceAllUrls]         BIT             NOT NULL,
    [DesktopModuleId]        INT             NULL,
    CONSTRAINT [PK_dnn_ExtensionUrlProviders] PRIMARY KEY CLUSTERED ([ExtensionUrlProviderID] ASC)
);

