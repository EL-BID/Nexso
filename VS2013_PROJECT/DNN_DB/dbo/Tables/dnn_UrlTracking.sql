CREATE TABLE [dbo].[dnn_UrlTracking] (
    [UrlTrackingID] INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]      INT            NULL,
    [Url]           NVARCHAR (255) NOT NULL,
    [UrlType]       CHAR (1)       NOT NULL,
    [Clicks]        INT            NOT NULL,
    [LastClick]     DATETIME       NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LogActivity]   BIT            NOT NULL,
    [TrackClicks]   BIT            CONSTRAINT [DF_dnn_UrlTracking_TrackClicks] DEFAULT ((1)) NOT NULL,
    [ModuleId]      INT            NULL,
    [NewWindow]     BIT            CONSTRAINT [DF_dnn_UrlTracking_NewWindow] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_UrlTracking] PRIMARY KEY CLUSTERED ([UrlTrackingID] ASC),
    CONSTRAINT [FK_dnn_UrlTracking_dnn_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_UrlTracking] UNIQUE NONCLUSTERED ([PortalID] ASC, [Url] ASC, [ModuleId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UrlTracking_ModuleId]
    ON [dbo].[dnn_UrlTracking]([ModuleId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_UrlTracking_Url_ModuleId]
    ON [dbo].[dnn_UrlTracking]([Url] ASC, [ModuleId] ASC)
    INCLUDE([TrackClicks], [NewWindow]);

