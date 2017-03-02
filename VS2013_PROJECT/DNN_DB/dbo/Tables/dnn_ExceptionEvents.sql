CREATE TABLE [dbo].[dnn_ExceptionEvents] (
    [LogEventID]      BIGINT         NOT NULL,
    [AssemblyVersion] VARCHAR (20)   NOT NULL,
    [PortalId]        INT            NULL,
    [UserId]          INT            NULL,
    [TabId]           INT            NULL,
    [RawUrl]          NVARCHAR (260) NULL,
    [Referrer]        NVARCHAR (260) NULL,
    [UserAgent]       NVARCHAR (260) NULL,
    CONSTRAINT [PK_dnn_ExceptionEvents] PRIMARY KEY CLUSTERED ([LogEventID] ASC),
    CONSTRAINT [FK_dnn_ExceptionEvents_EventLog] FOREIGN KEY ([LogEventID]) REFERENCES [dbo].[dnn_EventLog] ([LogEventID]) ON DELETE CASCADE
);

