CREATE TABLE [dbo].[SolutionLists] (
    [ListId]     UNIQUEIDENTIFIER NOT NULL,
    [SolutionId] UNIQUEIDENTIFIER NOT NULL,
    [Category]   VARCHAR (50)     NOT NULL,
    [Key]        VARCHAR (50)     NOT NULL,
    CONSTRAINT [PK_SolutionLists] PRIMARY KEY CLUSTERED ([ListId] ASC),
    CONSTRAINT [FK_SolutionLists_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId])
);


GO
ALTER TABLE [dbo].[SolutionLists] NOCHECK CONSTRAINT [FK_SolutionLists_Solution];



