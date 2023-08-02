public class GNE_SFA2_MCCO_ART_Driver extends GNE_SFA2_List_View_Base_Controller{
    
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }

    //Created By Will Larter, Veeva Systems for November 2009 SFA R2 Release 
    //Version #: 1
    //Date: 8/7/2009

    
    //Begin Code:
    
    
    public List<ART_Team_gne__c> teamSiteList {get; private set;}
    public List<ART_Site_gne__c> ownerSiteList {get; private set;}
    public List<ART_Site_gne__c> mySiteList {get; private set;}
    public List<ART_Site_gne__c> otherSiteList {get; private set;}
    public String userIdToViewLink {get;set;}
       
    //Wrapper addition
    List<Wrapper> m_list = new List<Wrapper>();
    Map<ID, Boolean> pri_Map = new Map<ID,Boolean>(); 
    
    public GNE_SFA2_MCCO_ART_Driver() {
        super('ART_Site_gne__c');
        thisController = this;
    
    
    //Determine the Site List Where User is on the ART Team
    teamSiteList = [Select Id, ART_Site_gne__c, Primary_Art_Site_gne__c, Team_Member_gne__c From ART_Team_gne__c Where Team_Member_gne__c=:UserInfo.getUserId()];
    system.debug('TeamSIteList: '+teamSiteList);
    //Determine the Site List Where User is the Site Owner
    ownerSiteList = [Select Id, Name, OwnerId, Owner.Name From ART_Site_gne__c Where OwnerId=:UserInfo.getUserId()];
    
    Set<ID> siteIds = new Set<Id>();
    
    
    for (Art_Site_gne__c a_x : ownerSiteList) {
        siteIds.add(a_x.Id);
        }
    
    for (Art_Team_gne__c a_t : teamSiteList) {
        siteIds.add(a_t.Art_Site_gne__c);
        
        if (a_t.Primary_Art_Site_gne__c == true)
            pri_Map.put(a_t.ART_Site_gne__c, a_t.Primary_Art_Site_gne__c);
        }
    
    
    mySiteList = [select Id, Name, ART_Site_Number_gne__c, Primary_gne__c, OwnerId,Owner.Name, RecordTypeId From ART_Site_gne__c where id in :siteIds];         
    
    otherSiteList = [select Id, Name, ART_Site_Number_gne__c, OwnerId,Owner.Name, RecordTypeId From ART_Site_gne__c where not id in :mySiteList];         
    system.debug('otherSiteList: ' + otherSiteList);
     
    }

    public List<ART_Site_gne__c> getMySiteList() {
        return mySiteList;
    }
    
    public List<ART_Site_gne__c> getOtherSiteList() {
        return otherSiteList;
    }
    
   public PageReference newArtSite() {
    
    PageReference pg = new PageReference('/a3D/e');
    return pg;
    
        /*Schema.DescribeSObjectResult describeResult = Task.SObjectType.getDescribe();
        PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        newToT.getParameters().put('retURL', '/apex/GNE_SFA2_MyTasks'); 
        return newToT;*/
    }
    
    //Added by Chatham Reed - Veeva Systems
    public List<Wrapper> getCombinedList() {        
        m_list.clear();
        system.debug('&&My Site List: '+mySiteList);
        for (ART_Site_gne__c a : mySiteList) {
            Wrapper w = new Wrapper();
            w.artSite = a;
            if (pri_Map.get(a.Id) == true)
            w.artSite.Primary_gne__c=true;
            
            m_list.add(w);
        }
        system.debug('mlist: '+m_list);
        return m_list;
        
    }
    
    public class Wrapper {
        public ART_Site_gne__c artSite {get; set;}
        public Boolean primary {get; set;}
    }
    
    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref; 
    }

}