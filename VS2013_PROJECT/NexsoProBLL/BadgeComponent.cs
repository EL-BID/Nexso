using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;


namespace NexsoProBLL
{
    public class BadgeComponent
    {
        private Badge badge;
        private MIFNEXSOEntities mifnexsoEntities;

        public Badge Badge
        {
            get { return badge; }
        }

        public BadgeComponent(Guid badgeId)
        {
            if (badgeId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    badge = mifnexsoEntities.Badges.FirstOrDefault(a => a.BadgeId == badgeId);


                    if (badge == null)
                    {
                        badge = new Badge();
                        badge.BadgeId = Guid.Empty;

                        mifnexsoEntities.Badges.AddObject(badge);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                badge = new Badge();
            }
        }
        
        public BadgeComponent(Guid solutionId, string type)
        {
            if (solutionId != Guid.Empty && !string.IsNullOrEmpty(type))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    badge = mifnexsoEntities.Badges.FirstOrDefault(a => a.SolutionId == solutionId && a.Type == type);


                    if (badge == null)
                    {
                        badge = new Badge();
                        badge.BadgeId = Guid.Empty;

                        mifnexsoEntities.Badges.AddObject(badge);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                badge = new Badge();
            }
        }

        public BadgeComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            badge = new Badge();
            badge.BadgeId = Guid.Empty;

            mifnexsoEntities.Badges.AddObject(badge);

        }

        public int Save()
        {
            try
            {
                if (badge.BadgeId == Guid.Empty)
                    badge.BadgeId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(badge);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = badge.EntityState;
            if (badge.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(badge);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Badges.AddObject(badge);
                else
                    mifnexsoEntities.Badges.Attach(badge);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


    }
}
