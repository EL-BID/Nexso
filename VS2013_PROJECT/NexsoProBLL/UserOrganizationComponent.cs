
using System;
using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class UserOrganizationComponent
    {
        private UserOrganization userOrganization;
        private MIFNEXSOEntities mifnexsoEntities;


        public UserOrganization UserOrganization
        {
            get { return userOrganization; }
        }

        public UserOrganizationComponent(int userId, Guid organizationId, int role)
        {

            mifnexsoEntities = new MIFNEXSOEntities();

            userOrganization = mifnexsoEntities.UserOrganization.SingleOrDefault(a => a.UserID == userId & a.OrganizationID == organizationId);
            if (userOrganization == null)
            {
                userOrganization = new UserOrganization();
                userOrganization.OrganizationID = organizationId;
                userOrganization.UserID = userId;
                userOrganization.Role = role;
                mifnexsoEntities.UserOrganization.AddObject(userOrganization);
            }

        }

        public UserOrganizationComponent(int userId, Guid organizationId, int role, MIFNEXSOEntities mifnexsoEntities)
        {

            this.mifnexsoEntities = mifnexsoEntities;
            userOrganization = mifnexsoEntities.UserOrganization.First(a => a.UserID == userId & a.OrganizationID == organizationId);
            if (userOrganization == null)
            {
                userOrganization = new UserOrganization();
                userOrganization.OrganizationID = organizationId;
                userOrganization.UserID = userId;
                userOrganization.Role = role;
                mifnexsoEntities.UserOrganization.AddObject(userOrganization);
            }

        }

        public UserOrganizationComponent(int userId, Guid organizationId)
        {
            try
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                userOrganization =
                    mifnexsoEntities.UserOrganization.SingleOrDefault(a => a.UserID == userId & a.OrganizationID == organizationId);
                if (userOrganization == null)
                {
                    userOrganization = new UserOrganization();
                    userOrganization.OrganizationID = organizationId;
                    userOrganization.UserID = userId;
                    userOrganization.Role = -1;
                    mifnexsoEntities.UserOrganization.AddObject(userOrganization);
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
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }



        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = userOrganization.EntityState;
            if (userOrganization.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(userOrganization);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.UserOrganization.AddObject(userOrganization);
                else
                    mifnexsoEntities.UserOrganization.Attach(userOrganization);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(userOrganization);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {
                return -1;

            }
        }


        #region Static Methods

        public static IQueryable<UserOrganization> GetUserPerOrganization(Guid organizationID)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.UserOrganization

                         where c.OrganizationID == organizationID
                         select c;

            return result;



        }

        #endregion
    }
}
