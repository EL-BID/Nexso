CREATE TABLE [dbo].[dnn_EventLogTypes] (
    [LogTypeKey]          NVARCHAR (35)  NOT NULL,
    [LogTypeFriendlyName] NVARCHAR (50)  NOT NULL,
    [LogTypeDescription]  NVARCHAR (128) NOT NULL,
    [LogTypeOwner]        NVARCHAR (100) NOT NULL,
    [LogTypeCSSClass]     NVARCHAR (40)  NOT NULL,
    CONSTRAINT [PK_dnn_EventLogTypes] PRIMARY KEY CLUSTERED ([LogTypeKey] ASC)
);

