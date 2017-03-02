CREATE TABLE [dbo].[dnn_Taxonomy_Terms] (
    [TermID]               INT             IDENTITY (1, 1) NOT NULL,
    [VocabularyID]         INT             NOT NULL,
    [ParentTermID]         INT             NULL,
    [Name]                 NVARCHAR (250)  NOT NULL,
    [Description]          NVARCHAR (2500) NULL,
    [Weight]               INT             CONSTRAINT [DF_dnn_Taxonomy_Terms_Weight] DEFAULT ((0)) NOT NULL,
    [TermLeft]             INT             CONSTRAINT [DF_dnn_Taxonomy_Terms_TermLeft] DEFAULT ((0)) NOT NULL,
    [TermRight]            INT             CONSTRAINT [DF_dnn_Taxonomy_Terms_TermRight] DEFAULT ((0)) NOT NULL,
    [CreatedByUserID]      INT             NULL,
    [CreatedOnDate]        DATETIME        NULL,
    [LastModifiedByUserID] INT             NULL,
    [LastModifiedOnDate]   DATETIME        NULL,
    CONSTRAINT [PK_dnn_Taxonomy_Terms] PRIMARY KEY CLUSTERED ([TermID] ASC),
    CONSTRAINT [FK_dnn_Taxonomy_Terms_dnn_Taxonomy_Terms] FOREIGN KEY ([ParentTermID]) REFERENCES [dbo].[dnn_Taxonomy_Terms] ([TermID]),
    CONSTRAINT [FK_dnn_Taxonomy_Terms_dnn_Taxonomy_Vocabularies] FOREIGN KEY ([VocabularyID]) REFERENCES [dbo].[dnn_Taxonomy_Vocabularies] ([VocabularyID]) ON DELETE CASCADE
);

