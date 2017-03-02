CREATE TABLE [dbo].[dnn_EventQueue] (
    [EventMessageID]   INT            IDENTITY (1, 1) NOT NULL,
    [EventName]        NVARCHAR (100) NOT NULL,
    [Priority]         INT            NOT NULL,
    [ProcessorType]    NVARCHAR (250) NOT NULL,
    [ProcessorCommand] NVARCHAR (250) NOT NULL,
    [Body]             NVARCHAR (250) NOT NULL,
    [Sender]           NVARCHAR (250) NOT NULL,
    [Subscriber]       NVARCHAR (100) NOT NULL,
    [AuthorizedRoles]  NVARCHAR (250) NOT NULL,
    [ExceptionMessage] NVARCHAR (250) NOT NULL,
    [SentDate]         DATETIME       NOT NULL,
    [ExpirationDate]   DATETIME       NOT NULL,
    [Attributes]       NTEXT          NOT NULL,
    [IsComplete]       BIT            CONSTRAINT [DF_dnn_EventQueue_IsComplete] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dnn_EventQueue] PRIMARY KEY CLUSTERED ([EventMessageID] ASC)
);

