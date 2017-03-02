CREATE TABLE [dbo].[CustomDataLog] (
    [CustomDataLogId]   UNIQUEIDENTIFIER NOT NULL,
    [SolutionId]        UNIQUEIDENTIFIER NOT NULL,
    [CustomData]        VARCHAR (MAX)    NOT NULL,
    [CustomaDataSchema] VARCHAR (MAX)    NULL,
    [Created]           DATETIME         NOT NULL,
    [Updated]           DATETIME         NULL,
    [CustomDataType]    VARCHAR (50)     NOT NULL,
    [UserId]            INT              NOT NULL,
    CONSTRAINT [PK_CustomDataLog] PRIMARY KEY CLUSTERED ([CustomDataLogId] ASC),
    CONSTRAINT [FK_CustomDataLog_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId]),
    CONSTRAINT [FK_CustomDataLog_UserProperties] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[CustomDataLog] NOCHECK CONSTRAINT [FK_CustomDataLog_Solution];


GO
ALTER TABLE [dbo].[CustomDataLog] NOCHECK CONSTRAINT [FK_CustomDataLog_UserProperties];



