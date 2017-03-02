using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;
namespace NexsoProBLL
{
    public class ChallengeComponent
    {
        private ChallengeSchema challenge;
        private MIFNEXSOEntities mifnexsoEntities;

        public ChallengeSchema Challenge
        {
            get { return challenge; }
        }

        public ChallengeComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            challenge = new ChallengeSchema();
            challenge.ChallengeReference = string.Empty;
            mifnexsoEntities.ChallengeSchemas.AddObject(challenge);
        }

        public ChallengeComponent(string challengeReference)
        {
            if (challengeReference != string.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challenge = mifnexsoEntities.ChallengeSchemas.FirstOrDefault(a => a.ChallengeReference == challengeReference);
                    if (challenge == null)
                    {
                        challenge = new ChallengeSchema();
                        challenge.ChallengeReference = string.Empty;
                        mifnexsoEntities.ChallengeSchemas.AddObject(challenge);
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
                mifnexsoEntities.DeleteObject(challenge);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = challenge.EntityState;
            if (challenge.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(challenge);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.ChallengeSchemas.AddObject(challenge);
                else
                    mifnexsoEntities.ChallengeSchemas.Attach(challenge);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static List<ChallengeSchema> GetChallenges()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.ChallengeSchemas

                         select c;

            return result.ToList();
        }

        public static IQueryable<ChallengeSchema> GetChallengesFront()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.ChallengeSchemas
                         where c.VisibilityFront == null || c.VisibilityFront == true
                         select c;

            return result;
        }

        public static IQueryable<ChallengeSchema> GetChallengesFront(string brand)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.ChallengeSchemas
                         where c.Brand == brand
                         select c;

            return result;
        }
    }
}
