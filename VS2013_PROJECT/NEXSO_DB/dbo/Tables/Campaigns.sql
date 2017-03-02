CREATE TABLE [dbo].[Campaigns] (
    [CampaignId]     UNIQUEIDENTIFIER NOT NULL,
    [TemplateId]     UNIQUEIDENTIFIER NULL,
    [Description]    VARCHAR (500)    NULL,
    [CampaignName]   VARCHAR (200)    NULL,
    [SendOn]         DATETIME         NULL,
    [Repeat]         INT              NULL,
    [Created]        DATETIME         NULL,
    [Updated]        DATETIME         NULL,
    [Status]         VARCHAR (10)     NULL,
    [Deleted]        BIT              CONSTRAINT [DF_Campaings_Deleted] DEFAULT ((0)) NOT NULL,
    [FilterTemplate] VARCHAR (MAX)    NULL,
    [CampaignType]   INT              NOT NULL,
    [NextExecution]  DATETIME         NULL,
    [TrackKey]       VARCHAR (50)     NULL,
    [Attemps]        INT              CONSTRAINT [DF_Campaings_Attemps] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignId] ASC),
    CONSTRAINT [FK_Campaigns_CampaignTemplates] FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[CampaignTemplates] ([TemplateId])
);


GO
ALTER TABLE [dbo].[Campaigns] NOCHECK CONSTRAINT [FK_Campaigns_CampaignTemplates];



