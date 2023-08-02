/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com   
*  Created: 2013-07-12
*  Project: FCR
*  Description: REST Webservice, returns a list of AccountIds for the specified user id (unixId).             
***************************************************************************************************/
@RestResource(urlMapping='/FCRWebservice/Account/*')
global with sharing class GNE_FCR_Account_Webservice {   
    @HttpGet  @ReadOnly
    webservice static GNE_FCR_Util.RestResponse processRequest() 
    {
        RestRequest req = RestContext.request;
        String unixId= req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return build(unixId);          
    }

      private static GNE_FCR_Util.RestResponse build(Object unixId) {
          List<Account> accounts = null;
          List<GetUserAccountsRecord> records = new List<GetUserAccountsRecord>();
          User user =GNE_FCR_Services_Helper.getUserByExternalId((String)unixId);
          if(user==null)
          {
              return new GNE_FCR_Util.CustomRestResponse();
          }        
          List<UserTerritory2Association> userTerritories = GNE_FCR_Services_Helper.getUserTerritories(user.id);
          List<String> userTerritoryIds = GNE_FCR_Services_Helper.buildStringList(userTerritories, 'Territory2Id');         
          List<Territory2> territories = GNE_FCR_Services_Helper.getTerritories(userTerritoryIds); 
          Map<Id,String> territoryIdToNameMap = new Map<Id,String>();
          for(Territory2 t : territories){
             territoryIdToNameMap.put(t.Id,t.Name);
          }              
          List<Group> groups = GNE_FCR_Services_Helper.getGroupsForTerritories(territories);
          Map<Id,List<Id>> groupsToTerritoryMap = new Map<Id,List<Id>>();
          for(Group g : groups){
              if(!groupsToTerritoryMap.containsKey(g.Id)){
                  groupsToTerritoryMap.put(g.Id,new List<Id>());
              }
              groupsToTerritoryMap.get(g.Id).add(g.relatedId);
          }
          List<String> groupIds = GNE_FCR_Services_Helper.buildStringList(groups, 'Id');
          List<AccountShare> accountShares = GNE_FCR_Services_Helper.getAccountSharesForGroups(groups);
          Map<Id,List<Id>> accountsToGroupMap = new Map<Id,List<Id>>();
          for(AccountShare a : accountShares){
              if(!accountsToGroupMap.containsKey(a.AccountId)){
                  accountsToGroupMap.put(a.AccountId,new List<Id>());
              }
              accountsToGroupMap.get(a.AccountId).add(a.UserOrGroupId);
          }   
          List<String> accountIds = GNE_FCR_Services_Helper.buildStringList(accountShares, 'AccountId');          
          accounts = GNE_FCR_Services_Helper.getAccountsByIds(accountIds);
          Integer i=0;
          for(Account account: accounts) {
              for(Id g : accountsToGroupMap.get(account.Id)){
                  for(Id t : groupsToTerritoryMap.get(g)){
                      if(i++==1000){          
                          GNE_FCR_Util.CustomRestResponse response = new GNE_FCR_Util.CustomRestResponse();
                          response.records = records;
                          response.setSuccessStatus();          
                          return response;
                      }
                      records.add(new GetUserAccountsRecord(account,t,territoryIdToNameMap.get(t)));
                  }
              }
          }
          GNE_FCR_Util.CustomRestResponse response = new GNE_FCR_Util.CustomRestResponse();
          response.records = records;
          response.setSuccessStatus();          
          return response;
        }
   
    
    class GetUserAccountsRecord extends GNE_FCR_util.RestRecord {
      private Id TerritoryId;
      private String TerritoryName; 
      public String AccountId;
      public String Name;
      public String MdmId;
      public GetUserAccountsRecord(Account account,Id TerritoryId,String TerritoryName) {
        this.AccountId = account.id;
        this.Name=account.name;
        this.MdmId=account.MDMID_gne__c;
        this.TerritoryName = TerritoryName;  
        this.TerritoryId = TerritoryId;
      }
    }       
}