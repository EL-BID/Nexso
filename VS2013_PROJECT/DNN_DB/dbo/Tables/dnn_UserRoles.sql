CREATE TABLE [dbo].[dnn_UserRoles] (
    [UserRoleID]           INT      IDENTITY (1, 1) NOT NULL,
    [UserID]               INT      NOT NULL,
    [RoleID]               INT      NOT NULL,
    [ExpiryDate]           DATETIME NULL,
    [IsTrialUsed]          BIT      NULL,
    [EffectiveDate]        DATETIME NULL,
    [CreatedByUserID]      INT      NULL,
    [CreatedOnDate]        DATETIME NULL,
    [LastModifiedByUserID] INT      NULL,
    [LastModifiedOnDate]   DATETIME NULL,
    [Status]               INT      CONSTRAINT [DF_dnn_UserRoles_Status] DEFAULT ((1)) NOT NULL,
    [IsOwner]              BIT      CONSTRAINT [DF_dnn_UserRoles_IsOwner] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_UserRoles] PRIMARY KEY CLUSTERED ([UserRoleID] ASC),
    CONSTRAINT [CK_dnn_UserRoles_RoleId] CHECK ([RoleId]>=(0)),
    CONSTRAINT [FK_dnn_UserRoles_dnn_Roles] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[dnn_Roles] ([RoleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_UserRoles_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_UserRoles_RoleUser]
    ON [dbo].[dnn_UserRoles]([RoleID] ASC, [UserID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_UserRoles_UserRole]
    ON [dbo].[dnn_UserRoles]([UserID] ASC, [RoleID] ASC);

