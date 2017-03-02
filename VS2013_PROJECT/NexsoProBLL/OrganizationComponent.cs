
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class OrganizationComponent
    {
        private Organization organization;
        private MIFNEXSOEntities mifnexsoEntities;


        public Organization Organization
        {
            get { return organization; }
        }

        public OrganizationComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            organization = new Organization();
            organization.OrganizationID = Guid.NewGuid();
            mifnexsoEntities.Organizations.AddObject(organization);
        }



        public OrganizationComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    organization = mifnexsoEntities.Organizations.FirstOrDefault(a => a.OrganizationID == guid);
                }
                else
                {
                    organization = new Organization();
                    organization.OrganizationID = Guid.Empty;
                    mifnexsoEntities.Organizations.AddObject(organization);
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
                if (organization.OrganizationID == Guid.Empty)
                    organization.OrganizationID = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(organization);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = organization.EntityState;
            if (organization.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(organization);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Organizations.AddObject(organization);
                else
                    mifnexsoEntities.Organizations.Attach(organization);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }



        public IQueryable<UserOrganization> GetMembersPerRol(int rol)
        {
            return mifnexsoEntities.UserOrganization.Where(a => a.Role == rol & a.OrganizationID == organization.OrganizationID);

        }

        public IQueryable<UserOrganization> GetMembers()
        {
            return mifnexsoEntities.UserOrganization.Where(a => a.OrganizationID == organization.OrganizationID);
        }

        #region Static Methods

        public static IQueryable<Organization> GetOrganizationsPerUser(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Organizations
                         join o in mifnexsoEntities.UserOrganization
                         on c.OrganizationID equals o.OrganizationID
                         where o.UserID == userId
                         select c;

            return result;



        }

        public static IQueryable<Organization> GetDraftOrganizationsPerUser(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = (from c in mifnexsoEntities.Organizations
                          join o in mifnexsoEntities.Solution
                          on c.OrganizationID equals o.OrganizationId
                          join z in mifnexsoEntities.UserOrganization
                          on o.OrganizationId equals z.OrganizationID
                          where z.UserID == userId && o.SolutionState < 1000
                          select c).Distinct();

            return result;



        }

        public static IQueryable<Organization> GetPublishedOrganizationsPerUser(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = (from c in mifnexsoEntities.Organizations
                          join o in mifnexsoEntities.Solution
                          on c.OrganizationID equals o.OrganizationId
                          join z in mifnexsoEntities.UserOrganization
                          on o.OrganizationId equals z.OrganizationID
                          where z.UserID == userId && o.SolutionState == 1000
                          select c).Distinct();

            return result;
        }

        public static IQueryable<Organization> GetOrganizations()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            return mifnexsoEntities.Organizations;

        }

        public static List<Organization> GetOrganizationPerId(Guid organization)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Organizations
                         where c.OrganizationID.Equals(organization)
                         select c;

            return result.ToList();
        }

        public static IQueryable<Organization> SearchOrganizationsByName(string name)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Organizations
                         where c.Name.Contains(name)
                         select c;

            return result;

        }

        public static IQueryable<OrganizationSolution> SearchOrganizationsSolutionsByName(string name)
        {


            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = (from c in mifnexsoEntities.Organizations
                          join o in mifnexsoEntities.Solution
                              on c.OrganizationID equals o.OrganizationId

                          where c.Name.Contains(name) && o.SolutionState == 1000
                          select new OrganizationSolution { Organization = c, Solution = o });

            return result;

        }

        public static IQueryable<OrganizationSolution> FilterOrganizations(string category, string key, string search)
        {


            var mifnexsoEntities = new MIFNEXSOEntities();
            switch (category)
            {
                case "ProjectDuration":
                    {


                        int durationT = -1;
                        try
                        {
                            durationT = Convert.ToInt32(new ListComponent(key, category).ListItem.Value);
                        }
                        catch
                        {


                        }
                        var result = (from c in mifnexsoEntities.Organizations
                                      join o in mifnexsoEntities.Solution
                                          on c.OrganizationID equals o.OrganizationId


                                      where c.Name.Contains(search) && o.SolutionState == 1000 && o.Duration.Value == durationT
                                      select new OrganizationSolution { Organization = c, Solution = o });

                        return result;
                    }
                case "Cost":
                    {
                        int costT = -1;
                        try
                        {
                            costT = Convert.ToInt32(new ListComponent(key, category).ListItem.Value);
                        }
                        catch
                        {


                        }


                        if (costT > 0)
                        {
                            var result = (from c in mifnexsoEntities.Organizations
                                          join o in mifnexsoEntities.Solution
                                              on c.OrganizationID equals o.OrganizationId


                                          where
                                              c.Name.Contains(search) && o.SolutionState == 1000 &&
                                              o.CostType.Value == costT

                                          select new OrganizationSolution { Organization = c, Solution = o });

                            return result;
                        }
                        return null;
                    }
                default:
                    {
                        var result = (from c in mifnexsoEntities.Organizations
                                      join o in mifnexsoEntities.Solution
                                          on c.OrganizationID equals o.OrganizationId
                                      join s in mifnexsoEntities.SolutionLists
                                      on o.SolutionId equals s.SolutionId

                                      where c.Name.Contains(search) && o.SolutionState == 1000 && s.Category == category && s.Key == key
                                      select new OrganizationSolution { Organization = c, Solution = o });

                        return result;
                    }
            }




        }

        public static IQueryable<UserPropertyOrganizationSolution> SearchUserPropertyOrganizationsSolutionsByName(string name)
        {


            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = (from organization in mifnexsoEntities.Organizations
                          join solution in mifnexsoEntities.Solution
                          on organization.OrganizationID equals solution.OrganizationId
                          join userProperty in mifnexsoEntities.UserProperties
                          on solution.CreatedUserId equals userProperty.UserId

                          where organization.Name.Contains(name)
                          select new UserPropertyOrganizationSolution { Organization = organization, Solution = solution, UserProperty = userProperty });

            return result;

        }
        #endregion

    }
}
