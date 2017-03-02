CREATE TABLE [dbo].[dnn_SearchIndexer] (
    [SearchIndexerID]                    INT        IDENTITY (1, 1) NOT NULL,
    [SearchIndexerAssemblyQualifiedName] CHAR (200) NOT NULL,
    CONSTRAINT [PK_dnn_SearchIndexer] PRIMARY KEY CLUSTERED ([SearchIndexerID] ASC)
);

