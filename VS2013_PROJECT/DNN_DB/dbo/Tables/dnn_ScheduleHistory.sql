CREATE TABLE [dbo].[dnn_ScheduleHistory] (
    [ScheduleHistoryID] INT            IDENTITY (1, 1) NOT NULL,
    [ScheduleID]        INT            NOT NULL,
    [StartDate]         DATETIME       NOT NULL,
    [EndDate]           DATETIME       NULL,
    [Succeeded]         BIT            NULL,
    [LogNotes]          NTEXT          NULL,
    [NextStart]         DATETIME       NULL,
    [Server]            NVARCHAR (150) NULL,
    CONSTRAINT [PK_dnn_ScheduleHistory] PRIMARY KEY CLUSTERED ([ScheduleHistoryID] ASC),
    CONSTRAINT [FK_dnn_ScheduleHistory_dnn_Schedule] FOREIGN KEY ([ScheduleID]) REFERENCES [dbo].[dnn_Schedule] ([ScheduleID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ScheduleHistory_NextStart]
    ON [dbo].[dnn_ScheduleHistory]([ScheduleID] ASC, [NextStart] DESC);


GO
CREATE NONCLUSTERED INDEX [IX_dnn_ScheduleHistory_StartDate]
    ON [dbo].[dnn_ScheduleHistory]([ScheduleID] ASC, [StartDate] DESC);

