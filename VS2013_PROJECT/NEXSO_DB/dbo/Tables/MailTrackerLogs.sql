CREATE TABLE [dbo].[MailTrackerLogs] (
    [MailTrackerLogId] UNIQUEIDENTIFIER NOT NULL,
    [CampaingLogId]    UNIQUEIDENTIFIER NOT NULL,
    [Language]         VARCHAR (10)     NULL,
    [Country]          VARCHAR (50)     NULL,
    [State]            VARCHAR (50)     NULL,
    [City]             VARCHAR (50)     NULL,
    [Latitude]         DECIMAL (10, 7)  NULL,
    [Longitude]        DECIMAL (10, 7)  NULL,
    [SourceBrowsing]   VARCHAR (50)     NULL,
    [IP]               VARCHAR (50)     NULL,
    [Network]          VARCHAR (100)    NULL,
    [Browser]          VARCHAR (100)    NULL,
    [Device]           VARCHAR (100)    NULL,
    CONSTRAINT [PK_MailTrackerLogs] PRIMARY KEY CLUSTERED ([MailTrackerLogId] ASC),
    CONSTRAINT [FK_MailTrackerLogs_CampaignLogs] FOREIGN KEY ([CampaingLogId]) REFERENCES [dbo].[CampaignLogs] ([CampaignLogId])
);


GO
ALTER TABLE [dbo].[MailTrackerLogs] NOCHECK CONSTRAINT [FK_MailTrackerLogs_CampaignLogs];



