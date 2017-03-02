using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
   public  class DocumentComponent
    {
        private Document document;
        private MIFNEXSOEntities mifnexsoEntities;

        public Document Document
        {
            get { return document; }
        }

        public DocumentComponent(Guid documentId)
        {
            if (documentId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    document = mifnexsoEntities.Documents.FirstOrDefault(a => a.DocumentId == documentId);


                    if (document == null)
                    {
                        document = new Document();
                        document.DocumentId = Guid.Empty;

                        mifnexsoEntities.Documents.AddObject(document);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                document = new Document();
            }
        }

        public int Save()
        {
            try
            {
                if (document.DocumentId == Guid.Empty)
                    document.DocumentId = Guid.NewGuid();
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                throw; 
                //return -1;
            }


        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(document);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = document.EntityState;
            if (document.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(document);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Documents.AddObject(document);
                else
                    mifnexsoEntities.Documents.Attach(document);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region

        public static List<Document> GetDocuments(Guid solutionId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Documents
                         where c.ExternalReference==solutionId
                         

                         select c;

            return result.ToList();
        }

        public static List<Document> GetDocuments(Guid solutionId, string category, string folder)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Documents
                         where c.ExternalReference==solutionId&&c.Category==category && c.Folder==folder


                         select c;

            return result.ToList();
        }
        #endregion
    }
}
