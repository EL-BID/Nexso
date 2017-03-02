CREATE TABLE [dbo].[dnn_CoreMessaging_UserPreferences] (
    [UserPreferenceId]            INT IDENTITY (1, 1) NOT NULL,
    [PortalId]                    INT NOT NULL,
    [UserId]                      INT NOT NULL,
    [MessagesEmailFrequency]      INT NOT NULL,
    [NotificationsEmailFrequency] INT NOT NULL,
    CONSTRAINT [PK_dnn_CoreMessaging_UserPreferences] PRIMARY KEY CLUSTERED ([UserPreferenceId] ASC)
);

