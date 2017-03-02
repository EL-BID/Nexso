CREATE TABLE [dbo].[dnn_EasyDNNNewsPortalSharing] (
    [PortalIDFrom] INT NOT NULL,
    [PortalIDTo]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsPortalSharing] PRIMARY KEY CLUSTERED ([PortalIDFrom] ASC, [PortalIDTo] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsPortalSharing_Portals1] FOREIGN KEY ([PortalIDFrom]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

