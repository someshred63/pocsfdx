/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-14
*  Project: FCR
*  Description: REST Webservice, used to get Franchise Objects.             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/FranchiseObjectives/*')
global with sharing class GNE_FCR_Franchise_Webservice {
    @HttpGet
    global static GNE_FCR_Util.RestResponse doGet(){
        GNE_FCR_Util.SObjectRestResponse r = new GNE_FCR_Util.SObjectRestResponse();            
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Integer index = req.requestURI.indexOf('/',req.requestURI.indexOf('FranchiseObjectives'));
            String unixId = null;
            if(index >= 0){
                unixId = req.requestURI.substring(index+1);
            }
            User user = GNE_FCR_Services_Helper.getUserByExternalId(unixId);        
            List<SFA2_User_Sales_Roster_gne__c>  franchise = GNE_FCR_Services_Helper.getFranchiseId(user.Id);
            System.debug('franchise'+franchise);
            List<Franchise_Objective_gne__c> result = null;
            if(franchise!=null && franchise.size()>0)
            {
               result = GNE_FCR_Services_Helper.getFranchiseObjective(franchise.get(0).Sales_Roster_gne__r.Franchise__r.Id);
            }
            System.debug('result'+result);
            if(result!=null && result.size()>0)
            {
                String timestamp = req.params.get('TimeStamp');
                if(timestamp != null && timestamp != ''){
                    r.deltaCalculator = new GNE_FCR_Util.DeltaCalculator(timestamp);
                }
                 r.setRecords(result);
            }
            r.setSuccessStatus();
            return r;
        }
        catch(Exception ex){
            r.setErrorStatus(ex);
            return r;
        }
    }
}