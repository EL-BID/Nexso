CREATE TABLE [dbo].[dnn_SQLQueries] (
    [QueryId]              INT            IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (200) NOT NULL,
    [Query]                NVARCHAR (MAX) NOT NULL,
    [ConnectionStringName] NVARCHAR (50)  NOT NULL,
    [CreatedByUserId]      INT            NOT NULL,
    [CreatedOnDate]        DATETIME       NOT NULL,
    [LastModifiedByUserId] INT            NOT NULL,
    [LastModifiedOnDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dnn_SavedQueries] PRIMARY KEY CLUSTERED ([QueryId] ASC)
);

