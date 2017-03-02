using System;

using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class SolutionLocationComponent
    {
        private SolutionLocation solutionLocation;
        private MIFNEXSOEntities mifnexsoEntities;

        public SolutionLocation SolutionLocation
        {
            get { return solutionLocation; }
        }





        public SolutionLocationComponent(Guid solutionId, string country, string region, string city, string postalCode,string address, decimal latitude,decimal longitude)
        {
            if (solutionId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    solutionLocation = mifnexsoEntities.SolutionLocations.FirstOrDefault(a => a.SolutionId == solutionId && a.Country == country
                        && a.Region == region && a.City == city);
                    if (solutionLocation == null)
                    {
                        solutionLocation = new SolutionLocation();
                        solutionLocation.SolutionLocationId = Guid.Empty;
                        solutionLocation.SolutionId = solutionId;
                        solutionLocation.Country = country;
                        solutionLocation.City = city;
                        solutionLocation.Region = region;
                        solutionLocation.Address = address;
                        solutionLocation.PostalCode = postalCode;
                        solutionLocation.Longitude = longitude;
                        solutionLocation.Latitude = latitude;
                        mifnexsoEntities.SolutionLocations.AddObject(solutionLocation);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }

        public SolutionLocationComponent(Guid solutionId, string country, string region, string city)
        {
            if (solutionId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    solutionLocation = mifnexsoEntities.SolutionLocations.FirstOrDefault(a => a.SolutionId == solutionId && a.Country == country
                        && a.Region == region && a.City == city);
                    if (solutionLocation == null)
                    {
                        solutionLocation = new SolutionLocation();
                        solutionLocation.SolutionLocationId = Guid.Empty;
                        solutionLocation.SolutionId = solutionId;
                        solutionLocation.Country = country;
                        solutionLocation.City = city;
                        solutionLocation.Region = region;
                        solutionLocation.Address = string.Empty;
                        solutionLocation.PostalCode = string.Empty;
                        solutionLocation.Longitude = -1;
                        solutionLocation.Latitude = -1;
                        mifnexsoEntities.SolutionLocations.AddObject(solutionLocation);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }

        public SolutionLocationComponent(Guid SolutionLocationId)
        {
            if (SolutionLocationId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    solutionLocation = mifnexsoEntities.SolutionLocations.FirstOrDefault(a => a.SolutionLocationId == SolutionLocationId);
                    if (solutionLocation == null)
                    {
                        solutionLocation = new SolutionLocation();
                        solutionLocation.SolutionLocationId = Guid.Empty;
                        mifnexsoEntities.SolutionLocations.AddObject(solutionLocation);
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
                if (solutionLocation.SolutionLocationId == Guid.Empty)
                    solutionLocation.SolutionLocationId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(solutionLocation);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = solutionLocation.EntityState;
            if (solutionLocation.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(solutionLocation);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.SolutionLocations.AddObject(solutionLocation);
                else
                    mifnexsoEntities.SolutionLocations.Attach(solutionLocation);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<SolutionLocation> GetSolutionLocationsPerSolution(Guid solutionId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionLocations

                         where c.SolutionId == solutionId
                         select c;

            return result;
        }

        public static bool DeleteSolutionLocationsPerSolution(Guid solutionId)
        {
            try
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                int results = mifnexsoEntities.ExecuteStoreCommand(
                     string.Format("DELETE SOLUTIONLOCATIONS WHERE SolutionId='{0}'", solutionId.ToString()));
                return true;
            }
            catch (Exception)
            {
                return false;
            }




        }
       
    }
}
