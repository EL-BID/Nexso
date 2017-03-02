CREATE TABLE [dbo].[dnn_EasyDNNNewsAuthorProfile] (
    [AuthorProfileID] INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]        INT             NOT NULL,
    [UserID]          INT             NOT NULL,
    [ShortInfo]       NVARCHAR (350)  NULL,
    [FullInfo]        NVARCHAR (4000) NULL,
    [ProfileImage]    NVARCHAR (1000) NULL,
    [FacebookURL]     NVARCHAR (1000) NULL,
    [TwitterURL]      NVARCHAR (1000) NULL,
    [GooglePlusURL]   NVARCHAR (1000) NULL,
    [LinkedInURL]     NVARCHAR (1000) NULL,
    [DateAdded]       DATETIME        NOT NULL,
    [Active]          BIT             NOT NULL,
    [ArticleCount]    INT             NOT NULL,
    [LinkType]        TINYINT         DEFAULT ((0)) NOT NULL,
    [AuthorURL]       NVARCHAR (1000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsAuthorProfile] PRIMARY KEY CLUSTERED ([AuthorProfileID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsAuthorProfiles_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE CASCADE,
    CONSTRAINT [IX_dnn_EasyDNNNewsAuthorProfile] UNIQUE NONCLUSTERED ([PortalID] ASC, [UserID] ASC)
);

