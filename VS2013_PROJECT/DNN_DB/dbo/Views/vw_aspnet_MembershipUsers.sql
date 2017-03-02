
  CREATE VIEW [dbo].[vw_aspnet_MembershipUsers]
  AS SELECT members.[UserId],
            members.[PasswordFormat],
            members.[MobilePIN],
            members.[Email],
            members.[LoweredEmail],
            members.[PasswordQuestion],
            members.[PasswordAnswer],
            members.[IsApproved],
            members.[IsLockedOut],
            members.[CreateDate],
            members.[LastLoginDate],
            members.[LastPasswordChangedDate],
            members.[LastLockoutDate],
            members.[FailedPasswordAttemptCount],
            members.[FailedPasswordAttemptWindowStart],
            members.[FailedPasswordAnswerAttemptCount],
            members.[FailedPasswordAnswerAttemptWindowStart],
            members.[Comment],
            users.[ApplicationId],
            users.[UserName],
            users.[MobileAlias],
            users.[IsAnonymous],
            users.[LastActivityDate]
  FROM [dbo].[aspnet_Membership] members INNER JOIN [dbo].[aspnet_Users] users
      ON members.[UserId] = users.[UserId]
  

