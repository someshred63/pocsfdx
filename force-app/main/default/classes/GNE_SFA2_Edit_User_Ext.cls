/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-10-22
*  Description: This is a extension controller for GNE_SFA2_Edit_User_Layout Page
*  
*  Modification History
*  Date        Name        Description
*  20.02.13    Lukasz Bieniawski    Added handling of 'retUrl' parameter       
*************************************************************/
public with sharing class GNE_SFA2_Edit_User_Ext {

    private String userId {get;set;}
    private String fromUrl {get;set;}
    public List<User> userFields {get;set;} 
    
    //temp
    public String userIdToViewLink {get;set;}

    public GNE_SFA2_Edit_User_Ext(ApexPages.StandardController controller) {
        userId = ApexPages.currentPage().getParameters().get('Id');
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        fromUrl = String.isBlank(retUrl) ? ('/apex/GNE_SFA2_User_Layout?Id=' + userId) : retUrl;         
    }
    
    public List<User> getUserFieldsToEditMode() {
        userFields = [SELECT Id, FirstName, Title, LastName, CompanyName, Email, Business_Role_gne__c, UserName, Profile_Name_gne__c, IsActive, TimeZoneSidKey, 
                      External_ID_gne__c, Fax, Phone, ManagerId, Extension, CreatedBy.Name, CreatedById, CreatedDate, LastModifiedBy.Name, LastModifiedById, 
                      LastModifiedDate, Street, City, State, PostalCode, Country
                      FROM User
                      WHERE Id =: userId];
        return userFields;
    }
    
    public User getUserToEdit() {
    	return getUserFieldsToEditMode()[0];
    }
    
    public PageReference clickCancel() {
        PageReference pageref = new PageReference(fromUrl);
        pageref.setredirect(true);
        return pageref; 
    }
    
    public PageReference clickSave() {
        update userFields;
        PageReference pageref = new PageReference(fromUrl);
        pageref.setredirect(true);
        return pageref; 
    }
    
    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref; 
    }

}