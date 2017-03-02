CREATE TABLE [dbo].[dnn_Schedule] (
    [ScheduleID]                INT             IDENTITY (1, 1) NOT NULL,
    [TypeFullName]              VARCHAR (200)   NOT NULL,
    [TimeLapse]                 INT             NOT NULL,
    [TimeLapseMeasurement]      VARCHAR (2)     NOT NULL,
    [RetryTimeLapse]            INT             NOT NULL,
    [RetryTimeLapseMeasurement] VARCHAR (2)     NOT NULL,
    [RetainHistoryNum]          INT             NOT NULL,
    [AttachToEvent]             VARCHAR (50)    NOT NULL,
    [CatchUpEnabled]            BIT             NOT NULL,
    [Enabled]                   BIT             NOT NULL,
    [ObjectDependencies]        VARCHAR (300)   NOT NULL,
    [Servers]                   NVARCHAR (2000) NULL,
    [CreatedByUserID]           INT             NULL,
    [CreatedOnDate]             DATETIME        NULL,
    [LastModifiedByUserID]      INT             NULL,
    [LastModifiedOnDate]        DATETIME        NULL,
    [FriendlyName]              NVARCHAR (200)  NULL,
    [ScheduleStartDate]         DATETIME        NULL,
    CONSTRAINT [PK_dnn_Schedule] PRIMARY KEY CLUSTERED ([ScheduleID] ASC)
);

