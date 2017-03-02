CREATE TABLE [dbo].[dnn_UserAuthentication] (
    [UserAuthenticationID] INT             IDENTITY (1, 1) NOT NULL,
    [UserID]               INT             NOT NULL,
    [AuthenticationType]   NVARCHAR (100)  NOT NULL,
    [AuthenticationToken]  NVARCHAR (1000) NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    CONSTRAINT [PK_dnn_UserAuthentication] PRIMARY KEY CLUSTERED ([UserAuthenticationID] ASC),
    CONSTRAINT [FK_dnn_UserAuthentication_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_UserAuthentication]
    ON [dbo].[dnn_UserAuthentication]([UserID] ASC, [AuthenticationType] ASC);

