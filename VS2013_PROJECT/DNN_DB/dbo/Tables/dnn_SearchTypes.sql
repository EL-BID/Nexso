CREATE TABLE [dbo].[dnn_SearchTypes] (
    [SearchTypeId]      INT            IDENTITY (1, 1) NOT NULL,
    [SearchTypeName]    NVARCHAR (100) NOT NULL,
    [SearchResultClass] NVARCHAR (256) NOT NULL,
    [IsPrivate]         BIT            CONSTRAINT [DF_dnn_SearchTypes_IsPrivate] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dnn_SearchTypes] PRIMARY KEY CLUSTERED ([SearchTypeId] ASC)
);

