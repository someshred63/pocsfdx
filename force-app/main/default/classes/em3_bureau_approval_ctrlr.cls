public class em3_bureau_approval_ctrlr {
    
    public class memberContainer{
        public Id Speaker_Bureau_ID_gne {get; set;}
        public Speaker_Bureau_Membership_gne__c member {get;set;}
        public string Speaker_Scope {get;set;}
    }
    
    public String absolutePath {get;set;}
    public String viewId {get;set;}    
    private String hostname;    
    
    public Map<ID,memberContainer> membersMap;
    public Map<ID,memberContainer> membersMap2;    
    private List<Speaker_Bureau_Membership_gne__c> non_members {get; set;}
    private List<SelectOption> bureauOptions;
    private List<SelectOption> scopeOptions;
    private String IDs;
    private boolean remove = false;
    private set<String> user = new set<String>();
    private boolean comp = false;
    
    //Omear's new var's     
    set<ID> cant_nominate = new set<ID>();
    set<ID> can_nominate = new set<ID>();
    
    public Boolean membersMapStaus { get; set; }     
    
            
    public em3_bureau_approval_ctrlr(ApexPages.StandardController controller){
    	
    	hostname = ApexPages.currentPage().getHeaders().get('Host');
	    absolutePath = 'https://' + hostname ;
    	viewId = '&fcf=' + ApexPages.currentPage().getParameters().get('fcf');
    	
    	Non_Members=new List<Speaker_Bureau_Membership_gne__c>();
        Map<ID,Speaker_Bureau_Membership_gne__c> membersBaseMap=new Map<Id,Speaker_Bureau_Membership_gne__c>([select ID, Name,Speaker_Status_gne__c,Speaker_Bureau_ID_gne__c,Bureau_Member_gne__c,Speaker_scope_gne__c,Bureau_Member_gne__r.Classification_gne__c from Speaker_Bureau_Membership_gne__c where id in:new Map<String,String>(ApexPages.currentPage().getParameters()).values()]);
        filter_members(membersBaseMap);
        membersMap=new Map<ID,memberContainer>();
        membersMap2=new Map<ID,memberContainer>();
        //for(ID memberId : membersBaseMap.keySet()) {
        //MY CHANGE - now using only the clean list of nominated users
        for(ID memberId : can_nominate) {
            memberContainer memberCont=new memberContainer();
            membersMap.put(memberId, memberCont);
            memberCont.member=membersBaseMap.get(memberId);
            memberCont.Speaker_Bureau_ID_gne=membersBaseMap.get(memberId).Speaker_Bureau_ID_gne__c;
            if(membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c == null)
            {
            	memberCont.Speaker_Scope= 'Unclassified';
            }
            else
            {
            	if(membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c == 'Local')
            		memberCont.Speaker_Scope= 'Community';
            	else if(membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c == 'Global')
            		memberCont.Speaker_Scope= 'National';
            	else
            		memberCont.Speaker_Scope= membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c;
            }
        }
        if(cant_nominate.size() > 0){        	
	        for(ID memberId : cant_nominate) {	        	
	            memberContainer memberCont=new memberContainer();
	            membersMap2.put(memberId, memberCont);
	            memberCont.member=membersBaseMap.get(memberId);
	            memberCont.Speaker_Bureau_ID_gne=membersBaseMap.get(memberId).Speaker_Bureau_ID_gne__c;
	            if(membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c == null)
	            {
	            	memberCont.Speaker_Scope= 'Unclassified';
	            }
	            else
	            {
	            	if(membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c == 'Local')
            			memberCont.Speaker_Scope= 'Community';
            	    else if(membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c == 'Global')
            			memberCont.Speaker_Scope= 'National';
	            	else
    	        		memberCont.Speaker_Scope= membersBaseMap.get(memberId).Bureau_Member_gne__r.Classification_gne__c;
	            }
	            system.debug('nominate:'+memberId);
	        }
        }                    
        /*membersMap=new Map<ID,memberContainer>();
        for(ID memberId : membersBaseMap.keySet()) {
            memberContainer memberCont=new memberContainer();
            membersMap.put(memberId, memberCont);
            memberCont.member=membersBaseMap.get(memberId);
            memberCont.Speaker_Bureau_ID_gne=membersBaseMap.get(memberId).Speaker_Bureau_ID_gne__c;
            memberCont.Speaker_Scope=membersBaseMap.get(memberId).Speaker_Scope_gne__c;
        }*/
        
        membersMapStaus = getMembersMapNominationStatus();
    }       
	

	public void filter_members(Map<ID,Speaker_Bureau_Membership_gne__c> membersBaseMap){		
		for(ID memberId : membersBaseMap.keySet()) {			
			system.debug('BASEEE:'+memberId);		
			Speaker_Bureau_Membership_gne__c member = membersBaseMap.get(memberId);            
            if(member.Speaker_Status_gne__c == 'Rejected' || member.Speaker_Status_gne__c == 'Approved'){
            	cant_nominate.add(memberId);	            	
            	non_members.add(member);
            }else{
            	can_nominate.add(memberId);
            }			
        }                
	}

    public List<SelectOption> getSpeaker_Bureau_Options() {
        if(bureauOptions==null){
            bureauOptions = new List<SelectOption>();
            List<Speaker_Bureau_gne__c> myBureaus=[select Id, Name from Speaker_Bureau_gne__c order by Name];
            for(Speaker_Bureau_gne__c sb : myBureaus ) {
                bureauOptions.add(new SelectOption(sb.Id,sb.Name));
            }
        }
        return bureauOptions;   
    }        
    
        //returns the memberContainers in the membersMap
    public List<memberContainer> getMembers(){
        return membersMap.values();
    }
    
    public List<memberContainer> getMembers2(){
    	return membersMap2.values(); 
    }
    
    public List<SelectOption> getSpeaker_Scope() {
        if(scopeOptions==null){
            scopeOptions = new List<SelectOption>();
            List<Schema.PicklistEntry> plValues = Speaker_Bureau_Membership_gne__c.Speaker_scope_gne__c.getDescribe().getPicklistValues();
            for(Schema.PicklistEntry plValue:plValues){
                if(!plValue.isActive()) continue;
                scopeOptions.add(new SelectOption(plValue.getLabel(),plValue.getLabel()));
            }
        }     
        return scopeOptions;
    }
    
    
    private boolean rendered = false;
    
    public boolean getRendered(){
        return rendered;
    }
    public void setRendered(boolean ren){
        rendered = ren;
    } 
    
    public void setID(){
        IDs =System.CurrentPageReference().getParameters().get('Name');                             
    }
    
    public string getID(){
        return IDs;
    }
    
    public boolean complete(){
        
        return comp;
    }           
    
    //this function removes the Members that is not possible to include from the list if with remove
    //if returns true, means that there are selectaable users
    public Boolean checkMembersMapNominationStatus(Map<ID,memberContainer> membersMap,Boolean withRemove){
        Integer statusCount=0;
        for(memberContainer memberCont : membersMap.values()){
            Speaker_Bureau_Membership_gne__c membership=memberCont.member;
            /*This method was changed to only disallow 'rejected' speakers and include all others
            if( membership.Speaker_Status_gne__c == 'Rejected' || 
                membership.Speaker_Status_gne__c == 'Nominated' ||
                membership.Speaker_Status_gne__c == 'Contracted' ||
                membership.Speaker_Status_gne__c == 'Approved'){
			*/
			if( membership.Speaker_Status_gne__c == 'Approved' ||
			membership.Speaker_Status_gne__c == 'Rejected'){                    
                    if(withRemove) membersMap.remove(membership.Id);
                    statusCount++;
            }
        }
        return !(membersMap.size()==0 || (statusCount==membersMap.size() && !withRemove));
    }
    public Boolean getMembersMapNominationStatus(){
        Boolean status=checkMembersMapNominationStatus(membersMap,false);
        if(!status) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no Members that can be selected on this list. Press Cancel to close this window.'));
        return status;
    }
    
    //For some reason the members variable in this method has a double of every member when it gets to this function.
    //so if members originally had 2 membership records in the list, it would have 4 in this method.  No idea why.  Fixed this by making
    //the members variable static - unclear as to why that helped but logic behind making it static was to have it keeps it's value and not
    //be refreshed upon instantiation of the controller
    public void approvals(){
        if(!checkMembersMapNominationStatus(membersMap,true)) return;
        List<Speaker_Bureau_Membership_gne__c> approvals = new List<Speaker_Bureau_Membership_gne__c>();                                          
        for(memberContainer memberCont : membersMap.values()){
            Speaker_Bureau_Membership_gne__c membership=memberCont.member;
            membership.Speaker_Status_gne__c = 'Approved';                                   
            approvals.add(membership);                                                        
        }
        try{
            upsert(approvals);                                                        
        }catch(DmlException e){
            System.debug(e.getMessage());
        }           
    }
    /************************************************************************
        This method is no longer used, see comments on Nominate Speaker Page
    ************************************************************************/
    public void updateSpeakerBureau(){
        id i=System.CurrentPageReference().getParameters().get('rid');
        membersMap.get(i).Speaker_Bureau_ID_gne=System.CurrentPageReference().getParameters().get('speakerBureauId');
    }
    public void genericPostbackFunction(){}
    
    public void removeMemberFromList(){
        Id memberId=System.CurrentPageReference().getParameters().get('rid');
        if(membersMap.containsKey(memberId)) membersMap.remove(memberId);
    }
    //public List<memberContainer> getMembers(){
      //  return membersMap.values();
    //}
    public static testmethod void test(){
        PageReference pageRef = Page.Nominate_Speakers;
        Test.setCurrentPage(pageRef);
        
        //Here the actual records Speaker_Bureau_Membership_gne__c should be created and then the id passed
        pageRef.getParameters().put('ce_id0', 'a2xQ0000000005f');
        pageRef.getParameters().put('ce_id1', 'a2xQ0000000005g');
        pageRef.getParameters().put('ce_id2', 'a2xQ0000000004g');
        pageRef.getParameters().put('ce_id3', 'a2xQ0000000001x');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Speaker_Bureau_Membership_gne__c());
        em3_bureau_nomination_ctrlr cont = new em3_bureau_nomination_ctrlr(sc);
        
        System.assertEquals(cont.getMembers().size(), 4);
        
    }        
}