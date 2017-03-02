CREATE TABLE [dbo].[CampaignLogs] (
    [CampaignLogId]    UNIQUEIDENTIFIER NOT NULL,
    [CampaignId]       UNIQUEIDENTIFIER NULL,
    [email]            VARCHAR (100)    NULL,
    [userId]           INT              NULL,
    [SentOn]           DATETIME         NULL,
    [Status]           VARCHAR (50)     NULL,
    [MailContent]      VARCHAR (MAX)    NULL,
    [MailSubject]      VARCHAR (500)    NULL,
    [CreatedOn]        DATETIME         NULL,
    [ReadOn]           DATETIME         NULL,
    [TrackKey]         VARCHAR (50)     NULL,
    [CampaignAttemp]   INT              CONSTRAINT [DF_CampaingLogs_CampaingAttemp] DEFAULT ((0)) NOT NULL,
    [Attemp]           INT              CONSTRAINT [DF_CampaingLogs_Attemp] DEFAULT ((0)) NOT NULL,
    [TrackingMetaData] VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_CampaignLogs] PRIMARY KEY CLUSTERED ([CampaignLogId] ASC),
    CONSTRAINT [FK_CampaignLogs_Campaigns] FOREIGN KEY ([CampaignId]) REFERENCES [dbo].[Campaigns] ([CampaignId])
);


GO
ALTER TABLE [dbo].[CampaignLogs] NOCHECK CONSTRAINT [FK_CampaignLogs_Campaigns];



