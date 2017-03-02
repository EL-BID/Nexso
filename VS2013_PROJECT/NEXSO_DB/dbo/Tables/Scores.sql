CREATE TABLE [dbo].[Scores] (
    [ScoreId]            UNIQUEIDENTIFIER NOT NULL,
    [UserId]             INT              NOT NULL,
    [SolutionId]         UNIQUEIDENTIFIER NOT NULL,
    [ScoreType]          VARCHAR (50)     NOT NULL,
    [ComputedValue]      FLOAT (53)       NULL,
    [Active]             BIT              CONSTRAINT [DF_Scores_Active] DEFAULT ((1)) NOT NULL,
    [Created]            DATETIME         NOT NULL,
    [Updated]            DATETIME         NOT NULL,
    [ChallengeReference] VARCHAR (50)     NULL,
    CONSTRAINT [PK_Scores] PRIMARY KEY CLUSTERED ([ScoreId] ASC),
    CONSTRAINT [FK_Scores_Scores] FOREIGN KEY ([ScoreId]) REFERENCES [dbo].[Scores] ([ScoreId]),
    CONSTRAINT [FK_Scores_ScoreTypes] FOREIGN KEY ([ScoreType]) REFERENCES [dbo].[ScoreTypes] ([ScoreTypeId]),
    CONSTRAINT [FK_Scores_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId]),
    CONSTRAINT [FK_Scores_UserProperties] FOREIGN KEY ([UserId]) REFERENCES [dbo].[UserProperties] ([UserId])
);


GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_Scores];


GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_ScoreTypes];


GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_Solution];


GO
ALTER TABLE [dbo].[Scores] NOCHECK CONSTRAINT [FK_Scores_UserProperties];



