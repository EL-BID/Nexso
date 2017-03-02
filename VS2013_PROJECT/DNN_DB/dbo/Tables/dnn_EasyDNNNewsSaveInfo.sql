CREATE TABLE [dbo].[dnn_EasyDNNNewsSaveInfo] (
    [ModuleID]   INT            NOT NULL,
    [PortalID]   INT            NOT NULL,
    [UserID]     INT            NULL,
    [PSHomeDP]   NVARCHAR (250) NULL,
    [PDPath]     NVARCHAR (250) NULL,
    [CategoryID] INT            NULL,
    [GalleryID]  INT            NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsSaveInfo] PRIMARY KEY CLUSTERED ([ModuleID] ASC, [PortalID] ASC)
);

