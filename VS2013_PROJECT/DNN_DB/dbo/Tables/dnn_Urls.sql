CREATE TABLE [dbo].[dnn_Urls] (
    [UrlID]    INT            IDENTITY (1, 1) NOT NULL,
    [PortalID] INT            NULL,
    [Url]      NVARCHAR (255) NOT NULL,
    CONSTRAINT [PK_dnn_Urls] PRIMARY KEY CLUSTERED ([UrlID] ASC),
    CONSTRAINT [FK_dnn_Urls_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_Urls] UNIQUE NONCLUSTERED ([Url] ASC, [PortalID] ASC)
);

