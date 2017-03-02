CREATE TABLE [dbo].[dnn_SiteLog] (
    [SiteLogId]       INT            IDENTITY (1, 1) NOT NULL,
    [DateTime]        SMALLDATETIME  NOT NULL,
    [PortalId]        INT            NOT NULL,
    [UserId]          INT            NULL,
    [Referrer]        NVARCHAR (255) NULL,
    [Url]             NVARCHAR (255) NULL,
    [UserAgent]       NVARCHAR (255) NULL,
    [UserHostAddress] NVARCHAR (255) NULL,
    [UserHostName]    NVARCHAR (255) NULL,
    [TabId]           INT            NULL,
    [AffiliateId]     INT            NULL,
    CONSTRAINT [PK_dnn_SiteLog] PRIMARY KEY CLUSTERED ([SiteLogId] ASC),
    CONSTRAINT [FK_dnn_SiteLog_dnn_Portals] FOREIGN KEY ([PortalId]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_SiteLog]
    ON [dbo].[dnn_SiteLog]([PortalId] ASC);

