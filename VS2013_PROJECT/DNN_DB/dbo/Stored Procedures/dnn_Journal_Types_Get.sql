CREATE PROCEDURE [dbo].[dnn_Journal_Types_Get]
@JournalType nvarchar(25)
AS
SELECT * from dbo.[dnn_Journal_Types] WHERE JournalType = @JournalType

