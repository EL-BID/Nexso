CREATE procedure [dbo].[dnn_DeleteListEntryByID]

@EntryId   int,
@DeleteChild bit

as

Delete
From dbo.dnn_Lists
Where  [EntryID] = @EntryID

If @DeleteChild = 1
Begin
	Delete 
	From dbo.dnn_Lists
	Where [ParentID] = @EntryID
End

