CREATE TABLE [dbo].[dnn_ExtensionUrlProviderSetting] (
    [ExtensionUrlProviderID] INT             NOT NULL,
    [PortalID]               INT             NOT NULL,
    [SettingName]            NVARCHAR (100)  NOT NULL,
    [SettingValue]           NVARCHAR (2000) NOT NULL,
    CONSTRAINT [PK_dnn_ExtensionUrlProviderSetting] PRIMARY KEY CLUSTERED ([ExtensionUrlProviderID] ASC, [PortalID] ASC, [SettingName] ASC)
);

