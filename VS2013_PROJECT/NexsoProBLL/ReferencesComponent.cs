using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class ReferencesComponent
    {
        private Reference reference;
        private MIFNEXSOEntities mifnexsoEntities;

        public Reference Reference
        {
            get { return reference; }
        }

        public ReferencesComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            reference = new Reference();
            reference.ReferenceId = Guid.Empty;
            mifnexsoEntities.References.AddObject(reference);
        }

        public ReferencesComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    reference = mifnexsoEntities.References.FirstOrDefault(a => a.ReferenceId == guid);
                }
                else
                {
                    reference = new Reference();
                    reference.ReferenceId = Guid.Empty;
                    mifnexsoEntities.References.AddObject(reference);
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
                mifnexsoEntities.DeleteObject(reference);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = reference.EntityState;
            if (reference.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(reference);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.References.AddObject(reference);
                else
                    mifnexsoEntities.References.Attach(reference);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static List<Reference> GetList()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.References 
                         where (c.Deleted != true || c.Deleted == null)
                         select c;

            return result.ToList();
        }

        public static List<Reference> GetReferences(Guid organization)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.References
                         where (c.OrganizationId == organization) && (c.Deleted != true || c.Deleted == null)
                         select c;

            return result.ToList();
        }
    }
}
