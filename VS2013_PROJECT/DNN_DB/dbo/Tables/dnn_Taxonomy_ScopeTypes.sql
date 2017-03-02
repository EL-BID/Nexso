CREATE TABLE [dbo].[dnn_Taxonomy_ScopeTypes] (
    [ScopeTypeID] INT            IDENTITY (1, 1) NOT NULL,
    [ScopeType]   NVARCHAR (250) NULL,
    CONSTRAINT [PK_dnn_ScopeTypes] PRIMARY KEY CLUSTERED ([ScopeTypeID] ASC)
);

