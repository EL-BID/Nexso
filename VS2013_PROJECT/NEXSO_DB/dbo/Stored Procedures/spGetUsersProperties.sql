CREATE PROCEDURE [dbo].[spGetUsersProperties]
(
	@RowsPerPage		INT,
	@PageNumber			INT

)
AS 
SELECT	* 
		FROM (	SELECT ROW_NUMBER() OVER (ORDER BY USR.FirstName) AS RowNum,
		USR.UserId AS UUserId,
		USR.NexsoUserId AS UNexsoUserId,
		USR.Agreement AS UAgreement,
		USR.SkypeName AS USkypeName,
		USR.Twitter AS UTwitter,
		USR.FaceBook AS UFaceBook,
		USR.Google AS UGoogle,
		USR.LinkedIn AS ULinkedIn,
		USR.OtherSocialNetwork AS UOtherSocialNetwork,
		USR.City AS UCity,
		USR.Region AS URegion,
		USR.Country AS UCountry,
		USR.PostalCode AS UPostalCode,
		USR.Telephone AS UTelephone,
		USR.Address AS UAddress,	
		USR.LastName AS ULastName,		
		USR.FirstName AS UFirstName,
		USR.email AS UEmail,
		USR.CustomerType AS UCustomerType,
		USR.NexsoEnrolment AS UNexsoEnrolment,
		USR.AllowNexsoNotifications AS UAllowNexsoNotifications,
		USR.Language AS ULanguage,
		USR.Latitude AS ULatitude,
		USR.Longitude AS ULongitude,
		USR.GoogleLocation AS UGoogleLocation,
		USR.Bio AS UBio,
		USR.ProfilePicture AS UProfilePicture,
		USR.BannerPicture AS UBannerPicture
		
		FROM UserProperties AS USR ) AS SUSR
		WHERE SUSR.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		
	
		
