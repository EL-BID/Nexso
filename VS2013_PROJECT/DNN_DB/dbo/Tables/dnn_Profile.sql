CREATE TABLE [dbo].[dnn_Profile] (
    [ProfileId]   INT      IDENTITY (1, 1) NOT NULL,
    [UserId]      INT      NOT NULL,
    [PortalId]    INT      NOT NULL,
    [ProfileData] NTEXT    NOT NULL,
    [CreatedDate] DATETIME NOT NULL,
    CONSTRAINT [PK_dnn_Profile] PRIMARY KEY CLUSTERED ([ProfileId] ASC),
    CONSTRAINT [FK_dnn_Profile_dnn_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Profile_dnn_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_Profile]
    ON [dbo].[dnn_Profile]([UserId] ASC, [PortalId] ASC);

