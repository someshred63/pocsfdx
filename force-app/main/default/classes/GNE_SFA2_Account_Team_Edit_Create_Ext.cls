/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2013-01-16
*  Description: This is a controller extension for GNE_SFA2_Account_Team_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Team_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 

    public GNE_SFA2_Lookup_Ctrl_Engine lookupColumns {get; private set;}

    public GNE_SFA2_Account_Team_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Team_Layout');

        if(myObject == null){
            myObject = new Account_Team_gne__c();
        }

        String accountId = ApexPages.currentPage().getParameters().get('objectId');
        String teamId = ApexPages.currentPage().getParameters().get('id');
        if(accountId != null && accountId != '' && (teamId == null || teamId == '')){
            myObject.put('Account_gne__c', accountId);
        }

        lookupColumns = new GNE_SFA2_Lookup_Ctrl_Engine();
        lookupColumns.addFieldData('Account_Team_gne__c', 'Team_Member_gne__c', 'Name,Title,Phone,Email,Role_Name_gne__c', null, null);
        lookupColumns.addFieldData('Account_Team_gne__c', 'Contact_fpm_gne__c', 'Name,Title_gne__c,Phone,Email,Type_gne__c', null, null);
    }
    
    public PageReference saveClick(){
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        if(GNE_SFA2_Util.getCurrentUserProfileName().contains('FPM')){
            if(
                (isNullOrEmpty(myObject.get('Team_Member_gne__c')) && isNullOrEmpty(myObject.get('Contact_fpm_gne__c'))) ||
                (!isNullOrEmpty(myObject.get('Team_Member_gne__c')) && !isNullOrEmpty(myObject.get('Contact_fpm_gne__c')))
                ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select User OR Contact.'));
                return null;
            }
        }
        if(String.isNotEmpty(retUrl)){
            save();
            return new PageReference(retUrl);
        }
        return save();
    }

    private Boolean isNullOrEmpty(Object value) {
        return value == null || (String)value == '';
    }
}