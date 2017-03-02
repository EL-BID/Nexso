CREATE TABLE [dbo].[dnn_Journal_Data] (
    [JournalDataId] INT IDENTITY (1, 1) NOT NULL,
    [JournalId]     INT NOT NULL,
    [JournalXML]    XML NOT NULL,
    CONSTRAINT [PK_dnn_Journal_Data] PRIMARY KEY CLUSTERED ([JournalDataId] ASC),
    CONSTRAINT [FK_dnn_Journal_Data_Journal] FOREIGN KEY ([JournalId]) REFERENCES [dbo].[dnn_Journal] ([JournalId]) ON DELETE CASCADE
);

