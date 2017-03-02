using System;

using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class UserPropertyComponent
    {
        private UserProperty userProperty;
        private MIFNEXSOEntities mifnexsoEntities;

        public UserProperty UserProperty
        {
            get { return userProperty; }
        }







        public UserPropertyComponent(int UserId)
        {
            if (UserId >= 0)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    userProperty = mifnexsoEntities.UserProperties.FirstOrDefault(a => a.UserId == UserId);
                    if (userProperty == null)
                    {
                        userProperty = new UserProperty();
                        userProperty.UserId = UserId;
                        mifnexsoEntities.UserProperties.AddObject(userProperty);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }
        public int Save()
        {
            try
            {
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
                mifnexsoEntities.DeleteObject(userProperty);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {
                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = userProperty.EntityState;
            if (userProperty.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(userProperty);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.UserProperties.AddObject(userProperty);
                else
                    mifnexsoEntities.UserProperties.Attach(userProperty);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<SolutionLocation> GetSolutionLocationsPerSolution(Guid solutionId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionLocations

                         where c.SolutionId == solutionId
                         select c;

            return result;
        }

        public static IQueryable<UserProperty> GetUsersStatistics()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.UserProperties
                         where c.Agreement != "VOID" || string.IsNullOrEmpty(c.Agreement)
                         select c;

            return result;
        }
    }
}
