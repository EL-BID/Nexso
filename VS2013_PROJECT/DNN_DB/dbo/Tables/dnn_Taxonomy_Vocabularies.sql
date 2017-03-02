CREATE TABLE [dbo].[dnn_Taxonomy_Vocabularies] (
    [VocabularyID]         INT             IDENTITY (1, 1) NOT NULL,
    [VocabularyTypeID]     INT             NOT NULL,
    [Name]                 NVARCHAR (250)  NOT NULL,
    [Description]          NVARCHAR (2500) NULL,
    [Weight]               INT             CONSTRAINT [DF_dnn_Taxonomy_Vocabularies_Weight] DEFAULT ((0)) NOT NULL,
    [ScopeID]              INT             NULL,
    [ScopeTypeID]          INT             NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    [IsSystem]             BIT             CONSTRAINT [DF_dnn_Taxonomy_Vocabularies_IsSystem] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_Taxonomy_Vocabulary] PRIMARY KEY CLUSTERED ([VocabularyID] ASC),
    CONSTRAINT [FK_dnn_Taxonomy_Vocabularies_dnn_Taxonomy_ScopeTypes] FOREIGN KEY ([ScopeTypeID]) REFERENCES [dbo].[dnn_Taxonomy_ScopeTypes] ([ScopeTypeID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_Taxonomy_Vocabularies_dnn_Taxonomy_VocabularyTypes] FOREIGN KEY ([VocabularyTypeID]) REFERENCES [dbo].[dnn_Taxonomy_VocabularyTypes] ([VocabularyTypeID])
);

