CREATE TABLE [dbo].[ScoreTypes] (
    [ScoreTypeId] VARCHAR (50) NOT NULL,
    [ScoreName]   VARCHAR (50) NOT NULL,
    [Weight]      FLOAT (53)   NOT NULL,
    CONSTRAINT [PK_ScoreTypes] PRIMARY KEY CLUSTERED ([ScoreTypeId] ASC)
);

