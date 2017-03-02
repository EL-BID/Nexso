CREATE TABLE [dbo].[dnn_ModuleSettings] (
    [ModuleID]             INT            NOT NULL,
    [SettingName]          NVARCHAR (50)  NOT NULL,
    [SettingValue]         NVARCHAR (MAX) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_ModuleSettings] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [SettingName] ASC),
    CONSTRAINT [FK_dnn_ModuleSettings_dnn_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE
);

