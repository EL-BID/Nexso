using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class PartnershipsComponent    
    {

        private Partnership partnership;
        private MIFNEXSOEntities mifnexsoEntities;
        //
        public Partnership Partnership
        {
            get { return partnership; }
        }

        public PartnershipsComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            partnership = new Partnership();
            partnership.OrganizationId = Guid.Empty;
            partnership.OrganizationPartnerId = Guid.Empty;
            mifnexsoEntities.Partnerships.AddObject(partnership);
        }

        public PartnershipsComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    partnership = mifnexsoEntities.Partnerships.FirstOrDefault(a => a.OrganizationId == guid);
                }
                else
                {
                    partnership.OrganizationId = Guid.Empty;
                    partnership.OrganizationPartnerId = Guid.Empty;
                    mifnexsoEntities.Partnerships.AddObject(partnership);
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

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(partnership);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = partnership.EntityState;
            if (partnership.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(partnership);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Partnerships.AddObject(partnership);
                else
                    mifnexsoEntities.Partnerships.Attach(partnership);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static List<Partnership> GetPartnershipList()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Partnerships
                         select c;

            return result.ToList();
        }
        public static List<string> GetPartnershipListLogo(Guid organization)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Partnerships
                         join o in mifnexsoEntities.Organizations
                         on c.OrganizationPartnerId equals o.OrganizationID
                         where c.OrganizationId == organization
                         select o.Logo;

            return result.ToList();
        }
    }
}
