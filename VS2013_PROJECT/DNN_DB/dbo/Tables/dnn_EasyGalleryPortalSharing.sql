CREATE TABLE [dbo].[dnn_EasyGalleryPortalSharing] (
    [PortalIDFrom] INT NOT NULL,
    [PortalIDTo]   INT NOT NULL,
    CONSTRAINT [PK_dnn_EasyGalleryPortalSharing] PRIMARY KEY CLUSTERED ([PortalIDFrom] ASC, [PortalIDTo] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryPortalSharing_dnn_Portals1] FOREIGN KEY ([PortalIDFrom]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

