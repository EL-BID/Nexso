CREATE TABLE [dbo].[CampaignTemplates] (
    [TemplateId]      UNIQUEIDENTIFIER NOT NULL,
    [TemplateTitle]   VARCHAR (200)    NULL,
    [TemplateContent] VARCHAR (MAX)    NULL,
    [TemplateVersion] INT              NULL,
    [Created]         DATETIME         NULL,
    [Updated]         DATETIME         NULL,
    [Deleted]         BIT              CONSTRAINT [DF_CampaingTemplates_Deleted] DEFAULT ((0)) NOT NULL,
    [Language]        VARCHAR (10)     NULL,
    [TemplateSubject] VARCHAR (500)    NULL,
    CONSTRAINT [PK_CampaignTemplates] PRIMARY KEY CLUSTERED ([TemplateId] ASC)
);

