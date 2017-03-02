CREATE TABLE [dbo].[dnn_Journal_Access] (
    [JournalAccessId] INT              IDENTITY (1, 1) NOT NULL,
    [JournalTypeId]   INT              NOT NULL,
    [PortalId]        INT              NOT NULL,
    [Name]            NVARCHAR (50)    NOT NULL,
    [AccessKey]       UNIQUEIDENTIFIER NOT NULL,
    [IsEnabled]       BIT              NOT NULL,
    [DateCreated]     DATETIME         NOT NULL,
    CONSTRAINT [PK_dnn_Journal_Access] PRIMARY KEY CLUSTERED ([JournalAccessId] ASC)
);

