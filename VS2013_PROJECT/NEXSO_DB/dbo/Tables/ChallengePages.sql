CREATE TABLE [dbo].[ChallengePages] (
    [ChallengePageId]       UNIQUEIDENTIFIER NOT NULL,
    [ChallengeCustomDataId] UNIQUEIDENTIFIER NOT NULL,
    [Title]                 VARCHAR (50)     NULL,
    [Tagline]               VARCHAR (500)    NULL,
    [Description]           VARCHAR (MAX)    NULL,
    [Content]               VARCHAR (MAX)    NULL,
    [Reference]             VARCHAR (50)     NULL,
    [Url]                   VARCHAR (500)    NULL,
    [Order]                 SMALLINT         NULL,
    [Visibility]            VARCHAR (50)     NULL,
    [ContentType]           VARCHAR (50)     NULL,
    [TabID]                 INT              NULL,
    CONSTRAINT [PK_ChallengePages] PRIMARY KEY CLUSTERED ([ChallengePageId] ASC),
    CONSTRAINT [FK_ChallengePages_ChallengeCustomData] FOREIGN KEY ([ChallengeCustomDataId]) REFERENCES [dbo].[ChallengeCustomData] ([ChallengeCustomDatalId])
);


GO
ALTER TABLE [dbo].[ChallengePages] NOCHECK CONSTRAINT [FK_ChallengePages_ChallengeCustomData];



