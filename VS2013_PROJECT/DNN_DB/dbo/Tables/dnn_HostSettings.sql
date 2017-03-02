CREATE TABLE [dbo].[dnn_HostSettings] (
    [SettingName]          NVARCHAR (50)  NOT NULL,
    [SettingValue]         NVARCHAR (256) NOT NULL,
    [SettingIsSecure]      BIT            CONSTRAINT [DF_dnn_HostSettings_Secure] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_HostSettings] PRIMARY KEY CLUSTERED ([SettingName] ASC)
);

