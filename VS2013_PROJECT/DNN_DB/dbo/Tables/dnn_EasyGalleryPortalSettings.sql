CREATE TABLE [dbo].[dnn_EasyGalleryPortalSettings] (
    [PortalID]     INT            NOT NULL,
    [GoogleAPIKey] NVARCHAR (300) NULL,
    CONSTRAINT [PK_dnn_EasyGalleryPortalSettings] PRIMARY KEY CLUSTERED ([PortalID] ASC),
    CONSTRAINT [FK_dnn_EasyGalleryPortalSettings_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

