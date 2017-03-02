CREATE TABLE [dbo].[dnn_SearchStopWords] (
    [StopWordsID]          INT            IDENTITY (1, 1) NOT NULL,
    [StopWords]            NVARCHAR (MAX) NOT NULL,
    [CreatedByUserID]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       NOT NULL,
    [LastModifiedByUserID] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       NOT NULL,
    [PortalID]             INT            NOT NULL,
    [CultureCode]          NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_dnn_SearchStopWords] PRIMARY KEY CLUSTERED ([StopWordsID] ASC)
);

