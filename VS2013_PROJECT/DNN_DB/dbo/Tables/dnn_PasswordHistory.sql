CREATE TABLE [dbo].[dnn_PasswordHistory] (
    [PasswordHistoryID]    INT            IDENTITY (1, 1) NOT NULL,
    [UserID]               INT            NOT NULL,
    [Password]             NVARCHAR (128) NOT NULL,
    [PasswordSalt]         NVARCHAR (128) NOT NULL,
    [CreatedByUserID]      INT            NULL,
    [CreatedOnDate]        DATETIME       NULL,
    [LastModifiedByUserID] INT            NULL,
    [LastModifiedOnDate]   DATETIME       NULL,
    CONSTRAINT [PK_dnn_PasswordHistory] PRIMARY KEY CLUSTERED ([PasswordHistoryID] ASC),
    CONSTRAINT [FK_dnn_PasswordHistory_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

