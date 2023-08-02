public class GNE_MCCO_PFT_MySurveys_Tab_Driver {

    private final ApexPages.standardController controller;
    public String actionS {get; set;}
    public List<qsObj> qsList {get; set;}
    private ID usrID;
    private Map<String, Boolean> availableRtypesMap = new Map<String, Boolean>();

    private SFA2_Configuration_Object_gne__c pageConfiguration;

    public class qsObj {
        public ID qID {get; set;}
        public String qType {get; set;}
        public String qStatus {get; set;}
        public String sModified {get; set;}
    }

    /*
    * Constructor
    */
    public GNE_MCCO_PFT_MySurveys_Tab_Driver(){
        // Instantiate variables
        Set<ID> questionnaireIDSet = new Set<ID>();
        this.qsList                = new List<qsObj>();
        usrID                      = UserInfo.getUserId();

        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Survey_gne__c');

        // Get record types from the questionnaire object for the running user
        getAvailableRTypes();

        // Based on user territory get group list
        Map<ID, Group> groupMap = new Map<ID, Group>([SELECT Id FROM Group
                                                      WHERE
                                                        Type = 'Territory' AND
                                                        RelatedID IN (SELECT Territory2Id
                                                                      FROM UserTerritory2Association
                                                                      WHERE UserID = :usrID)]
                                                     );

        // Retreive Questionnaire Accounts
        List<AggregateResult> questionnaireAccountList = [SELECT
                                                                Questionnaire_gne__c,
                                                                COUNT(Account__c)
                                                            FROM
                                                                QuestionnaireAccount_gne__c
                                                            WHERE
                                                                Questionnaire_gne__r.Audience_Type_gne__c IN ('General', 'Targeted') AND
                                                                Questionnaire_gne__r.Questionnaire_Status_gne__c = 'Open' AND
                                                                Questionnaire_gne__r.Category_gne__c IN :availableRtypesMap.keySet() AND
                                                                Account__c IN (SELECT AccountID
                                                                                FROM AccountShare
                                                                                WHERE (RowCause = 'TerritoryRule' or RowCause = 'Territory2AssociationManual') AND
                                                                                UserOrGroupID IN :groupMap.keySet())
                                                            GROUP BY Questionnaire_gne__c
                                                            HAVING COUNT(Account__c) > 0];

        for (AggregateResult ar : questionnaireAccountList)
            questionnaireIDSet.add((ID)ar.get('Questionnaire_gne__c'));

        // For targeted additionally add those accounts where the user is the manager
        questionnaireAccountList = [SELECT
                                        Questionnaire_gne__c,
                                        COUNT(Account__c)
                                    FROM
                                        QuestionnaireAccount_gne__c
                                    WHERE
                                        Questionnaire_gne__r.Audience_Type_gne__c = 'Targeted' AND
                                        Questionnaire_gne__r.Questionnaire_Status_gne__c = 'Open' AND
                                        Questionnaire_gne__r.Category_gne__c IN :availableRtypesMap.keySet() AND
                                        Account__r.Account_Manager_gne__c = :usrID
                                    GROUP BY Questionnaire_gne__c
                                    HAVING COUNT(Account__c) > 0];

        for (AggregateResult ar : questionnaireAccountList)
            questionnaireIDSet.add((ID)ar.get('Questionnaire_gne__c'));

        // Retreive Questionnaires
        List<Questionnaire_gne__c> questionnaireList = [SELECT
                                                            Id,
                                                            Type_gne__c,
                                                            Questionnaire_Status_gne__c,
                                                            (SELECT LastModifiedDate FROM Surveys__r
                                                             WHERE OwnerId = :usrID
                                                             ORDER BY LastModifiedDate DESC LIMIT 1)
                                                        FROM
                                                            Questionnaire_gne__c
                                                        WHERE
                                                            Id IN :questionnaireIDSet];

        for (Questionnaire_gne__c q : questionnaireList) {
            qsObj temp      = new qsObj();
            temp.qID        = q.Id;
            temp.qType      = q.Type_gne__c;
            temp.qStatus    = q.Questionnaire_Status_gne__c;
            temp.sModified  = '-';
            if (q.Surveys__r.size() > 0)
                temp.sModified  = q.Surveys__r[0].LastModifiedDate.format();
            this.qsList.add(temp);
        }
    }


    /*
    * This method populates record types for the Questionnaire object available for the running user
    */
    public void getAvailableRTypes(){
        Schema.DescribeSObjectResult describeResults = Questionnaire_gne__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> rtInfos = describeResults.getRecordTypeInfos();
        for(schema.recordTypeInfo srt : rtInfos){
           if(srt.isAvailable() && srt.getName() != 'Managed Care - Access Metrics'){
               if(!availableRtypesMap.containsKey(srt.getName())){
                    availableRtypesMap.put(srt.getName(), srt.isAvailable());
               }
           }
        }
    }


    /**
    * Page Methods
    */
    public PageReference viewS(){
        PageReference newpage = new PageReference('/apex/GNE_MCCO_Mass_Survey_Updates?id='+this.actionS);
        newpage.setRedirect(true);
        return newpage;
    }

    public PageReference viewSFA2(){
        PageReference newpage = new PageReference('/apex/GNE_SFA2_MCCO_Mass_Survey_Updates?id='+this.actionS);
        newpage.setRedirect(true);
        return newpage;
    }

    public String getListPageName() {
        String result;
        if(pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
  	 	return result;
  	}

  	public String getActiveMenuItem() {
  	 	String result = '';
      	if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
    	  result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
      	}
      	return result;
  	}
}