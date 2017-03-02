CREATE TABLE [dbo].[dnn_EasyDNNNewsAuthorGroups] (
    [PortalID]          INT             NOT NULL,
    [GroupID]           INT             IDENTITY (1, 1) NOT NULL,
    [GroupName]         NVARCHAR (250)  NOT NULL,
    [GroupInfo]         NVARCHAR (4000) NULL,
    [GroupImage]        NVARCHAR (1000) NULL,
    [FacebookURL]       NVARCHAR (1000) NULL,
    [TwitterURL]        NVARCHAR (1000) NULL,
    [GooglePlusURL]     NVARCHAR (1000) NULL,
    [LinkedInURL]       NVARCHAR (1000) NULL,
    [Parent]            INT             NULL,
    [Level]             INT             NOT NULL,
    [Position]          INT             NOT NULL,
    [GroupContactEmail] NVARCHAR (100)  NULL,
    [LinkType]          TINYINT         DEFAULT ((0)) NOT NULL,
    [GroupURL]          NVARCHAR (1000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsProfileGroups] PRIMARY KEY CLUSTERED ([GroupID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsAuthorGroups_Portals] FOREIGN KEY ([PortalID]) REFERENCES [dbo].[dnn_Portals] ([PortalID]) ON DELETE CASCADE
);

