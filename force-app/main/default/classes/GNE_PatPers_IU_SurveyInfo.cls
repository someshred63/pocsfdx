public class GNE_PatPers_IU_SurveyInfo
    {
        public boolean pass;
        public String segmentID;
        public String transactionID;
        public String patientID;
        public String answerNumber;
        public String answerText;
        public String questionNumber;
        public Transaction_File_Staging_gne__c trans;       
        
        public GNE_PatPers_IU_SurveyInfo (String transactionID, String segmentID,String patientID)
        {
            this.segmentID = segmentID;
            this.transactionID = transactionID;
            this.patientID = patientID;
            this.trans = null; 
            this.pass = true;
            this.answerNumber = '';
            this.answerText = '';
            this.questionNumber = '';
            system.debug('GNE_TEST: SurveyInfo Created -- Segment: ' + segmentID + 
                            ' transactionID: ' + transactionID + ' Patient ID: ' +
                            patientID);
        }
        
        @istest public static void TestMe()
        {
            GNE_PatPers_IU_SurveyInfo sur = 
                new GNE_PatPers_IU_SurveyInfo('trans1','segmentid1','patient01');
            System.assert(sur != null);    
            system.debug('GNE_TEST: Survey Init Complete');
        }
       }