CREATE TABLE [dbo].[Badges] (
    [BadgeId]     UNIQUEIDENTIFIER NOT NULL,
    [SolutionId]  UNIQUEIDENTIFIER NULL,
    [Type]        VARCHAR (50)     NULL,
    [Description] VARCHAR (500)    NULL,
    [Icon]        VARCHAR (500)    NULL,
    CONSTRAINT [PK_Badges] PRIMARY KEY CLUSTERED ([BadgeId] ASC),
    CONSTRAINT [FK_Badges_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId])
);


GO
ALTER TABLE [dbo].[Badges] NOCHECK CONSTRAINT [FK_Badges_Solution];



