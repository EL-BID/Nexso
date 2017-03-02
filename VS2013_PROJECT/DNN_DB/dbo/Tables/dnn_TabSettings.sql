CREATE TABLE [dbo].[dnn_TabSettings] (
    [TabID]                INT             NOT NULL,
    [SettingName]          NVARCHAR (50)   NOT NULL,
    [SettingValue]         NVARCHAR (2000) NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    CONSTRAINT [PK_dnn_TabSettings] PRIMARY KEY NONCLUSTERED ([TabID] ASC, [SettingName] ASC),
    CONSTRAINT [FK_dnn_TabSettings_dnn_Tabs] FOREIGN KEY ([TabID]) REFERENCES [dbo].[dnn_Tabs] ([TabID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_dnn_TabSettings_TabID_SettingName]
    ON [dbo].[dnn_TabSettings]([TabID] ASC, [SettingName] ASC);

