/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com
*  Created: 2013-07-12
*  Project: FCR
*  Description: REST Webservice, returns a list of TerritoryIds and TerritoryNames for the specified user id (unixId).
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/Territories/*')
global with sharing class GNE_FCR_Territories_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String unixId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            User user = GNE_FCR_Services_Helper.getUserByExternalId(unixId);
            List<UserTerritory2Association> userTerritories = GNE_FCR_Services_Helper.getUserTerritories(user.id);
            List<String> userTerritoryIds = GNE_FCR_Services_Helper.buildStringList(userTerritories, 'TerritoryId');
            List<Territory2> result = GNE_FCR_Services_Helper.getTerritories(userTerritoryIds);
            GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
            if(result!=null && result.size()>0)
            {
                r.records = result;
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();
            r.setErrorStatus(ex);
            return r;
        }
    }
}