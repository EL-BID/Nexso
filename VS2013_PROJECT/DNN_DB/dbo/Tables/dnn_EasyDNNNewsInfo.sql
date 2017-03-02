CREATE TABLE [dbo].[dnn_EasyDNNNewsInfo] (
    [EntryID] INT            IDENTITY (1, 1) NOT NULL,
    [Info1]   NVARCHAR (300) NOT NULL,
    [Info2]   NVARCHAR (300) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsInfo] PRIMARY KEY CLUSTERED ([EntryID] ASC)
);

