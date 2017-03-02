CREATE TABLE [dbo].[dnn_EasyDNNNewsEventsDataPostItems] (
    [PostSettingsID] INT NOT NULL,
    [ArticleID]      INT NOT NULL,
    [Finished]       BIT NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsEventsDataPostItems] PRIMARY KEY CLUSTERED ([PostSettingsID] ASC, [ArticleID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsDataPostItems_EasyDNNNewsEventPostSettings] FOREIGN KEY ([PostSettingsID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventPostSettings] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNNewsEventsDataPostItems_EasyDNNNewsEventsData] FOREIGN KEY ([ArticleID]) REFERENCES [dbo].[dnn_EasyDNNNewsEventsData] ([ArticleID]) ON DELETE CASCADE
);


GO
CREATE TRIGGER [dbo].[dnn_EasyDNNNewsEventsDataPostItemsDelete]
    ON [dbo].[dnn_EasyDNNNewsEventsDataPostItems]
    AFTER DELETE AS
BEGIN
	SET NOCOUNT ON;
    DELETE FROM dbo.[dnn_EasyDNNNewsEventPostSettings] WHERE id IN (SELECT PostSettingsID FROM deleted)
END


