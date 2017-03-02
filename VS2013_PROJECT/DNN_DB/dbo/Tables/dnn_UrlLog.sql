CREATE TABLE [dbo].[dnn_UrlLog] (
    [UrlLogID]      INT      IDENTITY (1, 1) NOT NULL,
    [UrlTrackingID] INT      NOT NULL,
    [ClickDate]     DATETIME NOT NULL,
    [UserID]        INT      NULL,
    CONSTRAINT [PK_dnn_UrlLog] PRIMARY KEY CLUSTERED ([UrlLogID] ASC),
    CONSTRAINT [FK_dnn_UrlLog_dnn_UrlTracking] FOREIGN KEY ([UrlTrackingID]) REFERENCES [dbo].[dnn_UrlTracking] ([UrlTrackingID]) ON DELETE CASCADE
);

