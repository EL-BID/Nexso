
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class SolutionComponent
    {
        private Solution solution;
        private MIFNEXSOEntities mifnexsoEntities;

        public Solution Solution
        {
            get { return solution; }
        }

        public SolutionComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            solution = new Solution();
            solution.OrganizationId = Guid.Empty;
            solution.SolutionId = Guid.NewGuid();
            mifnexsoEntities.Solution.AddObject(solution);
        }

        public SolutionComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    solution = mifnexsoEntities.Solution.FirstOrDefault(a => a.SolutionId == guid);
                }
                else
                {
                    solution = new Solution();
                    solution.SolutionId = Guid.Empty;
                    solution.OrganizationId = Guid.Empty;
                    mifnexsoEntities.Solution.AddObject(solution);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        public int Save()
        {
            try
            {
                if (solution.SolutionId == Guid.Empty)
                    solution.SolutionId = Guid.NewGuid();
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }


        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(solution);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = solution.EntityState;
            if (solution.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(solution);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Solution.AddObject(solution);
                else
                    mifnexsoEntities.Solution.Attach(solution);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region Static Methods

        public static IQueryable<Solution> GetSolutionPerOrganization(Guid organizationId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution
                         join o in mifnexsoEntities.Organizations
                         on c.OrganizationId equals o.OrganizationID
                         where o.OrganizationID == organizationId && c.SolutionState == 1000
                         select c;

            return result;
        }

        public static List<SolutionOrganizationView> GetSolutions(string search, int state, int minScore)
        {

            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = mifnexsoEntities.ExecuteStoreQuery<SolutionOrganizationView>("SELECT     dbo.Solution.SolutionId AS SSolutionId, dbo.Solution.SolutionTypeId AS SSolutionTypeId, " +
                                                                                      " dbo.Solution.Title AS STitle, dbo.Solution.TagLine AS STagLine,  " +
                  "     dbo.Solution.Description AS SDescription, dbo.Solution.Biography AS SBiography, dbo.Solution.Challenge AS SChallenge, dbo.Solution.Approach AS SApproach,  " +
                    "    dbo.Solution.Results AS SResults, dbo.Solution.ImplementationDetails AS SImplementationDetails, dbo.Solution.AdditionalCost AS SAdditionalCost,  " +
                    "    dbo.Solution.AvailableResources AS SAvailableResources, dbo.Solution.TimeFrame AS STimeFrame, dbo.Solution.Duration AS SDuration,  " +
                    "    dbo.Solution.DurationDetails AS SDurationDetails, dbo.Solution.SolutionStatusId AS SSolutionStatusId, dbo.Solution.SolutionType AS SSolutionType,  " +
                     "   dbo.Solution.Topic AS STopic, dbo.Solution.Language AS SLanguage, dbo.Solution.CreatedUserId AS SCreatedUserId, dbo.Solution.Deleted AS SDeleted,  " +
                    "    dbo.Solution.Country AS SCountry, dbo.Solution.Region AS SRegion, dbo.Solution.City AS SCity, dbo.Solution.Address AS SAddress,  " +
                    "    dbo.Solution.ZipCode AS SZipCode, dbo.Solution.Logo AS SLogo, dbo.Solution.Cost1 AS SCost1, dbo.Solution.Cost2 AS SCost2, dbo.Solution.Cost3 AS SCost3,  " +
                   "     dbo.Solution.DeliveryFormat AS SDeliveryFormat, dbo.Solution.Cost AS SCost, dbo.Solution.CostType AS SCostType, dbo.Solution.CostDetails AS SCostDetails,  " +
                   "     dbo.Solution.SolutionState AS SSolutionState, dbo.Solution.Beneficiaries AS SBeneficiaries, dbo.Solution.DateCreated AS SDateCreated,  " +
                 "       dbo.Solution.DateUpdated AS SDateUpdated, dbo.Solution.ChallengeReference AS SChallengeReference, dbo.Organization.OrganizationID AS OOrganizationID,  " +
                 "       dbo.Organization.Code AS OCode, dbo.Organization.Name AS OName, dbo.Organization.Address AS OAddress, dbo.Organization.Phone AS OPhone,  " +
                  "      dbo.Organization.Email AS OEmail, dbo.Organization.ContactEmail AS OContactEmail, dbo.Organization.Website AS OWebsite, dbo.Organization.Twitter AS OTwitter,  " +
                  "      dbo.Organization.Skype AS OSkype, dbo.Organization.Facebook AS OFacebook, dbo.Organization.GooglePlus AS OGooglePlus,  " +
                   "     dbo.Organization.LinkedIn AS OLinkedIn, dbo.Organization.Description AS ODescription, dbo.Organization.Logo AS OLogo, dbo.Organization.Country AS OCountry,  " +
                   "     dbo.Organization.Region AS ORegion, dbo.Organization.ZipCode AS OZipCode, dbo.Organization.City AS OCity, dbo.Organization.Created AS OCreated,  " +
                    "    dbo.Organization.Updated AS OUpdated, dbo.Organization.Latitude AS OLatitude, dbo.Organization.Longitude AS OLongitude,  " +
                    "    dbo.Organization.GoogleLocation AS OGoogleLocation " +
                    "      FROM         dbo.Solution INNER JOIN " +
                    "    dbo.Organization ON dbo.Solution.OrganizationId = dbo.Organization.OrganizationID where dbo.GetScore(Solution.SolutionId,'JUDGE')>" + minScore.ToString() + " and Solution.SolutionState=" + state.ToString() +
                    " order by dbo.GetScore(Solution.SolutionId,'JUDGE') desc"
                    ).ToList();

            return result;




        }

        public static IQueryable<Solution> GetDraftSolutionPerOrganization(Guid organizationId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution
                         join o in mifnexsoEntities.Organizations
                         on c.OrganizationId equals o.OrganizationID
                         where o.OrganizationID == organizationId && c.SolutionState < 1000
                         select c;

            return result;



        }

        public static IQueryable<Solution> GetSolutionPerUser(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution
                         join o in mifnexsoEntities.Organizations
                             on c.OrganizationId equals o.OrganizationID
                         join z in mifnexsoEntities.UserOrganization
                             on o.OrganizationID equals z.OrganizationID
                         where z.UserID == userId & c.SolutionState == 1000

                         select c;

            return result;



        }

        public static IQueryable<Solution> GetDraftSolutionPerUser(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution
                         join o in mifnexsoEntities.Organizations
                             on c.OrganizationId equals o.OrganizationID
                         join z in mifnexsoEntities.UserOrganization
                             on o.OrganizationID equals z.OrganizationID
                         where z.UserID == userId & c.SolutionState < 1000

                         select c;

            return result;



        }
        public static IQueryable<Solution> GetAllSolutionPerUser(int userId)
        {


            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution

                         where c.CreatedUserId == userId

                         select c;

            return result;



        }

        public static List<string> GetSolutionChallenges()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = mifnexsoEntities.ExecuteStoreQuery<string>("select challengereference from solution where challengereference is not null group by challengereference ").ToList();

            return result;
        }

        public static IQueryable<Solution> GetAllSolutionPerChallenge(string challenge)
        {


            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution

                         where c.ChallengeReference == challenge
                         select c;

            return result;

        }

        public static IQueryable<Solution> GetPublishSolutionPerChallenge(string challenge)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution
                         where c.ChallengeReference == challenge & c.SolutionState > 800
                         select c;
            return result;
        }

        public static IQueryable<Solution> GetSolutionStatistics()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Solution
                          where c.SolutionState >= 800 &&( c.Deleted == false || c.Deleted == null)
                          select c;
            return result;
        }


        #endregion
    }
}
