CREATE TABLE [dbo].[ScoreValues] (
    [ScoreValueId]   UNIQUEIDENTIFIER NOT NULL,
    [ScoreId]        UNIQUEIDENTIFIER NOT NULL,
    [value]          FLOAT (53)       NOT NULL,
    [ScoreValueType] VARCHAR (50)     NOT NULL,
    [Created]        DATETIME         NOT NULL,
    [Updated]        DATETIME         NOT NULL,
    [MetaData]       VARCHAR (MAX)    NULL,
    CONSTRAINT [PK_ScoreValues] PRIMARY KEY CLUSTERED ([ScoreValueId] ASC),
    CONSTRAINT [FK_ScoreValues_Scores] FOREIGN KEY ([ScoreId]) REFERENCES [dbo].[Scores] ([ScoreId]),
    CONSTRAINT [FK_ScoreValues_ScoreTypes] FOREIGN KEY ([ScoreValueType]) REFERENCES [dbo].[ScoreTypes] ([ScoreTypeId])
);


GO
ALTER TABLE [dbo].[ScoreValues] NOCHECK CONSTRAINT [FK_ScoreValues_Scores];


GO
ALTER TABLE [dbo].[ScoreValues] NOCHECK CONSTRAINT [FK_ScoreValues_ScoreTypes];



