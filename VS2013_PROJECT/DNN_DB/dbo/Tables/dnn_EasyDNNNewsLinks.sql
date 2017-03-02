CREATE TABLE [dbo].[dnn_EasyDNNNewsLinks] (
    [LinkID]       INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]     INT            NOT NULL,
    [UserID]       INT            NULL,
    [Type]         TINYINT        NOT NULL,
    [Title]        NVARCHAR (200) NULL,
    [Description]  NVARCHAR (500) NULL,
    [Target]       TINYINT        NOT NULL,
    [URL]          NVARCHAR (500) NULL,
    [Protocol]     NVARCHAR (10)  NULL,
    [ArticleID]    INT            NULL,
    [TabID]        INT            NULL,
    [AllLanguages] BIT            NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsArticleLink] PRIMARY KEY CLUSTERED ([LinkID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsLinks_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsLinks_Tabs] FOREIGN KEY ([TabID]) REFERENCES [dbo].[dnn_Tabs] ([TabID]),
    CONSTRAINT [FK_dnn_EasyDNNNewsLinks_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);

