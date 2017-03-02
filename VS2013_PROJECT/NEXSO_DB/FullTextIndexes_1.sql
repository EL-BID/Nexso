
GO
CREATE FULLTEXT INDEX ON [dbo].[Solution]
    ([Title] LANGUAGE 1033, [TagLine] LANGUAGE 1033)
    KEY INDEX [PK_Solution]
    on [SolutionCatalog];

