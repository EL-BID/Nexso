CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalGroupItems] (
    [PortalID] INT NOT NULL,
    [GroupID]  INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalGroupItems] PRIMARY KEY CLUSTERED ([PortalID] ASC, [GroupID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalGroupItems_EasyDNNNewsAuthorGroups] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[dnn_EasyDNNNewsAuthorGroups] ([GroupID]) ON DELETE CASCADE
);

