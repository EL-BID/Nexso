CREATE TABLE [dbo].[dnn_Journal_Types] (
    [JournalTypeId]    INT            NOT NULL,
    [JournalType]      NVARCHAR (25)  NULL,
    [icon]             NVARCHAR (25)  NULL,
    [PortalId]         INT            CONSTRAINT [DF_dnn_JournalTypes_PortalId] DEFAULT ((-1)) NOT NULL,
    [IsEnabled]        BIT            CONSTRAINT [DF_dnn_JournalTypes_IsEnabled] DEFAULT ((1)) NOT NULL,
    [AppliesToProfile] BIT            CONSTRAINT [DF_dnn_JournalTypes_AppliesToProfile] DEFAULT ((1)) NOT NULL,
    [AppliesToGroup]   BIT            CONSTRAINT [DF_dnn_JournalTypes_AppliesToGroup] DEFAULT ((1)) NOT NULL,
    [AppliesToStream]  BIT            CONSTRAINT [DF_dnn_JournalTypes_AppliesToStream] DEFAULT ((1)) NOT NULL,
    [Options]          NVARCHAR (MAX) NULL,
    [SupportsNotify]   BIT            CONSTRAINT [DF_dnn_JournalTypes_SupportsNotify] DEFAULT ((0)) NOT NULL,
    [EnableComments]   BIT            CONSTRAINT [DF_dnn_Journal_Types_EnableComments] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dnn_JournalTypes] PRIMARY KEY CLUSTERED ([JournalTypeId] ASC)
);

