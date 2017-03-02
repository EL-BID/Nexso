CREATE TABLE [dbo].[JudgesAssignation] (
    [JudgeAssigantionId] UNIQUEIDENTIFIER NOT NULL,
    [ChallengeJudgeId]   UNIQUEIDENTIFIER NULL,
    [SolutionId]         UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_JudgesAssignation] PRIMARY KEY CLUSTERED ([JudgeAssigantionId] ASC),
    CONSTRAINT [FK_JudgesAssignation_ChallengeJudges] FOREIGN KEY ([ChallengeJudgeId]) REFERENCES [dbo].[ChallengeJudges] ([ChallengeJudgeId]),
    CONSTRAINT [FK_JudgesAssignation_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId])
);


GO
ALTER TABLE [dbo].[JudgesAssignation] NOCHECK CONSTRAINT [FK_JudgesAssignation_ChallengeJudges];


GO
ALTER TABLE [dbo].[JudgesAssignation] NOCHECK CONSTRAINT [FK_JudgesAssignation_Solution];



