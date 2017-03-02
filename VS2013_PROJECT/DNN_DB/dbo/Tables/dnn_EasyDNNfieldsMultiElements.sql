CREATE TABLE [dbo].[dnn_EasyDNNfieldsMultiElements] (
    [FieldElementID] INT            IDENTITY (1, 1) NOT NULL,
    [CustomFieldID]  INT            NOT NULL,
    [FEParentID]     INT            NULL,
    [Text]           NVARCHAR (300) NOT NULL,
    [Position]       INT            NOT NULL,
    [DefSelected]    BIT            NOT NULL,
    CONSTRAINT [PK_dnn_EasyDNNfieldsMultiElements] PRIMARY KEY CLUSTERED ([FieldElementID] ASC),
    CONSTRAINT [FK_dnn_EasyDNNfieldsMultiElements_EasyDNNfields] FOREIGN KEY ([CustomFieldID]) REFERENCES [dbo].[dnn_EasyDNNfields] ([CustomFieldID]) ON DELETE CASCADE,
    CONSTRAINT [FK_dnn_EasyDNNfieldsMultiElements_EasyDNNfieldsMultiElements] FOREIGN KEY ([FEParentID]) REFERENCES [dbo].[dnn_EasyDNNfieldsMultiElements] ([FieldElementID])
);

