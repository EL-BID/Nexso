CREATE TABLE [dbo].[dnn_SearchCommonWords] (
    [CommonWordID] INT            IDENTITY (1, 1) NOT NULL,
    [CommonWord]   NVARCHAR (255) NOT NULL,
    [Locale]       NVARCHAR (10)  NULL,
    CONSTRAINT [PK_dnn_SearchCommonWords] PRIMARY KEY CLUSTERED ([CommonWordID] ASC)
);

