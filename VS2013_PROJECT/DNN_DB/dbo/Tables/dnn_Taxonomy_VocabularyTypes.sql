CREATE TABLE [dbo].[dnn_Taxonomy_VocabularyTypes] (
    [VocabularyTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [VocabularyType]   NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_Taxonomy_VocabularyType] PRIMARY KEY CLUSTERED ([VocabularyTypeID] ASC)
);

