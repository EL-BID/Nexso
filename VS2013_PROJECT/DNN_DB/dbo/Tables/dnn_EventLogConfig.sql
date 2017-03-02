CREATE TABLE [dbo].[dnn_EventLogConfig] (
    [ID]                            INT           IDENTITY (1, 1) NOT NULL,
    [LogTypeKey]                    NVARCHAR (35) NULL,
    [LogTypePortalID]               INT           NULL,
    [LoggingIsActive]               BIT           NOT NULL,
    [KeepMostRecent]                INT           NOT NULL,
    [EmailNotificationIsActive]     BIT           NOT NULL,
    [NotificationThreshold]         INT           NULL,
    [NotificationThresholdTime]     INT           NULL,
    [NotificationThresholdTimeType] INT           NULL,
    [MailFromAddress]               NVARCHAR (50) NOT NULL,
    [MailToAddress]                 NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_EventLogConfig] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_dnn_EventLogConfig_dnn_EventLogTypes] FOREIGN KEY ([LogTypeKey]) REFERENCES [dbo].[dnn_EventLogTypes] ([LogTypeKey])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_dnn_LogTypeKey_dnn_LogTypePortalID]
    ON [dbo].[dnn_EventLogConfig]([LogTypeKey] ASC, [LogTypePortalID] ASC);

