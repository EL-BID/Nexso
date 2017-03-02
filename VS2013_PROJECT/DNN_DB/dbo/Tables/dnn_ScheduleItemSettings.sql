CREATE TABLE [dbo].[dnn_ScheduleItemSettings] (
    [ScheduleID]   INT            NOT NULL,
    [SettingName]  NVARCHAR (50)  NOT NULL,
    [SettingValue] NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_dnn_ScheduleItemSettings] PRIMARY KEY CLUSTERED ([ScheduleID] ASC, [SettingName] ASC),
    CONSTRAINT [FK_dnn_ScheduleItemSettings_dnn_Schedule] FOREIGN KEY ([ScheduleID]) REFERENCES [dbo].[dnn_Schedule] ([ScheduleID]) ON DELETE CASCADE
);

