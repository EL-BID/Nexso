CREATE TABLE [dbo].[dnn_TabModuleSettings] (
    [TabModuleID]          INT            NOT NULL,
    [SettingName]          NVARCHAR (50)  NOT NULL,
    [SettingValue]         NVARCHAR (MAX) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_TabModuleSettings] PRIMARY KEY CLUSTERED ([TabModuleID] ASC, [SettingName] ASC),
    CONSTRAINT [FK_dnn_TabModuleSettings_dnn_TabModules] FOREIGN KEY ([TabModuleID]) REFERENCES [dbo].[dnn_TabModules] ([TabModuleID]) ON DELETE CASCADE
);

