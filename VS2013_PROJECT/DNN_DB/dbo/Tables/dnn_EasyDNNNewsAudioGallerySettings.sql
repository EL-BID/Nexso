CREATE TABLE [dbo].[dnn_EasyDNNNewsAudioGallerySettings] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [PortalID]        INT           NOT NULL,
    [ModuleID]        INT           NULL,
    [ArticleID]       INT           NULL,
    [ThumbWidth]      INT           CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_ThumbWidth] DEFAULT ((100)) NOT NULL,
    [ThumbHeight]     INT           CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_ThumbHeight] DEFAULT ((100)) NOT NULL,
    [ItemsPerPage]    INT           CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_ItemsPerPage] DEFAULT ((20)) NOT NULL,
    [NumOfColumns]    INT           CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_NumOfColumns] DEFAULT ((4)) NOT NULL,
    [PagerType]       NVARCHAR (50) CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_PagerType] DEFAULT (N'Numeric') NOT NULL,
    [GalleryTheme]    NVARCHAR (50) CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_GalleryTheme] DEFAULT (N'EDG_0_Shadow.css') NOT NULL,
    [ShowTitle]       BIT           CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_ShowTitle] DEFAULT ((0)) NOT NULL,
    [ShowDescription] BIT           CONSTRAINT [DF_dnn_EasyDNNNewsAudioGallerySettings_ShowDescription] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsAudioGallerySettings] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsAudioGallerySettings_EasyDNNNews] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNews] ([ArticleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsAudioGallerySettings_Modules] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[dnn_Modules] ([ModuleID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsAudioGallerySettings_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsAudioGallerySettings] UNIQUE NONCLUSTERED ([PortalID] ASC, [ModuleID] ASC, [ArticleID] ASC)
);

