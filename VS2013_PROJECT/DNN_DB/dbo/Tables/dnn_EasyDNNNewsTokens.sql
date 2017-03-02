CREATE TABLE [dbo].[dnn_EasyDNNNewsTokens] (
    [TokenID]      INT             IDENTITY (1, 1) NOT NULL,
    [PortalID]     INT             NULL,
    [TokenTitle]   NVARCHAR (250)  NULL,
    [TokenContent] NVARCHAR (4000) NULL,
    [UserID]       INT             NULL,
    [DateAdded]    DATETIME        NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsTokens] PRIMARY KEY CLUSTERED ([TokenID] ASC)
);

