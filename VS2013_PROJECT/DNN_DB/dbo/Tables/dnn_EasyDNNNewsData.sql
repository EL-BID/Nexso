CREATE TABLE [dbo].[dnn_EasyDNNNewsData] (
    [EntryID] INT            NULL,
    [Value]   NVARCHAR (500) NULL
);


GO
CREATE CLUSTERED INDEX [IX_dnn_EasyDNNNewsData_EntryID]
    ON [dbo].[dnn_EasyDNNNewsData]([EntryID] ASC);

