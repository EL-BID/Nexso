CREATE TABLE [dbo].[SolutionLogs] (
    [SolutionLogId] UNIQUEIDENTIFIER NOT NULL,
    [SolutionId]    UNIQUEIDENTIFIER NOT NULL,
    [Key]           VARCHAR (100)    NOT NULL,
    [Value]         VARCHAR (MAX)    NULL,
    [Date]          DATETIME         NOT NULL,
    [DataType]      VARCHAR (50)     NULL,
    [Schema]        VARCHAR (MAX)    NULL,
    [Delete]        BIT              CONSTRAINT [DF_SolutionLogs_Delete] DEFAULT ((0)) NOT NULL,
    [UserID]        INT              NULL,
    CONSTRAINT [PK_SolutionLogs] PRIMARY KEY CLUSTERED ([SolutionLogId] ASC),
    CONSTRAINT [FK_SolutionLogs_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId])
);


GO
ALTER TABLE [dbo].[SolutionLogs] NOCHECK CONSTRAINT [FK_SolutionLogs_Solution];



