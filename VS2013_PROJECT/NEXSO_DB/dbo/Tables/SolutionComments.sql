CREATE TABLE [dbo].[SolutionComments] (
    [Comment_Id]  UNIQUEIDENTIFIER NOT NULL,
    [SolutionId]  UNIQUEIDENTIFIER NULL,
    [UserId]      INT              NULL,
    [Comment]     VARCHAR (5000)   NULL,
    [CreatedDate] DATETIME         NULL,
    [Publish]     BIT              NULL,
    [Scope]       VARCHAR (50)     NULL,
    CONSTRAINT [PK_SolutionComments] PRIMARY KEY CLUSTERED ([Comment_Id] ASC),
    CONSTRAINT [FK_SolutionComments_Solution] FOREIGN KEY ([SolutionId]) REFERENCES [dbo].[Solution] ([SolutionId])
);


GO
ALTER TABLE [dbo].[SolutionComments] NOCHECK CONSTRAINT [FK_SolutionComments_Solution];



