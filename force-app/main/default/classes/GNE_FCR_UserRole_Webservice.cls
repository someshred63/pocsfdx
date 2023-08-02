/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-08
*  Project: FCR
*  Description: REST Webservice, to determine the role of a given user.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/UserRole/*')
global with sharing class GNE_FCR_UserRole_Webservice {   
@HttpGet
    global static GNE_FCR_util.RestResponse doGet(){
       GNE_FCR_Util.CustomRestResponse  r = new GNE_FCR_Util.CustomRestResponse();
       try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('UserRole'));
            String unixId = null;
            if(index >= 0){
                unixId = req.requestURI.substring(index+1);
            }
            User user = GNE_FCR_Services_Helper.getUserByExternalId(unixId);        
            String role = null;
            if (user!=null)
            {
                role = GNE_FCR_Services_Helper.getUserRole(user.Id);
            }
            if (role!=null)
            {
                r.records.add(new UserRoleRecord(user.Id,unixId,role));              
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
    class UserRoleRecord extends GNE_FCR_Util.RestRecord{
      public Id UserId;
      public String ExternalId;
      public String Role;
      public UserRoleRecord(Id UserId,String ExternalId,String Role) {
        this.UserId=UserId;
        this.ExternalId=ExternalId;
        this.Role=Role; 
      }
    }  
}