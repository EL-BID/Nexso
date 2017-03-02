CREATE TABLE [dbo].[dnn_Journal_TypeFilters] (
    [JournalTypeFilterId] INT IDENTITY (1, 1) NOT NULL,
    [PortalId]            INT NOT NULL,
    [ModuleId]            INT NOT NULL,
    [JournalTypeId]       INT NOT NULL,
    CONSTRAINT [PK_dnn_Journal_TypeFilters] PRIMARY KEY CLUSTERED ([JournalTypeFilterId] ASC)
);

