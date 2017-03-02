CREATE PROCEDURE [dbo].[dnn_Journal_Save]
@PortalId int,
@JournalId int,
@JournalTypeId int,
@UserId int,
@ProfileId int,
@GroupId int,
@Title nvarchar(255),
@Summary nvarchar(2000),
@ItemData nvarchar(2000),
@JournalXML xml,
@ObjectKey nvarchar(255),
@AccessKey uniqueidentifier,
@SecuritySet nvarchar(2000),
@CommentsDisabled bit,
@CommentsHidden bit
AS
INSERT INTO dbo.[dnn_Journal]
	(JournalTypeId, UserId, DateCreated, DateUpdated, PortalId, ProfileId, GroupId,Title,Summary, ObjectKey, AccessKey, ItemData, CommentsHidden, CommentsDisabled)
	VALUES
	(@JournalTypeId, @UserId, GETUTCDATE(), GETUTCDATE(), @PortalId, @ProfileId, @GroupId, @Title, @Summary, @ObjectKey, @AccessKey, @ItemData, @CommentsHidden, @CommentsDisabled)
SET @JournalId = SCOPE_IDENTITY()
BEGIN
INSERT INTO dbo.[dnn_Journal_Security]
	(JournalId, SecurityKey) 
	SELECT @JournalId, string from dbo.[dnn_Journal_SplitText](@SecuritySet,',')
END
IF @JournalXML IS NOT NULL
BEGIN
INSERT INTO dbo.[dnn_Journal_Data]
	(JournalId, JournalXML)
	VALUES
	(@JournalId, @JournalXML)
END
SELECT @JournalId

