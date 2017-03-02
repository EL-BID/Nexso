CREATE TABLE [dbo].[dnn_Journal_Security] (
    [JournalSecurityId] INT           IDENTITY (1, 1) NOT NULL,
    [JournalId]         INT           NOT NULL,
    [SecurityKey]       NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_Journal_Security] PRIMARY KEY CLUSTERED ([JournalSecurityId] ASC),
    CONSTRAINT [IX_dnn_Journal_Security] UNIQUE NONCLUSTERED ([JournalId] DESC, [SecurityKey] ASC)
);

