CREATE TABLE [dbo].[dnn_EasyDNNNewsSystemTokens] (
    [EntryID]      INT             IDENTITY (1, 1) NOT NULL,
    [TokenTitle]   NVARCHAR (150)  NULL,
    [Description]  NVARCHAR (250)  NULL,
    [TokenContent] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_dnn_EasyDNNSystemTokens] PRIMARY KEY CLUSTERED ([EntryID] ASC)
);

