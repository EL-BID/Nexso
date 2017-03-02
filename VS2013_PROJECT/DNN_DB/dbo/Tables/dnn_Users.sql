CREATE TABLE [dbo].[dnn_Users] (
    [UserID]                  INT              IDENTITY (1, 1) NOT NULL,
    [Username]                NVARCHAR (100)   NOT NULL,
    [FirstName]               NVARCHAR (50)    NOT NULL,
    [LastName]                NVARCHAR (50)    NOT NULL,
    [IsSuperUser]             BIT              CONSTRAINT [DF_dnn_Users_IsSuperUser] DEFAULT ((0)) NOT NULL,
    [AffiliateId]             INT              NULL,
    [Email]                   NVARCHAR (256)   NULL,
    [DisplayName]             NVARCHAR (128)   CONSTRAINT [DF_dnn_Users_DisplayName] DEFAULT ('') NOT NULL,
    [UpdatePassword]          BIT              CONSTRAINT [DF_dnn_Users_UpdatePassword] DEFAULT ((0)) NOT NULL,
    [LastIPAddress]           NVARCHAR (50)    NULL,
    [IsDeleted]               BIT              CONSTRAINT [DF_dnn_Users_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]         INT              NULL,
    [CreatedOnDate]           DATETIME         NULL,
    [LastModifiedByUserID]    INT              NULL,
    [LastModifiedOnDate]      DATETIME         NULL,
    [PasswordResetToken]      UNIQUEIDENTIFIER NULL,
    [PasswordResetExpiration] DATETIME         NULL,
    [LowerEmail]              AS               (lower([Email])) PERSISTED,
    CONSTRAINT [PK_dnn_Users] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [IX_dnn_Users] UNIQUE NONCLUSTERED ([Username] ASC)
);












GO
CREATE NONCLUSTERED INDEX [IX_dnn_Users_Email]
    ON [dbo].[dnn_Users]([Email] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Users_IsDeleted_DisplayName]
    ON [dbo].[dnn_Users]([IsDeleted] ASC, [DisplayName] ASC)
    INCLUDE([UserID], [IsSuperUser], [Email]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_Users_LastModifiedOnDate]
    ON [dbo].[dnn_Users]([LastModifiedOnDate] DESC)
    INCLUDE([UserID], [IsSuperUser]);





GO
CREATE NONCLUSTERED INDEX [IX_dnn_Users_LowerEmail]
    ON [dbo].[dnn_Users]([Email] ASC);

