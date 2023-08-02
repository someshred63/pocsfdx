public class GNE_SFA2_Questionnaire_Layout_Controller {
    public Questionnaire_gne__c questionnaire {get;set;}
 	public Boolean isNew {get; set;}
    public Boolean isFreeze {get; set;}
    public Boolean isHide {get; set;}
    public Boolean noEdit {get; set;}
    public Boolean readyUse {get; set;}
    public Boolean showPosition {get; set;}
    public Boolean showWeight {get; set;} 
    public Boolean productSpecific {get; set;}                
    public GNE_SFA2_Questionnaire_Layout_Controller(ApexPages.StandardController controller) {
        this.questionnaire = (Questionnaire_gne__c)controller.getRecord();
        System.debug('-----------------------------------------------questionnaire:'+questionnaire);
        String isNewParam = ApexPages.currentPage().getParameters().get('isNew');
        System.debug('-----------------------------------------------isNewParam:'+isNewParam);  
        if(isNewParam != null && isNewParam == 'true')
        {
        	System.debug('-----------------------------------------------questionnaire:'+questionnaire);        
        }
        else 
        {
			this.isNew = false;
            questionnaire = [Select Id, Name,Audience_Type_gne__c, Category_gne__c, Freeze_Surveys_gne__c,
            					Hide_Surveys_gne__c, No_Edit_gne__c, ProductSpecific_gne__c, Questionnaire_Status_gne__c,
            					Product_gne__c, Product_gne__r.Name, Ready_For_Use_gne__c,Show_Questions_Position_gne__c, 
            					Show_Weight_gne__c, Single_Survey_per_Mode_gne__c, Territories_can_gne__c, Type_gne__c, Version_gne__c
            					from Questionnaire_gne__c where ID =: questionnaire.Id];

			if(questionnaire.Freeze_Surveys_gne__c)
            this.isFreeze = true;
            if(questionnaire.Hide_Surveys_gne__c)
            this.isHide = true;
            if(questionnaire.No_Edit_gne__c)
            this.noEdit = true;
            if(questionnaire.Ready_For_Use_gne__c)
            this.readyUse = true;
            if(questionnaire.Show_Questions_Position_gne__c)
            this.showWeight = true;
            if(questionnaire.Show_Questions_Position_gne__c)
            this.showWeight = true;
            if(questionnaire.ProductSpecific_gne__c)
            this.productSpecific = true;                                    
            System.debug('-----------------------------------------------questionnaire:'+questionnaire);   
        }
    }   

    
    public PageReference save()
    {
        upsert questionnaire;
        return new PageReference('/'+this.questionnaire.Id);
    }

    public PageReference cancel()
    {
        return new PageReference('/'+this.questionnaire.Id);
    }
    
    public PageReference edit()
    {
        return new PageReference('/apex/GNE_SFA2_Edit_Questionnaire_Layout?id='+this.questionnaire.Id);
    }  
}