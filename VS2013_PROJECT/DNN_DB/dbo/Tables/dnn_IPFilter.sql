CREATE TABLE [dbo].[dnn_IPFilter] (
    [IPFilterID]           INT           IDENTITY (1, 1) NOT NULL,
    [IPAddress]            NVARCHAR (50) NULL,
    [SubnetMask]           NVARCHAR (50) NULL,
    [RuleType]             TINYINT       NULL,
    [CreatedByUserID]      INT           NULL,
    [CreatedOnDate]        DATETIME      NULL,
    [LastModifiedByUserID] INT           NULL,
    [LastModifiedOnDate]   DATETIME      NULL,
    CONSTRAINT [PK_dnn_IPFilter] PRIMARY KEY CLUSTERED ([IPFilterID] ASC)
);

