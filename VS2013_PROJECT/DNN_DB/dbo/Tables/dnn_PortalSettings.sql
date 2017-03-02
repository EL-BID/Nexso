CREATE TABLE [dbo].[dnn_PortalSettings] (
    [PortalSettingID]      INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]             INT             NOT NULL,
    [SettingName]          NVARCHAR (50)   NOT NULL,
    [SettingValue]         NVARCHAR (2000) NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    [CultureCode]          NVARCHAR (10)   NULL,
    CONSTRAINT [PK_dnn_PortalSettings] PRIMARY KEY NONCLUSTERED ([PortalSettingID] ASC),
    CONSTRAINT [FK_dnn_PortalSettings_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);


GO
CREATE CLUSTERED INDEX [IX_dnn_PortalSettings]
    ON [dbo].[dnn_PortalSettings]([PortalID] ASC, [CultureCode] ASC, [SettingName] ASC);

