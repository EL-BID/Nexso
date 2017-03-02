CREATE TABLE [dbo].[dnn_FeedbackList] (
    [ListID]    INT            IDENTITY (1, 1) NOT NULL,
    [PortalID]  INT            NOT NULL,
    [ListType]  INT            DEFAULT ((1)) NULL,
    [IsActive]  BIT            DEFAULT ((1)) NULL,
    [Name]      NVARCHAR (50)  NULL,
    [ListValue] NVARCHAR (100) NULL,
    [SortOrder] INT            DEFAULT ((0)) NULL,
    [Portal]    BIT            NOT NULL,
    [ModuleID]  INT            NOT NULL,
    CONSTRAINT [PK_dnn_FeedbackList] PRIMARY KEY CLUSTERED ([ListID] ASC)
);

