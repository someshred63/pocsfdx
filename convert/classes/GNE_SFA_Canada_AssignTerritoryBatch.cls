global class GNE_SFA_Canada_AssignTerritoryBatch implements Database.Batchable<sObject> {

	private Map<String, String> selectedTerrritoris;
	private String questionaryId;
	private Boolean checkTargeted;

	public GNE_SFA_Canada_AssignTerritoryBatch(String passedQuestionaryId, Boolean passedCheckTargeted, Map<String, String> passedSelectedTerrritoris) {
		this.selectedTerrritoris = passedSelectedTerrritoris;
		this.questionaryId = passedQuestionaryId;
		this.checkTargeted = passedCheckTargeted;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		String query = GNE_SFA_Canada_AssignTerritoryBatch.getTsfQuery(this.checkTargeted, this.selectedTerrritoris);
		return String.isBlank(query) ? null : Database.getQueryLocator(query);
    }

    global static String getTsfQuery(Boolean checkTarget, Map<String, String> allSelectedTerrritoriesMap){
    	if (allSelectedTerrritoriesMap.size() == 0){
    		return null;
    	}
    	String tsfQuery = 'SELECT Account_vod__c FROM TSF_vod__c Where External_Id_vod__c != null AND Address_vod__c != null AND Account_vod__c != null AND Territory_vod__c != null ';
        if(checkTarget){
        	Map<String, Set<String>> userToTerritories = new Map<String, Set<String>>();
	    	for (UserTerritory2Association userTerritory : [SELECT Territory2Id, UserId FROM UserTerritory2Association Where Territory2Id In :allSelectedTerrritoriesMap.keyset() AND UserId In (Select Id From User Where Profile.Name Like '%Canada%' AND IsActive = true)]){
    			if (!userToTerritories.containsKey(userTerritory.UserId)){
    				userToTerritories.put(userTerritory.UserId, new Set<String>());
    			}
    			userToTerritories.get(userTerritory.UserId).add(userTerritory.Territory2Id);
    		}
    		if (userToTerritories.size() == 0){
    			return null;
    		}

    		Map<String, Set<String>> territoriesToProducts = new Map<String, Set<String>>();
    		for (My_Setup_Products_vod__c userProduct : [SELECT Id, OwnerId, Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId In :userToTerritories.keyset() AND Product_vod__c != null AND Product_vod__r.Owner.Name != 'GNE-CANADA-INACTIVE-PROD-QUEUE' Order By OwnerId]){
    			for (String userTerritory : userToTerritories.get(userProduct.OwnerId)){
    				if (!territoriesToProducts.containsKey(userTerritory)){
    					territoriesToProducts.put(userTerritory, new Set<String>());
    				}
    				territoriesToProducts.get(userTerritory).add(userProduct.Product_vod__c);
    			}
    		}
    		if (territoriesToProducts.size() == 0){
    			return null;
    		}

    		List<String> terrToProductsConditions = new List<String>();
    		for (String territoryId : territoriesToProducts.keyset()){
    			terrToProductsConditions.add(String.format('(Territory_gne__c = \'\'{0}\'\' AND Product_Catalog_gne__c In {1})',
    				new String[]{
    					allSelectedTerrritoriesMap.get(territoryId),
    					GNE_SFA2_Util.createInListForQuery(new List<String>(territoriesToProducts.get(territoryId)))
    				}
    			));
    		}

    		String tntQuery = String.format('SELECT Territory_Field_parent_gne__c FROM Targets_and_Tiers_can_gne__c ' +
				'WHERE ({0}) AND (My_Target_gne__c <> null OR Target_gne__c <> null OR Segment_gne__c <> null OR Tier_can_gne__c <> null)',
				new String[]{
					String.join(terrToProductsConditions, ' OR ')
				}
			);

    		tsfQuery += String.format('AND My_Target_vod__c = true AND Account_vod__r.IsPersonAccount = true AND Id In ({0}) ',
        		new String[]{
        			tntQuery
        		}
        	);
        } else {
        	tsfQuery += String.format('AND Territory_vod__c In {0} ',
        		new String[]{
        			GNE_SFA2_Util.createInListForQueryNotEscaping(allSelectedTerrritoriesMap.values())
        		}
        	);
        }
        System.debug('tsfQuery: ' + tsfQuery);
        return tsfQuery;
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {

	    List<Tsf_vod__c> acctTSFs = (List<TSF_vod__c>) scope;
	    Set<Id> accountIds = new Set<Id>();
	    for(TSF_vod__c acctTSF : acctTSFs){
        	accountIds.add(acctTSF.Account_vod__c);
        }

	    if(accountIds.size() > 0){
	    	//create questionaries
	        List<QuestionnaireAccount_gne__c> toInsert = new List<QuestionnaireAccount_gne__c>();
	        Set<QuestionnaireAccount_gne__c> toUpsert = new Set<QuestionnaireAccount_gne__c>();
	        Schema.SObjectField extIdField = QuestionnaireAccount_gne__c.Fields.Questionnaire_Account_ExKey_gne__c;
	        for(Id accId : accountIds){
	            toUpsert.add(new QuestionnaireAccount_gne__c(Account__c = accId, Questionnaire_gne__c = questionaryId, Questionnaire_Account_ExKey_gne__c = accId + '_' + questionaryId));
	        }
	        toInsert = new List<QuestionnaireAccount_gne__c>(toUpsert);
	        List<Database.Saveresult> result;
	        Database.UpsertResult[] lur = Database.upsert(toInsert, extIdField, false);
	    }

    }

	global void finish(Database.BatchableContext bc){

		Questionnaire_gne__c qstr = [SELECT Name FROM Questionnaire_gne__c WHERE Id = :questionaryId LIMIT 1];
		String EMAIL_SUBJECT = 'Completed accounts addition for '+qstr.Name;

		String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = :userName limit 1];
		String userEmail = activeUser.Email;

		List<String> lstToEmail = new List<String>();
		lstToEmail.add(userEmail);

		String body = 'Accounts addition is completed for selected territories, Questionnaire is ready to take surveys.';
		sendEmails(lstToEmail, new String[]{''}, '', EMAIL_SUBJECT, body);

		//updateQuestionnairTerritoriesField();
    }

    private void sendEmails(List<String> toEmail, List<String> ccEmail, String replyTo, String subject, String body) {
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    String[] toAddresses        = toEmail;
	    mail.setToAddresses(toAddresses);
	    mail.setBccSender(false);
	    mail.setSubject(subject);

		mail.setPlainTextBody(body);

		List<Messaging.Sendemailresult> emailResult;
		try{
			emailResult =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			if(emailResult!=null && !emailResult[0].isSuccess()) {
				List<Messaging.SendEmailError> emailError= emailResult[0].getErrors();
				if(emailError!=null) {
					System.debug('email error : ' + emailError[0].getMessage());
				}
			}
		}
		catch(Exception ex) {
			throw ex;
		}

	}



}