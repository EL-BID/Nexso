CREATE TABLE [dbo].[ChallengeJudges] (
    [ChallengeJudgeId]   UNIQUEIDENTIFIER NOT NULL,
    [UserId]             INT              NOT NULL,
    [ChallengeReference] VARCHAR (50)     NOT NULL,
    [PermisionLevel]     VARCHAR (50)     NULL,
    [FromDate]           DATETIME         NULL,
    [ToDate]             DATETIME         NULL,
    [Note]               VARCHAR (500)    NULL,
    CONSTRAINT [PK_ChallengeJudges] PRIMARY KEY CLUSTERED ([ChallengeJudgeId] ASC),
    CONSTRAINT [FK_ChallengeJudges_UserProperties] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[ChallengeJudges] NOCHECK CONSTRAINT [FK_ChallengeJudges_UserProperties];



