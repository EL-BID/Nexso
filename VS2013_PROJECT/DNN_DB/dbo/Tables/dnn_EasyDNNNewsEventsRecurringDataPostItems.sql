CREATE TABLE [dbo].[dnn_EasyDNNNewsEventsRecurringDataPostItems] (
    [PostSettingsID] INT NOT NULL,
    [ArticleID]      INT NOT NULL,
    [RecurringID]    INT NOT NULL,
    [Finished]       BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventsRecurringDataPostItems] PRIMARY KEY CLUSTERED ([PostSettingsID] ASC, [ArticleID] ASC, [RecurringID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsRecurringDataPostItems_EasyDNNNewsEventPostSettings] FOREIGN KEY ([PostSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventPostSettings] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsRecurringDataPostItems_EasyDNNNewsEventsRecurringData] FOREIGN KEY ([ArticleID], [RecurringID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsRecurringData] ([ArticleID], [RecurringID]) ON DELETE CASCADE
);


GO
CREATE TRIGGER [dbo].[dnn_EasyDNNNewsEventsRecurringDataPostItemsDelete]
    ON [dbo].[dnn_EasyDNNNewsEventsRecurringDataPostItems]
    AFTER DELETE AS
BEGIN
	SET NOCOUNT ON;
    DELETE FROM dbo.[dnn_EasyDNNNewsEventPostSettings] WHERE id IN (SELECT PostSettingsID FROM deleted)
END


