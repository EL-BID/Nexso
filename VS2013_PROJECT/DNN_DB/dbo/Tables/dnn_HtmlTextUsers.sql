CREATE TABLE [dbo].[dnn_HtmlTextUsers] (
    [HtmlTextUserID] INT      IDENTITY (1, 1) NOT NULL,
    [ItemID]         INT      NOT NULL,
    [StateID]        INT      NOT NULL,
    [ModuleID]       INT      NOT NULL,
    [TabID]          INT      NOT NULL,
    [UserID]         INT      NOT NULL,
    [CreatedOnDate]  DATETIME NOT NULL,
    CONSTRAINT [PK_dnn_HtmlTextUsers] PRIMARY KEY CLUSTERED ([HtmlTextUserID] ASC),
    CONSTRAINT [FK_dnn_HtmlTextUsers_dnn_HtmlText] FOREIGN KEY ([ItemID]) REFERENCES [dbo].[dnn_HtmlText] ([ItemID]) ON DELETE CASCADE
);

