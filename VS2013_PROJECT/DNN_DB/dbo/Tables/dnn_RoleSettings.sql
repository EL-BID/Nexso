CREATE TABLE [dbo].[dnn_RoleSettings] (
    [RoleSettingID]        INT             IDENTITY (1, 1) NOT NULL,
    [RoleID]               INT             NOT NULL,
    [SettingName]          NVARCHAR (50)   NOT NULL,
    [SettingValue]         NVARCHAR (2000) NOT NULL,
    [CreatedByUserID]      INT             NOT NULL,
    [CreatedOnDate]        DATETIME        CONSTRAINT [DF_dnn_RoleSettings_CreatedOnDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT             NOT NULL,
    [LastModifiedOnDate]   DATETIME        CONSTRAINT [DF_dnn_RoleSettings_LastModifiedOnDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dnn_RoleSettings] PRIMARY KEY CLUSTERED ([RoleSettingID] ASC)
);

