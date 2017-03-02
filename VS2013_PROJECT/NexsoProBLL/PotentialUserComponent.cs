using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class PotentialUserComponent
    {

         private PotentialUser potentialUser;
        private MIFNEXSOEntities mifnexsoEntities;

        public PotentialUser PotentialUser
        {
            get { return potentialUser; }
        }

        public PotentialUserComponent(Guid potentialUserId)
        {
            if (potentialUserId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    potentialUser = mifnexsoEntities.PotentialUsers.FirstOrDefault(a => a.PotentialUserId == potentialUserId);


                    if (potentialUser == null)
                    {
                        potentialUser = new PotentialUser();
                        potentialUser.PotentialUserId = Guid.Empty;

                        mifnexsoEntities.PotentialUsers.AddObject(potentialUser);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                potentialUser = new PotentialUser();
            }
        }


        public PotentialUserComponent(string email)
        {
            if (!string.IsNullOrEmpty(email))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    potentialUser = mifnexsoEntities.PotentialUsers.FirstOrDefault(a => a.Email == email && (a.Deleted==false || a.Deleted==null));


                    if (potentialUser == null)
                    {
                        potentialUser = new PotentialUser();
                        potentialUser.Email = email;
                        potentialUser.PotentialUserId = Guid.Empty;

                        mifnexsoEntities.PotentialUsers.AddObject(potentialUser);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                potentialUser = new PotentialUser();
            }
        }

        public PotentialUserComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            potentialUser = new PotentialUser();
            potentialUser.PotentialUserId = Guid.Empty;

            mifnexsoEntities.PotentialUsers.AddObject(potentialUser);

        }

        public int Save()
        {
            try
            {
                if (potentialUser.PotentialUserId == Guid.Empty)
                    potentialUser.PotentialUserId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(potentialUser);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = potentialUser.EntityState;
            if (potentialUser.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(potentialUser);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.PotentialUsers.AddObject(potentialUser);
                else
                    mifnexsoEntities.PotentialUsers.Attach(potentialUser);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        public static List<PotentialUser> GetPotentialUsers()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.PotentialUsers

                          select c;

            return result.ToList();



        }

        public static List<string> GetPotentialUserSources()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = mifnexsoEntities.ExecuteStoreQuery<string>("select source from potentialUsers where source is not null group by source").ToList();

            return result;
        }
    }
}
