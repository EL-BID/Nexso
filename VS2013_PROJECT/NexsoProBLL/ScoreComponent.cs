using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class ScoreComponent
    {
        private Score score;
        private MIFNEXSOEntities mifnexsoEntities;

        public Score Score
        {
            get { return score; }
        }

        public ScoreComponent()
        {

        }

        /// <summary>
        /// Is the absolute value of the score
        /// </summary>
        public double AbsoluteScore
        {
            get { return 0; }
        }

        /// <summary>
        /// is compared as global value
        /// </summary>
        public double RelativeScore
        {
            get { return 0; }
        }

        protected ScoreComponent(Guid SolutionId)
        {

            //if (SolutionId != Guid.Empty && userId > 0 && scoreType != string.Empty)
            //{
            //    mifnexsoEntities = new MIFNEXSOEntities();
            //    try
            //    {


            //        score = mifnexsoEntities.Scores.FirstOrDefault(a => a.SolutionId == SolutionId && a.UserId == userId && a.ScoreType == scoreType);


            //        if (score == null)
            //        {
            //            score = new Score();
            //            score.UserId = userId;
            //            score.SolutionId = SolutionId;
            //            score.ScoreType = scoreType;
            //            score.ScoreId = Guid.Empty;

            //            mifnexsoEntities.Scores.AddObject(score);
            //        }

            //    }
            //    catch (Exception)
            //    {
            //        throw;
            //    }
            //}


        }

        protected ScoreComponent(Guid SolutionId, int userId, string scoreType)
        {

            if (SolutionId != Guid.Empty && userId > 0 && scoreType != string.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    score =
                        mifnexsoEntities.Scores.FirstOrDefault(
                            a => a.SolutionId == SolutionId && a.UserId == userId && a.ScoreType == scoreType && a.Active == true);


                    if (score == null)
                    {
                        score = new Score();
                        score.UserId = userId;
                        score.SolutionId = SolutionId;
                        score.ScoreType = scoreType;
                        score.ScoreId = Guid.Empty;

                        mifnexsoEntities.Scores.AddObject(score);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }


        }



        public ScoreComponent(Guid SolutionId, int userId, string scoreType, string challengeReference)
        {

            if (SolutionId != Guid.Empty && userId > 0 && scoreType != string.Empty && challengeReference != null)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    score = mifnexsoEntities.Scores.FirstOrDefault(
                            a => a.SolutionId == SolutionId && a.UserId == userId && a.ScoreType == scoreType && a.ChallengeReference == challengeReference && a.Active == true);


                    if (score == null)
                    {
                        score = new Score();
                        score.UserId = userId;
                        score.SolutionId = SolutionId;
                        score.ScoreType = scoreType;
                        score.ScoreId = Guid.Empty;

                        mifnexsoEntities.Scores.AddObject(score);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }


        }

        public int Save(string challengeReference)
        {
            try
            {
                if (score.ScoreId == Guid.Empty)
                {
                    score.Created = DateTime.Now;
                    score.Updated = score.Created;
                    score.ScoreId = Guid.NewGuid();
                }
                else
                {
                    score.Updated = DateTime.Now;
                }
                score.ComputedValue = 0;
                for (int i = 0; i < score.ScoreValues.Count; i++)
                {
                    var scoreItem = score.ScoreValues.ElementAt(i);
                    if (scoreItem.ScoreValueId == Guid.Empty)
                    {
                        scoreItem.ScoreValueId = Guid.NewGuid();
                        scoreItem.Created = score.Updated;
                        scoreItem.Updated = score.Updated;
                    }
                    else
                    {
                        scoreItem.Updated = score.Updated;
                    }
                    score.ComputedValue = score.ComputedValue + scoreItem.value * scoreItem.ScoreType.Weight;
                }

                score.Active = true;
                score.ChallengeReference = challengeReference;

                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }
        public int Save(Guid scoreId)
        {
            try
            {
                if (score.ScoreId == Guid.Empty)
                {
                    score.ScoreId = scoreId;
                }

                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }
        }

        public int Save()
        {
            try
            {
                if (score.ScoreId == Guid.Empty)
                {
                    score.Created = DateTime.Now;
                    score.Updated = score.Created;
                    score.ScoreId = Guid.NewGuid();
                }
                else
                {
                    score.Updated = DateTime.Now;
                }
                score.ComputedValue = 0;
                for (int i = 0; i < score.ScoreValues.Count; i++)
                {
                    var scoreItem = score.ScoreValues.ElementAt(i);
                    if (scoreItem.ScoreValueId == Guid.Empty)
                    {
                        scoreItem.ScoreValueId = Guid.NewGuid();
                        scoreItem.Created = score.Updated;
                        scoreItem.Updated = score.Updated;
                    }
                    else
                    {
                        scoreItem.Updated = score.Updated;
                    }
                    score.ComputedValue = score.ComputedValue + scoreItem.value * scoreItem.ScoreType.Weight;
                }
                score.Active = true;



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
                mifnexsoEntities.DeleteObject(score);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = score.EntityState;
            if (score.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(score);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Scores.AddObject(score);
                else
                    mifnexsoEntities.Scores.Attach(score);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        public class ScoreJudge
        {
            #region private variables

            private ScoreComponent scoreComponent;

            private ScoreValue nameScore;
            private ScoreValue tagLineScore;


            private ScoreValue resultScoreMarketingDescription;
            private ScoreValue resultScoreAdopter;
            private ScoreValue resultScoreEvidence;
            private ScoreValue resultScoreReplication;
            private ScoreValue resultScoreBeneficiary;

            private ScoreValue innovationScoreInnovation;
            private ScoreValue innovationScoreMethodology;
            private ScoreValue innovationScoreChallenge;
            private ScoreValue innovationScoreRealizable;
            private ScoreValue innovationScoreReplicable;

            private ScoreValue challengeScoreCurrentSituation;
            private ScoreValue challengeScoreSpecificProblem;
            private ScoreValue challengeScoreCause;
            private ScoreValue challengeScoreDimension;
            private ScoreValue challengeScoreBeneficiaries;

            private ScoreValue implementationCostScore;
            private ScoreValue implementationTimeScore;
            private ScoreValue implementationScore;
            private ScoreValue additionalInformationScore;
            private ScoreValue themeScore;
            private ScoreValue beneficiariesScore;
            private ScoreValue deliveryFormatScore;
            private ScoreValue timeScore;
            private ScoreValue costScore;
            private ScoreValue availableResourcesScore;

            #endregion

            #region properties

            public double NameScore
            {
                get
                {
                    if (nameScore == null)
                    {
                        nameScore = GetScoreValueByScoreValueType("JUDGE_NameScore");

                    }
                    return nameScore.value;


                }
                set
                {
                    if (nameScore == null)
                    {
                        nameScore = GetScoreValueByScoreValueType("JUDGE_NameScore");

                    }

                    nameScore.value = value;



                }
            }

            public double TagLineScore
            {
                get
                {
                    if (tagLineScore == null)
                    {
                        tagLineScore = GetScoreValueByScoreValueType("JUDGE_TagLineScore");

                    }
                    return tagLineScore.value;


                }
                set
                {
                    if (tagLineScore == null)
                    {
                        tagLineScore = GetScoreValueByScoreValueType("JUDGE_TagLineScore");

                    }

                    tagLineScore.value = value;



                }
            }

            public double ImplementationCostScore
            {
                get
                {
                    if (implementationCostScore == null)
                    {
                        implementationCostScore = GetScoreValueByScoreValueType("JUDGE_ImplementationCostScore");

                    }
                    return implementationCostScore.value;


                }
                set
                {
                    if (implementationCostScore == null)
                    {
                        implementationCostScore = GetScoreValueByScoreValueType("JUDGE_ImplementationCostScore");

                    }

                    implementationCostScore.value = value;



                }
            }

            public double ImplementationTimeScore
            {
                get
                {
                    if (implementationTimeScore == null)
                    {
                        implementationTimeScore = GetScoreValueByScoreValueType("JUDGE_ImplementationTimeScore");

                    }
                    return implementationTimeScore.value;


                }
                set
                {
                    if (implementationTimeScore == null)
                    {
                        implementationTimeScore = GetScoreValueByScoreValueType("JUDGE_ImplementationTimeScore");

                    }

                    implementationTimeScore.value = value;



                }
            }

            public double ImplementationScore
            {
                get
                {
                    if (implementationScore == null)
                    {
                        implementationScore = GetScoreValueByScoreValueType("JUDGE_ImplementationScore");

                    }
                    return implementationScore.value;


                }
                set
                {
                    if (implementationScore == null)
                    {
                        implementationScore = GetScoreValueByScoreValueType("JUDGE_ImplementationScore");

                    }

                    implementationScore.value = value;



                }
            }

            public double AdditionalInformationScore
            {
                get
                {
                    if (additionalInformationScore == null)
                    {
                        additionalInformationScore = GetScoreValueByScoreValueType("JUDGE_AdditionalInformationScore");

                    }
                    return additionalInformationScore.value;


                }
                set
                {
                    if (additionalInformationScore == null)
                    {
                        additionalInformationScore = GetScoreValueByScoreValueType("JUDGE_AdditionalInformationScore");

                    }

                    additionalInformationScore.value = value;



                }
            }

            public double ThemeScore
            {
                get
                {
                    if (themeScore == null)
                    {
                        themeScore = GetScoreValueByScoreValueType("JUDGE_ThemeScore");

                    }
                    return themeScore.value;


                }
                set
                {
                    if (themeScore == null)
                    {
                        themeScore = GetScoreValueByScoreValueType("JUDGE_ThemeScore");

                    }

                    themeScore.value = value;



                }
            }

            public double BeneficiariesScore
            {
                get
                {
                    if (beneficiariesScore == null)
                    {
                        beneficiariesScore = GetScoreValueByScoreValueType("JUDGE_BeneficiariesScore");

                    }
                    return beneficiariesScore.value;


                }
                set
                {
                    if (beneficiariesScore == null)
                    {
                        beneficiariesScore = GetScoreValueByScoreValueType("JUDGE_BeneficiariesScore");

                    }

                    beneficiariesScore.value = value;



                }
            }

            public double DeliveryFormatScore
            {
                get
                {
                    if (deliveryFormatScore == null)
                    {
                        deliveryFormatScore = GetScoreValueByScoreValueType("JUDGE_DeliveryFormatScore");

                    }
                    return deliveryFormatScore.value;


                }
                set
                {
                    if (deliveryFormatScore == null)
                    {
                        deliveryFormatScore = GetScoreValueByScoreValueType("JUDGE_DeliveryFormatScore");

                    }

                    deliveryFormatScore.value = value;



                }
            }

            public double TimeScore
            {
                get
                {
                    if (timeScore == null)
                    {
                        timeScore = GetScoreValueByScoreValueType("JUDGE_TimeScore");

                    }
                    return timeScore.value;


                }
                set
                {
                    if (timeScore == null)
                    {
                        timeScore = GetScoreValueByScoreValueType("JUDGE_TimeScore");

                    }

                    timeScore.value = value;



                }
            }

            public double CostScore
            {
                get
                {
                    if (costScore == null)
                    {
                        costScore = GetScoreValueByScoreValueType("JUDGE_CostScore");

                    }
                    return costScore.value;


                }
                set
                {
                    if (costScore == null)
                    {
                        costScore = GetScoreValueByScoreValueType("JUDGE_CostScore");

                    }

                    costScore.value = value;



                }
            }

            public double AvailableResourcesScore
            {
                get
                {
                    if (availableResourcesScore == null)
                    {
                        availableResourcesScore = GetScoreValueByScoreValueType("JUDGE_AvailableResourcesScore");

                    }
                    return availableResourcesScore.value;


                }
                set
                {
                    if (availableResourcesScore == null)
                    {
                        availableResourcesScore = GetScoreValueByScoreValueType("JUDGE_AvailableResourcesScore");

                    }

                    availableResourcesScore.value = value;



                }
            }

            public double ResultScoreMarketingDescription
            {
                get
                {
                    if (resultScoreMarketingDescription == null)
                    {
                        resultScoreMarketingDescription =
                            GetScoreValueByScoreValueType("JUDGE_ResultScoreMarketingDescription");

                    }
                    return resultScoreMarketingDescription.value;


                }
                set
                {
                    if (resultScoreMarketingDescription == null)
                    {
                        resultScoreMarketingDescription =
                            GetScoreValueByScoreValueType("JUDGE_ResultScoreMarketingDescription");

                    }

                    resultScoreMarketingDescription.value = value;



                }
            }

            public double ResultScoreAdopter
            {
                get
                {
                    if (resultScoreAdopter == null)
                    {
                        resultScoreAdopter = GetScoreValueByScoreValueType("JUDGE_ResultScoreAdopter");

                    }
                    return resultScoreAdopter.value;


                }
                set
                {
                    if (resultScoreAdopter == null)
                    {
                        resultScoreAdopter = GetScoreValueByScoreValueType("JUDGE_ResultScoreAdopter");

                    }

                    resultScoreAdopter.value = value;



                }
            }

            public double ResultScoreEvidence
            {
                get
                {
                    if (resultScoreEvidence == null)
                    {
                        resultScoreEvidence = GetScoreValueByScoreValueType("JUDGE_ResultScoreEvidence");

                    }
                    return resultScoreEvidence.value;


                }
                set
                {
                    if (resultScoreEvidence == null)
                    {
                        resultScoreEvidence = GetScoreValueByScoreValueType("JUDGE_ResultScoreEvidence");

                    }

                    resultScoreEvidence.value = value;



                }
            }

            public double ResultScoreReplication
            {
                get
                {
                    if (resultScoreReplication == null)
                    {
                        resultScoreReplication = GetScoreValueByScoreValueType("JUDGE_ResultScoreReplication");

                    }
                    return resultScoreReplication.value;


                }
                set
                {
                    if (resultScoreReplication == null)
                    {
                        resultScoreReplication = GetScoreValueByScoreValueType("JUDGE_ResultScoreReplication");

                    }

                    resultScoreReplication.value = value;



                }
            }

            public double ResultScoreBeneficiary
            {
                get
                {
                    if (resultScoreBeneficiary == null)
                    {
                        resultScoreBeneficiary = GetScoreValueByScoreValueType("JUDGE_ResultScoreBeneficiary");

                    }
                    return resultScoreBeneficiary.value;


                }
                set
                {
                    if (resultScoreBeneficiary == null)
                    {
                        resultScoreBeneficiary = GetScoreValueByScoreValueType("JUDGE_ResultScoreBeneficiary");

                    }

                    resultScoreBeneficiary.value = value;



                }
            }

            public double InnovationScoreInnovation
            {
                get
                {
                    if (innovationScoreInnovation == null)
                    {
                        innovationScoreInnovation = GetScoreValueByScoreValueType("JUDGE_InnovationScoreInnovation");

                    }
                    return innovationScoreInnovation.value;


                }
                set
                {
                    if (innovationScoreInnovation == null)
                    {
                        innovationScoreInnovation = GetScoreValueByScoreValueType("JUDGE_InnovationScoreInnovation");

                    }

                    innovationScoreInnovation.value = value;



                }
            }

            public double InnovationScoreMethodology
            {
                get
                {
                    if (innovationScoreMethodology == null)
                    {
                        innovationScoreMethodology = GetScoreValueByScoreValueType("JUDGE_InnovationScoreMethodology");

                    }
                    return innovationScoreMethodology.value;


                }
                set
                {
                    if (innovationScoreMethodology == null)
                    {
                        innovationScoreMethodology = GetScoreValueByScoreValueType("JUDGE_InnovationScoreMethodology");

                    }

                    innovationScoreMethodology.value = value;



                }
            }

            public double InnovationScoreChallenge
            {
                get
                {
                    if (innovationScoreChallenge == null)
                    {
                        innovationScoreChallenge = GetScoreValueByScoreValueType("JUDGE_InnovationScoreChallenge");

                    }
                    return innovationScoreChallenge.value;


                }
                set
                {
                    if (innovationScoreChallenge == null)
                    {
                        innovationScoreChallenge = GetScoreValueByScoreValueType("JUDGE_InnovationScoreChallenge");

                    }

                    innovationScoreChallenge.value = value;



                }
            }

            public double InnovationScoreRealizable
            {
                get
                {
                    if (innovationScoreRealizable == null)
                    {
                        innovationScoreRealizable = GetScoreValueByScoreValueType("JUDGE_InnovationScoreRealizable");

                    }
                    return innovationScoreRealizable.value;


                }
                set
                {
                    if (innovationScoreRealizable == null)
                    {
                        innovationScoreRealizable = GetScoreValueByScoreValueType("JUDGE_InnovationScoreRealizable");

                    }

                    innovationScoreRealizable.value = value;



                }
            }

            public double InnovationScoreReplicable
            {
                get
                {
                    if (innovationScoreReplicable == null)
                    {
                        innovationScoreReplicable = GetScoreValueByScoreValueType("JUDGE_InnovationScoreReplicable");

                    }
                    return innovationScoreReplicable.value;


                }
                set
                {
                    if (innovationScoreReplicable == null)
                    {
                        innovationScoreReplicable = GetScoreValueByScoreValueType("JUDGE_InnovationScoreReplicable");

                    }

                    innovationScoreReplicable.value = value;



                }
            }

            public double ChallengeScoreCurrentSituation
            {
                get
                {
                    if (challengeScoreCurrentSituation == null)
                    {
                        challengeScoreCurrentSituation = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreCurrentSituation");

                    }
                    return challengeScoreCurrentSituation.value;


                }
                set
                {
                    if (challengeScoreCurrentSituation == null)
                    {
                        challengeScoreCurrentSituation = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreCurrentSituation");

                    }

                    challengeScoreCurrentSituation.value = value;



                }
            }

            public double ChallengeScoreSpecificProblem
            {
                get
                {
                    if (challengeScoreSpecificProblem == null)
                    {
                        challengeScoreSpecificProblem = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreSpecificProblem");

                    }
                    return challengeScoreSpecificProblem.value;


                }
                set
                {
                    if (challengeScoreSpecificProblem == null)
                    {
                        challengeScoreSpecificProblem = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreSpecificProblem");

                    }

                    challengeScoreSpecificProblem.value = value;



                }
            }

            public double ChallengeScoreCause
            {
                get
                {
                    if (challengeScoreCause == null)
                    {
                        challengeScoreCause = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreCause");

                    }
                    return challengeScoreCause.value;


                }
                set
                {
                    if (challengeScoreCause == null)
                    {
                        challengeScoreCause = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreCause");

                    }

                    challengeScoreCause.value = value;



                }
            }

            public double ChallengeScoreDimension
            {
                get
                {
                    if (challengeScoreDimension == null)
                    {
                        challengeScoreDimension = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreDimension");

                    }
                    return challengeScoreDimension.value;


                }
                set
                {
                    if (challengeScoreDimension == null)
                    {
                        challengeScoreDimension = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreDimension");

                    }

                    challengeScoreDimension.value = value;



                }
            }

            public double ChallengeScoreBeneficiaries
            {
                get
                {
                    if (challengeScoreBeneficiaries == null)
                    {
                        challengeScoreBeneficiaries = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreBeneficiaries");

                    }
                    return challengeScoreBeneficiaries.value;


                }
                set
                {
                    if (challengeScoreBeneficiaries == null)
                    {
                        challengeScoreBeneficiaries = GetScoreValueByScoreValueType("JUDGE_ChallengeScoreBeneficiaries");

                    }

                    challengeScoreBeneficiaries.value = value;



                }
            }

            #endregion

            private ScoreValue GetScoreValueByScoreValueType(string scoreValueType)
            {
                ScoreValue score =
                    scoreComponent.Score.ScoreValues.FirstOrDefault(a => a.ScoreValueType == scoreValueType && a.Score.Active == true);
                if (score == null)
                {
                    score = new ScoreValue()
                        {
                            ScoreValueId = Guid.Empty,
                            value = 0,
                            ScoreValueType = scoreValueType
                        };
                    scoreComponent.Score.ScoreValues.Add(score);
                }
                return score;
            }

            public ScoreJudge(Guid SolutionId, int userId)
            {
                scoreComponent = new ScoreComponent(SolutionId, userId, "JUDGE");


            }

            public ScoreJudge(Guid SolutionId, int userId, string challengeReference)
            {
                scoreComponent = new ScoreComponent(SolutionId, userId, "JUDGE", challengeReference);


            }

            public int save(string challengeReference)
            {
                return scoreComponent.Save(challengeReference);
            }
            public int save()
            {
                return scoreComponent.Save();
            }

            public double AbsoluteScore
            {
                get
                {

                    double finalScore = 0;
                    if (scoreComponent.Score != null)
                    {
                        foreach (var score in scoreComponent.Score.ScoreValues)
                        {
                            finalScore = finalScore + score.value * score.ScoreType.Weight;
                        }
                    }

                    return finalScore;

                }
            }


            public static double GetGlobalJudgeScore(Guid solutionId)
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                var result = from c in mifnexsoEntities.Scores
                             where c.SolutionId == solutionId && c.ScoreType == "JUDGE" && c.Active == true
                             select c;
                double finalScore = 0;
                int judges = 0;


                foreach (var score in result)
                {
                    judges++;
                    foreach (var scoreValue in score.ScoreValues)
                    {
                        finalScore = finalScore + scoreValue.value * scoreValue.ScoreType.Weight;
                    }
                }
                if (judges != 0)
                {
                    return finalScore / judges;
                }
                else
                {
                    return double.MinValue;
                }
            }


            public static double GetGlobalJudgeScore(Guid solutionId, string challengeReference)
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                var result = from c in mifnexsoEntities.Scores
                             where c.SolutionId == solutionId && c.ScoreType == "JUDGE" && c.ChallengeReference == challengeReference && c.Active == true
                             select c;
                double finalScore = 0;
                int judges = 0;
                foreach (var score in result)
                {
                    judges++;
                    foreach (var scoreValue in score.ScoreValues)
                    {
                        finalScore = finalScore + scoreValue.value * scoreValue.ScoreType.Weight;
                    }
                }
                if (judges != 0)
                {
                    return finalScore / judges;
                }
                else
                {
                    return double.MinValue;
                }
            }
            public static double GetGlobalAdditionalJudgeScore(Guid solutionId, string challengeReference)
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                var result = from c in mifnexsoEntities.Scores
                             where c.SolutionId == solutionId && c.ScoreType == "CUSTOM_XML" && c.ChallengeReference == challengeReference && c.Active == true
                             select c;
                double finalScore = 0;
                int judges = 0;
                foreach (var score in result)
                {
                    judges++;
                    foreach (var scoreValue in score.ScoreValues)
                    {
                        finalScore = finalScore + scoreValue.value * scoreValue.ScoreType.Weight;
                    }
                }
                if (judges != 0)
                {
                    return finalScore / judges;
                }
                else
                {
                    return double.MinValue;
                }
            }

            public static double GetGlobalJudgeScoreXML(Guid solutionId, string challengeReference)
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                var result = from c in mifnexsoEntities.Scores
                             where c.SolutionId == solutionId && c.ScoreType == "JUDGE" && c.ChallengeReference == challengeReference && c.Active == true
                             select c;

                var result2 = from c in mifnexsoEntities.Scores
                              where c.SolutionId == solutionId && c.ScoreType == "CUSTOM_XML" && c.ChallengeReference == challengeReference && c.Active == true
                              select c;


                double finalScore = 0;
                int judges = 0;
                foreach (var score in result)
                {
                    judges++;
                    double scoreDouble = 0;
                    foreach (var scoreValue in score.ScoreValues)
                    {
                        scoreDouble = scoreDouble + scoreValue.value * scoreValue.ScoreType.Weight;
                    }
                    Score scoreXML = result2.FirstOrDefault(a => a.UserId == score.UserId);
                    if (scoreXML != null)

                        finalScore = finalScore + (scoreDouble * 0.6) + (Convert.ToDouble(scoreXML.ComputedValue) * 0.4);
                    else
                        finalScore = finalScore + scoreDouble;

                }

                if (judges != 0)
                {
                    return finalScore / judges;
                }
                else
                {
                    return double.MinValue;
                }
            }

        }

        public class ScoreUser
        {
            public float Views { get; set; }
            public float Share { get; set; }
            public float Discussion { get; set; }
            public float ComputedScore { get; set; }
        }

        public class ScoreSubmitter
        {
            public float Word { get; set; }
            public float Tested { get; set; }
            public float Documents { get; set; }
            public float References { get; set; }
            public float ReferencesVerified { get; set; }
            public float AbsoluteScore { get; set; }
            public float RelativeScore { get; set; }
        }

        public class ScoreTime
        {
            public float AbsoluteScore { get; set; }
            public float RelativeScore { get; set; }

        }


    }
}
