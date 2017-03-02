CREATE TABLE [dbo].[dnn_Authentication] (
    [AuthenticationID]     INT            IDENTITY (1, 1) NOT NULL,
    [PackageID]            INT            CONSTRAINT [DF__dnn_Authe__Packa__43F60EC8] DEFAULT ((-1)) NOT NULL,
    [AuthenticationType]   NVARCHAR (100) NOT NULL,
    [IsEnabled]            BIT            CONSTRAINT [DF_dnn_Authentication_IsEnabled] DEFAULT ((0)) NOT NULL,
    [SettingsControlSrc]   NVARCHAR (250) NOT NULL,
    [LoginControlSrc]      NVARCHAR (250) NOT NULL,
    [LogoffControlSrc]     NVARCHAR (250) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_Authentication] PRIMARY KEY CLUSTERED ([AuthenticationID] ASC),
    CONSTRAINT [FK_dnn_Authentication_dnn_Packages] FOREIGN KEY ([PackageID]) REFERENCES [dbo].[dnn_Packages] ([PackageID]) ON DELETE CASCADE ON UPDATE CASCADE
);

