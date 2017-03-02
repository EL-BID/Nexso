CREATE PROCEDURE [dbo].[dnn_Journal_Types_GetById]
@JournalTypeId int
AS
SELECT * from dbo.[dnn_Journal_Types] WHERE JournalTypeId = @JournalTypeId

