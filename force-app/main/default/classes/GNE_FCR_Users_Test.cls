@isTest(SeeAllData=true)
private class GNE_FCR_Users_Test {  
    static testMethod void testUserRole(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        system.debug('Id returned'+unixId.Alias);
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/UserRole/'+Id;
        GNE_FCR_Util.CustomRestResponse response = ((GNE_FCR_Util.CustomRestResponse)GNE_FCR_UserRole_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
    }

    static testMethod void testUsers(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/Users/'+Id;
        GNE_FCR_Util.CustomRestResponse response = ((GNE_FCR_Util.CustomRestResponse)GNE_FCR_Users_Webservice.doGet());
        System.assert(response.records.size()>0);
        System.assertEquals(true,response.success);
    }

    static testMethod void testFranchiseObjectives(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/FranchiseObjectives/'+Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_Franchise_Webservice.doGet());
        System.assert(response.records.size()>0);
        System.assertEquals(true,response.success);
    }

    static testMethod void testTerritories(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/Territories/'+Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_Territories_Webservice.doGet());
        System.assert(response.records.size()>0);
        System.assertEquals(true,response.success);
    }

    static testMethod void testAccounts(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/Account/'+Id;
        GNE_FCR_Util.CustomRestResponse response = ((GNE_FCR_Util.CustomRestResponse)GNE_FCR_Account_Webservice.processRequest());
        System.assert(response.records.size()>0);
        System.assertEquals(true,response.success);
    }
    
    static testMethod void testPreviousActionPlan(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/PreviousActionPlans/'+Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_Previous_ActionPlan_Webservice.doGet());
        System.assert(response.records.size()>=0);
        System.assertEquals(true,response.success);
    }

    static testMethod void testListDaysPlan(){
        User unixId = [select Alias from User where Profile.Name='GNE-SFA-Actemra-CS' and IsActive=true limit 1];
        String Id = unixId.Alias;        
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/ListDaysPlan/'+Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ListDaysPlan_Webservice.doGet());
        System.assert(response.records.size()>=0);
        System.assertEquals(true,response.success);
    }
}