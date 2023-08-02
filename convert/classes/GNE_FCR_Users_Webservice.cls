/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-26
*  Project: FCR
*  Description: REST Webservice, used to retrieve list of CS users for the DM user and vice-versa.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/Users/*')
global with sharing class GNE_FCR_Users_Webservice {
    @HttpGet
    global static GNE_FCR_util.RestResponse doGet(){
       GNE_FCR_Util.CustomRestResponse  r = new GNE_FCR_Util.CustomRestResponse();
       try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('Users'));
            String unixId = null;
            if(index >= 0){
                unixId = req.requestURI.substring(index+1);
            }
            User user = GNE_FCR_Services_Helper.getUserByExternalId(unixId);        
            List<User> csUsers = new List<User>();            
            List<User> dmUsers = new List<User>();
                                    
            String role = null;
            if(user!=null)
            {
                role = GNE_FCR_Services_Helper.getUserRole(user.Id);
            }
            if (role!=null)
            {
                if(role == 'CS')
                {
                    csUsers = [select Id, FirstName, LastName, External_ID_gne__c, Email, ManagerId from User
                     where Id =:user.Id];
                    dmUsers = [select Id, FirstName, LastName, External_ID_gne__c, Email from User
                     where Id =:csUsers.get(0).ManagerId];                     
                }
                else if(role == 'DM' )
                {
                    dmUsers = [select Id, FirstName, LastName, External_ID_gne__c, Email from User
                     where Id =:user.Id];
                    csUsers = [select Id, FirstName, LastName, External_ID_gne__c, Email from User
                     where ManagerId = :user.Id];                    
                }
                for(User u:csUsers){
                    r.records.add(new UserRestRecord(u.Id,u.FirstName,u.LastName,u.Email,u.External_ID_gne__c,'CS'));
                }
                for(User u:dmUsers){
                    r.records.add(new UserRestRecord(u.Id,u.FirstName,u.LastName,u.Email,u.External_ID_gne__c,'DM'));
                }                
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
    class UserRestRecord extends GNE_FCR_Util.RestRecord{
      public Id UserId;
      public String FirstName;
      public String LastName;
      public String Email;
      public String ExternalId;
      public String Role;
      public UserRestRecord(Id UserId,String FirstName,String LastName,String Email,String ExternalId,String Role) {
        this.UserId=UserId;
        this.FirstName=FirstName;
        this.LastName=LastName;
        this.Email=Email;
        this.ExternalId=ExternalId;
        this.Role=Role; 
      }
    }  
}