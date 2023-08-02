/* 
 * GNE_MCCO_CRM_Questionnaire_New_Edit_Ctrl 
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 */
public without sharing class GNE_MCCO_CRM_Questionnaire_New_Edit_Ctrl {
	
	private String questionnaireId { get; set; }
	public List<SelectOption> recordTypesOptions { get; private set; }
	public Questionnaire_gne__c questionnaire { get; set; }
	
	public String recordTypeName { get; set; }
	public Map<Id, String> recordTypeIdsToName { get; set; }

	public List<SelectOption> categories { get; private set; }
	public List<SelectOption> audiences { get; private set; }
	public List<SelectOption> surveyModes { get; private set; }

	public String pageTitle { get; private set; }
	public Boolean editMode { get; private set; }
	
	public GNE_MCCO_CRM_Questionnaire_New_Edit_Ctrl() {
		loadRecordTypeList();
		questionnaireId = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
		
		if(questionnaireId != '' && questionnaireId != null) {
			pageTitle = 'Edit Questionnaire';
			editMode = true;
			questionnaire = [ SELECT Id, Product_gne__c, ProductSpecific_gne__c, Type_gne__c, Version_gne__c, OwnerId, Category_gne__c, Audience_Type_gne__c, Single_Survey_per_Mode_gne__c, Show_Questions_Position_gne__c, Ready_For_Use_gne__c, No_Edit_gne__c, Freeze_Surveys_gne__c, Hide_Surveys_gne__c, Show_Weight_gne__c FROM Questionnaire_gne__c WHERE Id = :questionnaireId LIMIT 1][0];
		} else {
			pageTitle = 'New Questionnaire';
			editMode = false;
			questionnaire = new Questionnaire_gne__c( OwnerId = UserInfo.getUserId() );
		}
		
		loadQuestionnaireData();
		
        String success = ApexPages.CurrentPage().GetParameters().Get('success');
        String error = ApexPages.CurrentPage().GetParameters().Get('error');

		if(!String.isEmpty(success)) {
    		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, success));
		} 
		
		if(!String.isEmpty(error)) {
    		ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
		} 

	}
	
	private void loadRecordTypeList() {
		recordTypeIdsToName = new Map<Id, String>();
		recordTypesOptions = new List<SelectOption>();
		List<Schema.RecordTypeInfo> schemaRecordTypesList =  Questionnaire_gne__c.SObjectType.getDescribe().getRecordTypeInfos();
		for(Schema.RecordTypeInfo recordTypeInfo : schemaRecordTypesList) {
			if ((recordTypeInfo.isAvailable() == true) && recordTypeInfo.getName() != null && recordTypeInfo.getName() != 'Master') {
				if(String.isEmpty(recordTypeName)) {
					recordTypeName = recordTypeInfo.getName();
				}
				recordTypesOptions.add(new SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
				recordTypeIdsToName.put(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName());
			}
		}
	}

	public PageReference save() {
		PageReference pageRef;
		try {
			if(!questionnaire.ProductSpecific_gne__c) {
				questionnaire.Product_gne__c = null;
			}
			upsert questionnaire;
			pageRef = new PageReference('/apex/GNE_MCCO_CRM_Questionnaire_View?id='+questionnaire.Id);
			pageRef.getParameters().put('success', 'Success!');
		} catch(DMLException ex) {
			pageRef = ApexPages.currentPage();
			pageRef.getParameters().put('error', ex.getMessage());
		}
        pageRef.setredirect(true);
        return pageRef;
	}
	
	public PageReference changeRecordType() {
		recordTypeName = recordTypeIdsToName.get(questionnaire.RecordTypeId);
		loadQuestionnaireData();
		return null;
	}
	
	private void loadQuestionnaireData(){
		
		categories = new List<SelectOption>();
		audiences = new List<SelectOption>();
		surveyModes = new List<SelectOption>();

        if(recordTypeName.equals('Managed Care - PT')){
            
            categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
        } else if(recordTypeName.equals('Managed Care - Access Metrics')){
                
            categories.add(new SelectOption('Managed Care - Access Metrics','Managed Care - Access Metrics'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));

    	} else if(recordTypeName.equals('Medical Event Survey')){
            
            categories.add(new SelectOption('Speaker Content','Speaker Content'));
            categories.add(new SelectOption('Speaker Skills','Speaker Skills'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));

        } else if(recordTypeName.equals('Speaker Nomination Survey')){
            
            categories.add(new SelectOption('Managed Care','Managed Care'));
            categories.add(new SelectOption('Nurses','Nurses'));
            categories.add(new SelectOption('Physicians','Physicians'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));

        } else if(recordTypeName.equals('MedAffairs')){
                
            categories.add(new SelectOption('MedAffairs','MedAffairs'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));

        } else if(recordTypeName.equals('Managed Care - CFT')){
            
            categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));

        } else if(recordTypeName.equals('Managed Care - FRM')){
            
            categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
                
        } else if(recordTypeName.equals('Canada Sales')){
    	
            categories.add(new SelectOption('Canada Sales','Canada Sales'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
            
        } else if(recordTypeName.equals('ATLS')){
        	
            categories.add(new SelectOption('ATLS','ATLS'));
            categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
            categories.add(new SelectOption('Medical Event Survey','Medical Event Survey'));
            categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
            
        } else if(recordTypeName.contains('MCCO Teams') && recordTypeName.contains('Shared')){
    	
            categories.add(new SelectOption('Sales','Sales'));
            categories.add(new SelectOption('ATLS','ATLS'));
            categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
            categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
            categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
            categories.add(new SelectOption('MedAffairs','MedAffairs'));
            categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
            categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
            categories.add(new SelectOption('Canada Sales','Canada Sales'));
            categories.add(new SelectOption('MCCO Teams - Shared','MCCO Teams - Shared'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
            
        } else if(recordTypeName.equals('Master')){
        	
            categories.add(new SelectOption('Sales','Sales'));
            categories.add(new SelectOption('ATLS','ATLS'));
            categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
            categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
            categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
            categories.add(new SelectOption('MedAffairs','MedAffairs'));
            categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
            categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
            categories.add(new SelectOption('Canada Sales','Canada Sales'));
            categories.add(new SelectOption('MCCO Teams - Shared','MCCO Teams - Shared'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
            
        } else if(recordTypeName.contains('Master')){
    	
            categories.add(new SelectOption('Sales','Sales'));
            categories.add(new SelectOption('ATLS','ATLS'));
            categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
            categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
            categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
            categories.add(new SelectOption('MedAffairs','MedAffairs'));
            categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
            categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
            categories.add(new SelectOption('Canada Sales','Canada Sales'));
            categories.add(new SelectOption('MCCO Teams - Shared','MCCO Teams - Shared'));
            audiences.add(new SelectOption('Targeted','Targeted'));
            audiences.add(new SelectOption('General','General'));
            surveyModes.add(new SelectOption('Per Account','Per Account'));
            surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
            surveyModes.add(new SelectOption('No Limit','No Limit'));
            
        }

    }
	
}