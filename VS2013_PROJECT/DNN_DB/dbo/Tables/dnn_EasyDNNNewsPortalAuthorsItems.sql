CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalAuthorsItems] (
    [PortalID] INT NOT NULL,
    [UserID]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalAuthorsItems] PRIMARY KEY CLUSTERED ([PortalID] ASC, [UserID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalAuthorsItems_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalAuthorsItems_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE
);

