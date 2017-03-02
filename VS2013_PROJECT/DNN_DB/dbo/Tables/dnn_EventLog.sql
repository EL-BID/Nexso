CREATE TABLE [dbo].[dnn_EventLog] (
    [LogGUID]                VARCHAR (36)   NOT NULL,
    [LogTypeKey]             NVARCHAR (35)  NOT NULL,
    [LogConfigID]            INT            NULL,
    [LogUserID]              INT            NULL,
    [LogUserName]            NVARCHAR (50)  NULL,
    [LogPortalID]            INT            NULL,
    [LogPortalName]          NVARCHAR (100) NULL,
    [LogCreateDate]          DATETIME       NOT NULL,
    [LogServerName]          NVARCHAR (50)  NOT NULL,
    [LogProperties]          XML            NULL,
    [LogNotificationPending] BIT            NULL,
    [LogEventID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [ExceptionHash]          VARCHAR (100)  NULL,
    CONSTRAINT [PK_dnn_EventLogMaster] PRIMARY KEY CLUSTERED ([LogEventID] ASC),
    CONSTRAINT [FK_dnn_EventLog_dnn_EventLogConfig] FOREIGN KEY ([LogConfigID]) REFERENCES [dbo].[dnn_EventLogConfig] ([ID]),
    CONSTRAINT [FK_dnn_EventLog_dnn_EventLogTypes] FOREIGN KEY ([LogTypeKey]) REFERENCES [dbo].[dnn_EventLogTypes] ([LogTypeKey]),
    CONSTRAINT [FK_dnn_EventLog_Exceptions] FOREIGN KEY ([ExceptionHash]) REFERENCES [dbo].[dnn_Exceptions] ([ExceptionHash])
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EventLog_LogConfigID]
    ON [dbo].[dnn_EventLog]([LogConfigID] ASC, [LogNotificationPending] ASC, [LogCreateDate] ASC)
    INCLUDE([LogEventID]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EventLog_LogCreateDate]
    ON [dbo].[dnn_EventLog]([LogCreateDate] ASC)
    INCLUDE([LogConfigID]);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EventLog_LogGUID]
    ON [dbo].[dnn_EventLog]([LogGUID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EventLog_LogType]
    ON [dbo].[dnn_EventLog]([LogTypeKey] ASC, [LogPortalID] ASC);

