CREATE TABLE [dbo].[dnn_EasyDNNNewsEventsRecurringContent] (
    [ArticleID]   INT             NOT NULL,
    [RecurringID] INT             NOT NULL,
    [LocaleCode]  NVARCHAR (20)   NOT NULL,
    [Summary]     NVARCHAR (4000) NOT NULL,
    [Article]     NVARCHAR (MAX)  NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventsRecurringContent] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [RecurringID] ASC, [LocaleCode] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsRecurringContent_EasyDNNNewsEventsRecurringData] FOREIGN KEY ([ArticleID], [RecurringID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsRecurringData] ([ArticleID], [RecurringID]) ON DELETE CASCADE
);

