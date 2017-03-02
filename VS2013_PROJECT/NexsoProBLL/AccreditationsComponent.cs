using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class AccreditationsComponent
    {
        private Accreditation acreditation;
        private MIFNEXSOEntities mifnexsoEntities;
         
        public Accreditation Accreditation
        {
            get { return acreditation; }
        }

        public AccreditationsComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            acreditation = new Accreditation();
            acreditation.AccreditationId = Guid.Empty;
            mifnexsoEntities.Accreditations.AddObject(acreditation);
        }

        public AccreditationsComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    acreditation = mifnexsoEntities.Accreditations.FirstOrDefault(a => a.AccreditationId == guid);
                }
                else
                {
                    acreditation = new Accreditation();
                    acreditation.AccreditationId = Guid.Empty;
                    mifnexsoEntities.Accreditations.AddObject(acreditation);
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
                mifnexsoEntities.DeleteObject(acreditation);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = acreditation.EntityState;
            if (acreditation.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(acreditation);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Accreditations.AddObject(acreditation);
                else
                    mifnexsoEntities.Accreditations.Attach(acreditation);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static List<Accreditation> GetAccreditationList()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Accreditations
                         select c;

            return result.ToList();
        }
        public static List<Accreditation> GetAccreditationId(Guid organization)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Accreditations
                         where c.OrganizationId == organization
                         select c;

            return result.ToList();
        }
    }
}
