CREATE TABLE [dbo].[Documents] (
    [DocumentId]        UNIQUEIDENTIFIER NOT NULL,
    [ExternalReference] UNIQUEIDENTIFIER NULL,
    [Title]             VARCHAR (200)    NULL,
    [Name]              VARCHAR (200)    NULL,
    [Size]              INT              NULL,
    [DocumentObject]    VARBINARY (MAX)  NULL,
    [Created]           DATETIME         NOT NULL,
    [Updated]           DATETIME         NOT NULL,
    [Read]              DATETIME         NULL,
    [Deleted]           BIT              NULL,
    [Status]            VARCHAR (10)     NULL,
    [Permission]        VARCHAR (10)     NULL,
    [Description]       VARCHAR (500)    NULL,
    [FileType]          VARCHAR (50)     NULL,
    [Version]           INT              CONSTRAINT [DF_Documents_Version] DEFAULT ((1)) NOT NULL,
    [Category]          VARCHAR (50)     NULL,
    [Author]            VARCHAR (50)     NULL,
    [Views]             INT              CONSTRAINT [DF_Documents_Views] DEFAULT ((0)) NOT NULL,
    [Tags]              VARCHAR (5000)   NULL,
    [DocumentType]      VARCHAR (50)     NULL,
    [Scope]             VARCHAR (50)     NULL,
    [UploadedBy]        INT              NULL,
    [CreatedBy]         INT              NULL,
    [Folder]            VARCHAR (500)    NULL,
    CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED ([DocumentId] ASC),
    CONSTRAINT [FK_Documents_Campaigns] FOREIGN KEY ([ExternalReference]) REFERENCES [dbo].[Campaigns] ([CampaignId]),
    CONSTRAINT [FK_Documents_Organization] FOREIGN KEY ([ExternalReference]) REFERENCES [dbo].[Organization] ([OrganizationID]),
    CONSTRAINT [FK_Documents_Solution] FOREIGN KEY ([ExternalReference]) REFERENCES [dbo].[Solution] ([SolutionId]),
    CONSTRAINT [FK_Documents_UserProperties] FOREIGN KEY ([UploadedBy]) REFERENCES [dbo].[UserProperties] ([UserId]),
    CONSTRAINT [FK_Documents_UserProperties1] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Campaigns];


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Organization];


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Solution];


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_UserProperties];


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_UserProperties1];




GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Campaigns];


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Organization];


GO
ALTER TABLE [dbo].[Documents] NOCHECK CONSTRAINT [FK_Documents_Solution];



