CREATE TABLE [dbo].[dnn_EasyDNNNewsUpdate] (
    [UpdateID]      INT           IDENTITY (1, 1) NOT NULL,
    [UpdateVersion] NVARCHAR (20) NOT NULL,
    [Finished]      BIT           NOT NULL,
    [InstallDate]   DATETIME      CONSTRAINT [DF_dnn_EasyDNNNewsUpdate_InstallDate] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNNewsUpdate] PRIMARY KEY CLUSTERED ([UpdateID] ASC)
);

