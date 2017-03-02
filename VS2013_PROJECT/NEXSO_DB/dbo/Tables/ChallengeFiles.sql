CREATE TABLE [dbo].[ChallengeFiles] (
    [ChallengeObjectId]    UNIQUEIDENTIFIER NOT NULL,
    [ChallengeReferenceId] VARCHAR (50)     NOT NULL,
    [ObjectName]           VARCHAR (255)    NULL,
    [ObjectLocation]       VARCHAR (1000)   NULL,
    [ObjectType]           VARCHAR (50)     NULL,
    [Created]              DATETIME         NULL,
    [Updated]              DATETIME         NULL,
    [Size]                 INT              NULL,
    [ObjectExtension]      VARCHAR (50)     NULL,
    [Delete]               BIT              NULL,
    [Language]             VARCHAR (50)     NULL,
    CONSTRAINT [PK_ChallengeFiles] PRIMARY KEY CLUSTERED ([ChallengeObjectId] ASC),
    CONSTRAINT [FK_ChallengeFiles_ChallengeSchemas] FOREIGN KEY ([ChallengeReferenceId]) REFERENCES [dbo].[ChallengeSchemas] ([ChallengeReference])
);


GO
ALTER TABLE [dbo].[ChallengeFiles] NOCHECK CONSTRAINT [FK_ChallengeFiles_ChallengeSchemas];



