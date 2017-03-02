CREATE TABLE [dbo].[dnn_Affiliates] (
    [AffiliateId]  INT        IDENTITY (1, 1) NOT NULL,
    [VendorId]     INT        NULL,
    [StartDate]    DATETIME   NULL,
    [EndDate]      DATETIME   NULL,
    [CPC]          FLOAT (53) NOT NULL,
    [Clicks]       INT        NOT NULL,
    [CPA]          FLOAT (53) NOT NULL,
    [Acquisitions] INT        NOT NULL,
    CONSTRAINT [PK_dnn_Affiliates] PRIMARY KEY CLUSTERED ([AffiliateId] ASC),
    CONSTRAINT [FK_dnn_Affiliates_dnn_Vendors] FOREIGN KEY ([VendorId]) REFERENCES [dbo].[dnn_Vendors] ([VendorId]) ON DELETE CASCADE
);

