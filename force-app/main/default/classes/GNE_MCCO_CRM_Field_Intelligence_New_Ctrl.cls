public with sharing class GNE_MCCO_CRM_Field_Intelligence_New_Ctrl {

    private String accountId { get; set; }
    private String retUrl { get; set; }

    public Account account { get; private set; }

    private List<GNE_MCCO_CRM_Survey__c> surveys { get; set; }

    public Set<SelectOption> surveysSelectTmp { get; private set; }
    public List<SelectOption> surveysSelect { get; private set; }

    public Boolean hasSurveys { get; private set; }
    public Boolean isCreatable { get; private set; }

    public String iconBase64 { get; private set; }

    public String selectedSurvey { get; set; }

    public GNE_MCCO_CRM_Field_Intelligence_New_Ctrl() {

    	surveysSelect 		= new List<SelectOption>();
    	surveysSelectTmp	= new Set<SelectOption>();

    	iconBase64 			= GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
		hasSurveys 			= false;
    	isCreatable 		= false;

    	accountId = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
    	retUrl = (ApexPages.currentPage().getParameters().get('retUrl') != null && ApexPages.currentPage().getParameters().get('retUrl') != '') ? ApexPages.currentPage().getParameters().get('retUrl') : null;

    	try {

    		List<String> tsfList = new List<String>();
    		List<String> territoriesIds = new List<String>();

    		account = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1][0];

    		for(TSF_vod__c tsf : [SELECT Territory_vod__c FROM TSF_vod__c WHERE Account_vod__c = :account.Id]) {
    			tsfList.add(tsf.Territory_vod__c);
    		}

    		for(Territory2 t : [SELECT Id FROM Territory2 WHERE Name IN :tsfList]) {
    			territoriesIds.add(t.Id);
    		}

    		surveys = [SELECT Id, Account_Ids_gne__c, Title_gne__c, Territories_gne__c, Assignment_Mode_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE Ready_To_Use_gne__c = true AND Close_survey_gne__c = false AND Record_Type_gne__c = 'Account'];

    		if(account != null) {
    			isCreatable = true;
			}


			if(surveys.size() > 0) {

				Set<Id> surveysAlreadyCreatedIds = new Set<Id>();

				for(GNE_MCCO_CRM_Field_Intelligence__c fi : [SELECT Survey_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Survey_Status_gne__c != 'Closed' AND (User_gne__c = :UserInfo.getUserId() OR CreatedById = :UserInfo.getUserId())]) {
					surveysAlreadyCreatedIds.add(fi.Survey_gne__c);
				}

				for(GNE_MCCO_CRM_Survey__c survey : surveys) {

					if(!surveysAlreadyCreatedIds.contains(survey.Id)) {

						if(!String.isEmpty(survey.Territories_gne__c)) {

							Set<String> sTerritoriesSet = new Set<String>();
							List<String> sTerritoriesList = survey.Territories_gne__c.split(';');
							sTerritoriesSet.addAll(sTerritoriesList);

							for(String ts : territoriesIds) {
								if(sTerritoriesSet.contains(ts)) {
			                		surveysSelectTmp.add(new SelectOption(survey.Id, survey.Title_gne__c));
								}
							}

						}

						if(!String.isEmpty(survey.Account_Ids_gne__c)) {

							Set<String> sAccountsSet = new Set<String>();
							List<String> sAccountsList = survey.Account_Ids_gne__c.split(';');
							sAccountsSet.addAll(sAccountsList);

							System.debug(sAccountsSet);

							if(sAccountsSet.contains(accountId) || sAccountsSet.contains(account.Id)) {
		                		surveysSelectTmp.add(new SelectOption(survey.Id, survey.Title_gne__c));
							}

						}

					}

                }

                surveysSelect.addAll(surveysSelectTmp);

                if(surveysSelect.size() > 0) {
                	hasSurveys = true;
                }

			}

    	} catch(Exception ex) {
    		System.debug(ex.getMessage());
    	}

    }

    public PageReference create() {

		PageReference pageref = null;

    	try {
    		GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = new GNE_MCCO_CRM_Field_Intelligence__c();

    		fieldIntelligence.Account_gne__c = accountId;
    		fieldIntelligence.Survey_gne__c = selectedSurvey;

    		insert fieldIntelligence;

    		String link = '/apex/GNE_MCCO_CRM_Field_Intelligence_Edit';
    		pageref = new PageReference(link);

    		pageref.getParameters().put('id', fieldIntelligence.Id);
    		if(String.isNotBlank(retUrl)) {
    			pageref.getParameters().put('retUrl', retUrl);
    		}
    		pageref.setredirect(true);

    	} catch (Exception ex) {
    		System.debug(ex.getMessage());
    	}

    	return pageref;

    }

}