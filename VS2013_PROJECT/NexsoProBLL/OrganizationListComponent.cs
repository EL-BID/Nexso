using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NexsoProDAL;
using System.Data;

namespace NexsoProBLL
{
    class OrganizationListComponent
    {
        private OrganizationList organizationList;
        private MIFNEXSOEntities mifnexsoEntities;

        public OrganizationList OrganizationList
        {
            get { return organizationList; }
        }

        public OrganizationListComponent(Guid organizationId, string key, string category)
        {


            if (!string.IsNullOrEmpty(key))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    organizationList = mifnexsoEntities.OrganizationLists.FirstOrDefault(a => a.OrganizationId == organizationId && a.Key == key && a.Category == category);


                    if (organizationList == null)
                    {
                        organizationList = new OrganizationList();
                        organizationList.ListId = Guid.NewGuid();
                        organizationList.Key = key;
                        organizationList.OrganizationId = organizationId;
                        organizationList.Category = category;

                        mifnexsoEntities.OrganizationLists.AddObject(organizationList);
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
                mifnexsoEntities.DeleteObject(organizationList);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = organizationList.EntityState;
            if (organizationList.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(organizationList);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.OrganizationLists.AddObject(organizationList);
                else
                    mifnexsoEntities.OrganizationLists.Attach(organizationList);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<OrganizationList> GetListPerCategory(Guid organizationId, string category)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.OrganizationLists

                         where c.OrganizationId == organizationId && c.Category == category
                         select c;

            return result;



        }

        public static IQueryable<OrganizationList> GetListPerCategory(string category, string key)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.OrganizationLists

                         where c.Category == category && c.Key == key
                         select c;

            return result;
        }
    }
}
