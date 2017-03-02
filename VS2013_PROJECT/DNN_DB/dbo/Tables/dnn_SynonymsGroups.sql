CREATE TABLE [dbo].[dnn_SynonymsGroups] (
    [SynonymsGroupID]      INT            IDENTITY (1, 1) NOT NULL,
    [SynonymsTags]         NVARCHAR (MAX) NOT NULL,
    [PortalID]             INT            NOT NULL,
    [CultureCode]          NVARCHAR (50)  NOT NULL,
    [CreatedByUserID]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       NOT NULL,
    [LastModifiedByUserID] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dnn_SynonymsGroups] PRIMARY KEY CLUSTERED ([SynonymsGroupID] ASC)
);

