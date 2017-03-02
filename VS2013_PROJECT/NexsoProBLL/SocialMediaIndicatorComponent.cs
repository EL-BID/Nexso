using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class SocialMediaIndicatorComponent
    {

       

         private SocialMediaIndicator socialMediaIndicator;
        private MIFNEXSOEntities mifnexsoEntities;

        public SocialMediaIndicator SocialMediaIndicator
        {
            get { return socialMediaIndicator; }
        }


        public SocialMediaIndicatorComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            socialMediaIndicator = new SocialMediaIndicator();
            socialMediaIndicator.SocialMediaIndicatorId = Guid.Empty;

            mifnexsoEntities.SocialMediaIndicators.AddObject(socialMediaIndicator);
        }
        
         public SocialMediaIndicatorComponent(Guid guid)
         {
             mifnexsoEntities = new MIFNEXSOEntities();
             try
             {
                 if (guid != Guid.Empty)
                 {
                     socialMediaIndicator = mifnexsoEntities.SocialMediaIndicators.FirstOrDefault(a => a.SocialMediaIndicatorId == guid);
                     if (socialMediaIndicator == null)
                     {

                         mifnexsoEntities = new MIFNEXSOEntities();
                         socialMediaIndicator = new SocialMediaIndicator();
                         socialMediaIndicator.SocialMediaIndicatorId = Guid.Empty;
                         mifnexsoEntities.SocialMediaIndicators.AddObject(socialMediaIndicator);
                     }
                 }
             }
             catch (Exception)
             {
                 throw;
             }
         }

         public SocialMediaIndicatorComponent(Guid objectRelated,string objectType, string indicatorType, int? userId)
         {
             mifnexsoEntities = new MIFNEXSOEntities();
             try
             {
                 if (objectRelated != Guid.Empty )
                 {
                     if (userId != null)
                     {
                         socialMediaIndicator = mifnexsoEntities.SocialMediaIndicators.FirstOrDefault(
                             a => a.ObjectId == objectRelated && a.ObjectType == objectType
                                 && a.IndicatorType == indicatorType && a.UserId == userId);
                     }
                     

                     if (socialMediaIndicator == null)
                     {
                         mifnexsoEntities = new MIFNEXSOEntities();
                         socialMediaIndicator = new SocialMediaIndicator();
                         socialMediaIndicator.SocialMediaIndicatorId = Guid.Empty;
                         socialMediaIndicator.ObjectId = objectRelated;
                         socialMediaIndicator.UserId = userId;
                         socialMediaIndicator.ObjectType=objectType;
                         socialMediaIndicator.IndicatorType = indicatorType;
                         mifnexsoEntities.SocialMediaIndicators.AddObject(socialMediaIndicator);
                     }
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
                if (socialMediaIndicator.SocialMediaIndicatorId == Guid.Empty)
                    socialMediaIndicator.SocialMediaIndicatorId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(socialMediaIndicator);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = socialMediaIndicator.EntityState;
            if (socialMediaIndicator.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(socialMediaIndicator);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.SocialMediaIndicators.AddObject(socialMediaIndicator);
                else
                    mifnexsoEntities.SocialMediaIndicators.Attach(socialMediaIndicator);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<SocialMediaIndicator> GetSocialMediaIndicatorPerObjectRelated(Guid objectRelated)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SocialMediaIndicators

                         where c.ObjectId == objectRelated && c.UserId !=null
                         orderby c.Created
                         select c;




            return result;



        }


        public static IQueryable<SocialMediaIndicator> GetSocialMediaIndicatorPerUser(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SocialMediaIndicators

                         where c.UserId == userId
                         orderby c.Created
                         select c;




            return result;



        }


        public static decimal GetAggregatorSocialMediaIndicatorPerObjectRelated(Guid objectRelated, string objecType, string indicatorType, string agregator)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
           
            var result_ = (from c in mifnexsoEntities.SocialMediaIndicators

                          where c.ObjectId == objectRelated && c.ObjectType==objecType && c.IndicatorType==indicatorType 
                          select c);
            
            if(result_!=null)
            {
                if (result_.Count() > 0)
                {
                    switch (agregator)
                    {
                        case "SUM":
                            return result_.Sum(a => a.Value);
                        case "AVG":
                            return result_.Average(a => a.Value);
                        case "COUNT":
                            return result_.Count();

                    }

                    
                }
            }
           




            return 0;



        }

    }
}
