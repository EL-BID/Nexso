using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class AttributesComponent    
    {
      
        private NexsoProDAL.Atrributes attributes;
        private MIFNEXSOEntities mifnexsoEntities;
         
        public NexsoProDAL.Atrributes Attributes
        {
            get { return attributes; }
        }

        public AttributesComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            attributes = new Atrributes();
            attributes.AttributeID = Guid.Empty;
            attributes.OrganizationID = Guid.Empty;
            attributes.Type = string.Empty;
            attributes.Value = string.Empty;
            attributes.ValueType = string.Empty;
            attributes.Description = string.Empty;
            attributes.Label = string.Empty;
            mifnexsoEntities.Atrributes.AddObject(attributes);
        }

        public AttributesComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    attributes = mifnexsoEntities.Atrributes.FirstOrDefault(a => a.AttributeID == guid);
                }
                else
                {
                    attributes = new Atrributes();
                    attributes.AttributeID = Guid.Empty;
                    attributes.OrganizationID = Guid.Empty;
                    attributes.Type = string.Empty;
                    attributes.Value = string.Empty;
                    attributes.ValueType = string.Empty;
                    attributes.Description = string.Empty;
                    attributes.Label = string.Empty;
                    mifnexsoEntities.Atrributes.AddObject(attributes);
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
                mifnexsoEntities.DeleteObject(attributes);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = attributes.EntityState;
            if (attributes.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(attributes);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Atrributes.AddObject(attributes);
                else
                    mifnexsoEntities.Atrributes.Attach(attributes);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static List<NexsoProDAL.Atrributes> GetAttributesList()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Atrributes
                         select c;

            return result.ToList();
        }
        public static List<NexsoProDAL.Atrributes> GetAttributesList(Guid organization)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Atrributes
                         where c.OrganizationID == organization
                         select c;

            return result.ToList();
        }
    }
}
