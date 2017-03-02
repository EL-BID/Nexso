CREATE TABLE [dbo].[dnn_EasyDNNnewsCharList] (
    [ItemID]       INT          IDENTITY (1, 1) NOT NULL,
    [PortalID]     INT          NOT NULL,
    [OriginalChar] NVARCHAR (3) NULL,
    [NewChar]      NVARCHAR (3) NULL,
    CONSTRAINT [PK_dnn_EasyDNNnewsCharList] PRIMARY KEY CLUSTERED ([ItemID] ASC)
);

