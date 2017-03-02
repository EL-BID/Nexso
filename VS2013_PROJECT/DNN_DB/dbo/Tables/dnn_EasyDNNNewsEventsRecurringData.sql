CREATE TABLE [dbo].[dnn_EasyDNNNewsEventsRecurringData] (
    [ArticleID]     INT      NOT NULL,
    [RecurringID]   INT      NOT NULL,
    [StartDateTime] DATETIME NOT NULL,
    [EndDateTime]   DATETIME NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventsRecurringData] PRIMARY KEY CLUSTERED ([ArticleID] ASC, [RecurringID] ASC),
    CONSTRAINT [chk_dnn_StartDateTimeEndDateTime] CHECK ([EndDateTime]>=[StartDateTime]),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsRecurringData_EasyDNNNewsEventsData] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsData] ([ArticleID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsEventsRecurringData_EndDateTime]
    ON [dbo].[dnn_EasyDNNNewsEventsRecurringData]([EndDateTime] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_EasyDNNNewsEventsRecurringData_StartDateTime]
    ON [dbo].[dnn_EasyDNNNewsEventsRecurringData]([StartDateTime] ASC);

