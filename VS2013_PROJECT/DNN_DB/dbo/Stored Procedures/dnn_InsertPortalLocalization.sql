CREATE PROCEDURE [dbo].[dnn_InsertPortalLocalization]
@PortalID           int,
@CultureCode nvarchar(10),
	@PortalName         nvarchar(128),
	@LogoFile           nvarchar(50),
	@FooterText         nvarchar(100),
	@Description        nvarchar(500),
	@KeyWords           nvarchar(500),
	@BackgroundFile     nvarchar(50),
	@HomeTabId          int,
	@LoginTabId         int,
	@UserTabId          int,
	@AdminTabid			int,
	@SplashTabId          int,
@CreatedByUserID  int
AS
INSERT INTO dbo.[dnn_PortalLocalization]
           ([PortalID]
           ,[CultureCode]
           ,[PortalName]
           ,[LogoFile]
           ,[FooterText]
           ,[Description]
           ,[KeyWords]
           ,[BackgroundFile]
           ,[HomeTabId]
           ,[LoginTabId]
           ,[UserTabId]
           ,[AdminTabId]
           ,[SplashTabId]
           ,[CreatedByUserID]
           ,[CreatedOnDate]
           ,[LastModifiedByUserID]
           ,[LastModifiedOnDate])
     VALUES
     (
     @PortalID,
     @CultureCode,
     @PortalName,
	@LogoFile, 
	@FooterText,
	@Description,
	@KeyWords,
	@BackgroundFile,
	@HomeTabId ,
	@LoginTabId ,
	@UserTabId,
	@AdminTabid,
	@SplashTabId  ,
-1,
		getdate(),
		-1,
		getdate()
		)

