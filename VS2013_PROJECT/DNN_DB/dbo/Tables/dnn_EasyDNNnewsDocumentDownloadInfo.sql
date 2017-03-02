CREATE TABLE [dbo].[dnn_EasyDNNnewsDocumentDownloadInfo] (
    [DownloadInfoID] INT           IDENTITY (1, 1) NOT NULL,
    [DocEntryID]     INT           NOT NULL,
    [UserID]         INT           NULL,
    [DateDownload]   DATETIME      CONSTRAINT [DF_dnn_EasyDNNnewsDocumentDownloadInfo_dnn_DateDownload] DEFAULT (getutcdate()) NOT NULL,
    [DownloadIP]     NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNnewsDocumentDownloadInfo] PRIMARY KEY CLUSTERED ([DownloadInfoID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNnewsDocumentDownloadInfo_dnn_EasyDNNNewsDocuments] FOREIGN KEY ([DocEntryID]) REFERENCES [dbo].[dnn_EasyDNNNewsDocuments] ([DocEntryID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNnewsDocumentDownloadInfo_dnn_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[dnn_Users] ([UserID]) ON DELETE SET NULL
);

