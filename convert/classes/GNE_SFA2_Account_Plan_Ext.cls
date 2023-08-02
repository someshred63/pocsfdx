/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-02
*  Description: This is a controller extension for GNE_SFA2_Account_Plan page
*  
*  Modification History
*  Date        Name        Description
*  2012-12-13  lewandj2    New approach with configuration object
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Plan_Ext extends GNE_SFA2_DynamicVFLoader {   
    
    public String recordTypeName {get; private set;}

    public GNE_SFA2_Account_Plan_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Plan_Layout');
        recordTypeName = [SELECT RecordType.Name FROM Account_Plan_vod__c WHERE Id =: ApexPages.currentPage().getParameters().get('Id') limit 1].RecordType.Name;
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Account_Plan_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference addAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    } 

    public PageReference viewAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_Attachment_layout?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    //relatedList Custom Buttons   
    public override PageReference callMethod(String methodName){
       if('newAccountTacticClick'.compareTo(methodName) == 0){
           return newAccountTacticClick(); 
       }   
       if('newAccountTacticStdClick'.compareTo(methodName) == 0){
           return newAccountTacticStdClick(); 
       }       
       return super.callMethod(methodName);      
    }
     
    private PageReference newAccountTacticClick(){
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Account_Tactic_Create_Layout?accountPlanId='+myObject.Id+'&retURL=%2F'+myObject.Id+'&accountId='+myObject.get('Account_vod__c'));
        pageref.setredirect(true);
        return pageref;
    }
    
    private PageReference newAccountTacticStdClick(){
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Acc_Tactic_Std_Create_Layout?objectId='+myObject.Id+'&retURL=%2F'+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
}