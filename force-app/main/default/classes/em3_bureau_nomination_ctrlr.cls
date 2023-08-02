public class em3_bureau_nomination_ctrlr {
    
    //custom object used to contain setters and getters for
    //the ID, speaker bureau membership record and speaker scope 
    //for a particular speaker bureau member 
    public class memberContainer{
        public Id Speaker_Bureau_ID_gne {get; set;}
        public Speaker_Bureau_Membership_gne__c member {get;set;}
        public string Speaker_Scope {get;set;}       
    }
    
    public boolean errors {get; set;}
    public String absolutePath {get;set;}
    public String viewId {get;set;}    
    private String hostname;    
    public Map<ID,memberContainer> membersMap;
    public Map<ID,memberContainer> membersMap2;
    private List<SelectOption> bureauOptions;
    private List<SelectOption> scopeOptions;
    private String IDs;
    private boolean remove = false;
    private set<String> user = new set<String>();
    private boolean comp = false;            
    private boolean unclasified = false; 
    //Omear's new var's     
    set<ID> cant_nominate = new set<ID>();
    set<ID> can_nominate = new set<ID>();
    private List<Speaker_Bureau_Membership_gne__c> non_members {get; set;}
    
    /*public List<Speaker_Bureau_Membership_gne__c> getnon_members(){
    	return non_members;    
    }*/               
    
    public ID a_bureau {set; get;}
    
    public pageReference set_Bureaus(){    	
		for(memberContainer mC : membersMap.values()){
    		mC.Speaker_Bureau_ID_gne = this.a_bureau;
    		system.debug('MC:'+this.a_bureau);
		}
		return null;	    	    	    
    }
    
    /*public ID getThe_Bureau(){
    	return this.the_bureau;
    }
    
    public void setThe_Bureau(ID bureau){
    	this.the_bureau = bureau;
    	set_all();
    }*/           
            
    //The constructor collects all speaker bureau membership records selected
    //into a map.  For each member a their ID and an empty memberContainer instnace    
    //are put into a MAP, and then that memberContainer is returned immediatley after
    //having been put in and the speaker bureau ID and speaker scope are populated               
    public em3_bureau_nomination_ctrlr(ApexPages.StandardController controller){    		
    	this.errors = false;
    	
    	hostname = ApexPages.currentPage().getHeaders().get('Host');
	    absolutePath = 'https://' + hostname ;
    	viewId = '&fcf=' + ApexPages.currentPage().getParameters().get('fcf');
    	Map<ID,Speaker_Bureau_Membership_gne__c> membersBaseMap=new Map<Id,Speaker_Bureau_Membership_gne__c>([select ID, Name, Speaker_Status_gne__c,Speaker_Bureau_ID_gne__c, Speaker_Bureau_ID_gne__r.Name, Bureau_Member_gne__c, Bureau_Member_gne__r.Name, Speaker_scope_gne__c,Bureau_Member_gne__r.Classification_gne__c from Speaker_Bureau_Membership_gne__c where id in:new Map<String,String>(ApexPages.currentPage().getParameters()).values()]);
    	Non_Members=new List<Speaker_Bureau_Membership_gne__c>();
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
    }       		
	
	public void filter_members(Map<ID,Speaker_Bureau_Membership_gne__c> membersBaseMap){		
		for(ID memberId : membersBaseMap.keySet()) {			
			system.debug('BASEEE:'+memberId);		
			Speaker_Bureau_Membership_gne__c member = membersBaseMap.get(memberId);            
            if(member.Speaker_Status_gne__c == 'Rejected'){
            	cant_nominate.add(memberId);	            	
            	non_members.add(member);
            }else{
            	can_nominate.add(memberId);
            }			
        }                
	}
	
	//omear method - to find dupes and add them to the dupe list
	public List<memberContainer> dupes_list(Map<ID,memberContainer> membersMap){
		//set to hold all bureaus and members from those being nominated
		Set<ID> bureaus_set = new Set<ID>();
		Set<ID> members_set = new Set<ID>();
		
		//go through all membership's about to be nominated		
		for(memberContainer memberCont : membersMap.values()){
			Speaker_Bureau_Membership_gne__c membership=memberCont.member;
			
			bureaus_set.add(memberCont.speaker_bureau_ID_gne);
			members_set.add(membership.Bureau_Member_gne__c);			            
        }															
		
		//List of Existing Bureau Memberships 
		List<Speaker_Bureau_Membership_gne__c> existing_memberships = [Select s.Speaker_Bureau_ID_gne__c, 
		s.Bureau_Member_gne__c, s.Speaker_Bureau_ID_gne__r.Name, s.Bureau_Member_gne__r.Name From Speaker_Bureau_Membership_gne__c s where s.Speaker_Bureau_ID_gne__c IN :bureaus_set
		AND s.Bureau_Member_gne__c IN :members_set];				
		
		List<MemberContainer> duplicate_nominees = new List<MemberContainer>();
		
		boolean dupes = false;	
		//Loop through existing memberships and the previously created bureaus_set
		//and remove from the matching element from the bureaus_set when a dupe is found	
		for(Speaker_Bureau_Membership_gne__c sb : existing_memberships){
			for(memberContainer memberCont : membersMap.values()){
				Speaker_Bureau_Membership_gne__c membership = memberCont.member;
				if((sb.speaker_bureau_id_gne__c == memberCont.speaker_bureau_id_gne) && 
				(sb.bureau_member_gne__c == membership.bureau_member_gne__c)){
					dupes = true;
					duplicate_nominees.add(memberCont);																				
				}
			}
		}
		
		return duplicate_nominees;
	}
	
	
	//I 'believe' the very first time the page is run the bureauOptions list is 
	//populated with all the bureau's in sfdc
	//BTW, selectoptions constructors are as follows: selectOption(value, label)	 
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
    
    //Same as before, if not instantiated the speaker scope dropdown is populated
    //with all the values for the scope, returned from the picklist using the schema
    //not using a DML
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
    
    /*public void approve(){
        List<Speaker_Bureau_Membership_gne__c> approve_list = new List<Speaker_Bureau_Membership_gne__c>();                                                                         
        for(Speaker_Bureau_Membership_gne__c membership : membersMap.values()){
            if(membership.Speaker_Status_gne__c != 'Nominated'){
                membersMap.clear();                                                                 
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Can only Approve Nominated Speakers'));                             
                break;
            }
            membership.Speaker_Status_gne__c = 'Approved';                              
            approve_list.add(membership);                                       
        }                                                                                                       
        membersMap.clear(); 
        
        try{
            update(approve_list);                                                       
        }catch(DmlException e){
            System.debug(e.getMessage());
        }
        comp = true;
    }
    
    
    public void reject(){
        List<Speaker_Bureau_Membership_gne__c> reject_list = new List<Speaker_Bureau_Membership_gne__c>();                                                                  
                                                        
        for(Speaker_Bureau_Membership_gne__c membership : membersMap.values()){
            if(membership.Speaker_Status_gne__c != 'Nominated'){
                membersMap.clear();                                                                 
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Can only Reject Nominated Speakers'));                              
                break;
            }               
            membership.Speaker_Status_gne__c = 'Rejected';      
            reject_list.add(membership);                                    
        }                                                                       
        membersMap.clear();
        
        try{
            update(reject_list);                                                        
        }catch(DmlException e){
            System.debug(e.getMessage());
        }
        comp = true;
    }*/
    
    
    //this function removes the Members that are not possible to include from the list if with remove is true.
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
			if( membership.Speaker_Status_gne__c == 'Rejected'){                    
                    if(withRemove) membersMap.remove(membership.Id);
                    statusCount++;
            }
        }
        return !(membersMap.size()==0 || (statusCount==membersMap.size() && !withRemove));
    }
    
    //If the getMembersMapNominationStatus returns false then there are no users
    //that can be nominated so an error is displayed.  Either way true or false are returned.
    public Boolean getMembersMapNominationStatus(){
        Boolean status=checkMembersMapNominationStatus(membersMap,false);
        if(!status) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no Members that can be selected on this list. Press Cancel to close this window.'));
        return status;
    }
    
    //For some reason the members variable in this method has a double of every member when it gets to this function.
    //so if members originally had 2 membership records in the list, it would have 4 in this method.  No idea why.  Fixed this by making
    //the members variable static - unclear as to why that helped but logic behind making it static was to have it keeps it's value and not
    //be refreshed upon instantiation of the controller
    
    //if checkMembersMapNominationStatus == false then the button is disabled, otherwise
    //then the membersMap values (which contains containers with all the new values for each
    //member) is iterated over and all new bureau membership record are created and added
    //to the nominations list and then inserted
    public void nominate(){
    	
    	 for(memberContainer memberCont : membersMap.values()){
	    		if(memberCont.Speaker_Scope == 'Unclassified')
	    		{
	    			unclasified = true;
	    			break;
	    		}
	    			
	    }
    	if(unclasified)
    	{
    		this.errors = true;
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Speakers have not been nominated.  There are Speaker Classification(s) that are  Unclassified.  Please remove any Nominees where Speaker Classification displays “Unclassified” before Nominating Speakers.'));
    		return;
    	}
    	        
    	this.errors = false;                                                                                                 
        if(!checkMembersMapNominationStatus(membersMap,true)) return;
        List<memberContainer> dupes = dupes_list(membersMap);
	    if(dupes.size() > 0){
	    	this.errors = true;
	    	String errors = '';
	    	
	    	for(memberContainer mc : dupes){
	    		errors += mc.member.Bureau_Member_gne__r.Name + ' Nominated for ' + mc.member.Speaker_bureau_ID_gne__r.Name + ' | '; 	
	    	}	    	 	    		    	
	    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'List of records with errors: ' + errors));
	    }else{
		                
	        List<Speaker_Bureau_Membership_gne__c> nominations = new List<Speaker_Bureau_Membership_gne__c>();                                          
	        for(memberContainer memberCont : membersMap.values()){
	            Speaker_Bureau_Membership_gne__c membership=memberCont.member;
	            nominations.add(new Speaker_bureau_membership_gne__c(           
	                Speaker_Status_gne__c = 'Nominated',
	                //Per Gianfranco on 10/13/09: Renominated Speakers Meet Speaker Criteria
	                Meets_Speaker_Criteria_gne__c = 'Yes-On Previous Bureau',
	                Speaker_Scope_gne__c = memberCont.Speaker_Scope,
	                Speaker_Bureau_ID_gne__c = memberCont.Speaker_Bureau_ID_gne,
	                Nomination_Date_gne__c = System.now(),
	                Nominated_By_gne__c = UserInfo.getUserID(),
	                Bureau_Member_gne__c = membership.Bureau_Member_gne__c          
	            ));                                 
	        }
	        try{
	            insert(nominations);                                                        
	        }catch(DmlException e){
	            System.debug(e.getMessage());
	        }     
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
    
    //Removes a user from the membersMap
    public void removeMemberFromList(){
    	unclasified = false;
        Id memberId=System.CurrentPageReference().getParameters().get('rid');
        if(membersMap.containsKey(memberId)) membersMap.remove(memberId);
    }
    
    //returns the memberContainers in the membersMap
    public List<memberContainer> getMembers(){
        return membersMap.values();
    }
    
    public List<memberContainer> getMembers2(){
    	return membersMap2.values(); 
    }
    
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

/*

public class em3_bureau_nomination_ctrlr {
    
    private List<String> myList = new List<String>();   
    private List<SelectOption> options = new List<SelectOption>();
    private List<Speaker_Bureau_Membership_gne__c> myMembers = new List<Speaker_Bureau_Membership_gne__c>();    
    private String selected_option;
    private List<Speaker_Bureau_gne__c> myBureaus = new List<SPeaker_Bureau_gne__c>();

    private static List<Speaker_Bureau_Membership_gne__c> members = new List<Speaker_Bureau_Membership_gne__c>();       
    private Map<ID,Speaker_Bureau_Membership_gne__c> ID_to_members_map = new Map<ID,Speaker_Bureau_Membership_gne__c>();
    private String IDs;
    private boolean remove = false;
    private set<String> user = new set<String>();
    private boolean comp = false;
            
    public em3_bureau_nomination_ctrlr(ApexPages.StandardController controller){
        reset();                                
        myList = new Map<String,String>(ApexPages.currentPage().getParameters()).values();                  
        setMembers();
        setBureaus();                   
    }       
    
    private string text;
    
    public String getText(){
        return text;
    }
    
    public void setText(){
            text = ApexPages.currentPage().getParameters().get('getRidOfThisId');
    }       
    
    public boolean getRemove(){
        return remove;
    }
    
    public void setRemove(boolean input){
        remove = input;
    }
    
    public void removeUser(){
        members.clear();        
        user.add(System.CurrentPageReference().getParameters().get('mName'));
        setRendered(true);
    }       
    
    public void reset(){
        myList.clear();
        options.clear();
        myMembers.clear();
        selected_option = null;
        myBureaus.clear();
        members.clear();
        ID_to_members_map.clear();
        IDs = '';
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
            
    public List<SelectOption> getBureaus(){     
        options = new List<SelectOption>();                
                
        for(Speaker_Bureau_gne__c sb : myBureaus ){                     
            options.add(new SelectOption(sb.Name,sb.Name));
        }
        
        return options;     
    }   
    
    public void setBureaus(){
        myBureaus = [select ID, Name from Speaker_Bureau_gne__c];
    }                           
    
    public boolean complete(){
        
        return comp;
    }
    
    public void approve(){
        List<Speaker_Bureau_Membership_gne__c> approve_list = new List<Speaker_Bureau_Membership_gne__c>();                                                                         
        for(Speaker_Bureau_Membership_gne__c membership : members){
            if(membership.Speaker_Status_gne__c != 'Nominated'){
                members.clear();                                                                    
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Can only Approve Nominated Speakers'));                             
                break;
            }
            membership.Speaker_Status_gne__c = 'Approved';                              
            approve_list.add(membership);                                       
        }                                                                                                       
        members.clear();    
        
        try{
            update(approve_list);                                                       
        }catch(DmlException e){
            System.debug(e.getMessage());
        }
        comp = true;
    }
    
    
    public void reject(){
        List<Speaker_Bureau_Membership_gne__c> reject_list = new List<Speaker_Bureau_Membership_gne__c>();                                                                  
                                                        
        for(Speaker_Bureau_Membership_gne__c membership : members){
            if(membership.Speaker_Status_gne__c != 'Nominated'){
                members.clear();                                                                    
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Can only Reject Nominated Speakers'));                              
                break;
            }               
            membership.Speaker_Status_gne__c = 'Rejected';      
            reject_list.add(membership);                                    
        }                                                                       
        members.clear();
        
        try{
            update(reject_list);                                                        
        }catch(DmlException e){
            System.debug(e.getMessage());
        }
        comp = true;
    }
    
    
    //For some reason the members variable in this method has a double of every member when it gets to this function.
    //so if members originally had 2 membership records in the list, it would have 4 in this method.  No idea why.  Fixed this by making
    //the members variable static - unclear as to why that helped but logic behind making it static was to have it keeps it's value and not
    //be refreshed upon instantiation of the controller
    public void nominate(){                                         
        List<Speaker_Bureau_Membership_gne__c> nominations = new List<Speaker_Bureau_Membership_gne__c>();                                                                  
                                                            
        for(Speaker_Bureau_Membership_gne__c membership : members){
            if(membership.Speaker_Status_gne__c == 'Rejected'){
                members.clear();                                                                    
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Cannot Nominate Rejected Speakers'));                               
                break;
            }else if(membership.Speaker_Status_gne__c == 'Nominated'){
                members.clear();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot Nominate a Speaker who is already nominated'));
                break;
            }else if(membership.Speaker_Status_gne__c == 'Contracted'){
                members.clear();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot Nominate a Contracted Speaker'));
                break;
            }else if(membership.Speaker_Status_gne__c == 'Approved'){
                members.clear();
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Cannot nominate Approved Speakers'));                               
                break;
            }
            //Commented out because of use of User__c
            /*nominations.add(new Speaker_bureau_membership_gne__c(
            User__c = Membership.User__c,
            Speaker_Status_gne__c = 'Nominated',
            Speaker_Scope_gne__c = membership.Speaker_Scope_gne__c,
            Speaker_Bureau_ID_gne__c = membership.Speaker_Bureau_ID_gne__c,
            Nomination_Date_gne__c = System.now(),
            Nominated_By_gne__c = UserInfo.getUserID(),
            Bureau_Member_gne__c = membership.Bureau_Member_gne__c              
            ));*//*
            
            nominations.add(new Speaker_bureau_membership_gne__c(           
            Speaker_Status_gne__c = 'Nominated',
            Speaker_Scope_gne__c = membership.Speaker_Scope_gne__c,
            Speaker_Bureau_ID_gne__c = membership.Speaker_Bureau_ID_gne__c,
            Nomination_Date_gne__c = System.now(),
            Nominated_By_gne__c = UserInfo.getUserID(),
            Bureau_Member_gne__c = membership.Bureau_Member_gne__c              
            ));                                 
        }                                                                       
        members.clear();
        try{
            insert(nominations);                                                        
        }catch(DmlException e){
            System.debug(e.getMessage());
        }   
        comp = true;                
    }
    
    public void setselected_option(String t){
    
    }
    
    public String getselected_option(){
        return null;
    }
    

    
    public void setMembers(){               
        //commented out because of user o User__c
        //myMembers = [select ID,User__c, Name,Speaker_Status_gne__c,Speaker_bureau_id_gne__c,Bureau_Member_gne__c,Speaker_scope_gne__c from Speaker_Bureau_Membership_gne__c];     
        
        myMembers = [select ID, Name,Speaker_Status_gne__c,Speaker_bureau_id_gne__c,Bureau_Member_gne__c,Speaker_scope_gne__c from Speaker_Bureau_Membership_gne__c];
        createMap(myMembers);       
    }
    
    public void createMap(List<Speaker_Bureau_Membership_gne__c> theMembers){       
        for(Speaker_Bureau_membership_gne__c current_member : theMembers){
            if(!ID_to_members_map.keySet().contains(current_member.id)){
                ID_to_members_map.put(current_member.id,current_member);
            }
        }               
    }
            
    public List<Speaker_Bureau_Membership_gne__c> getMembers(){                                             
        for(String memberID : myList){
            ID temp = memberID;
            if(!user.contains(memberID)){                   
                members.add(ID_to_members_map.get(temp));
            }                       
        }                                           
        return members;
    }
            
    public void setList(ID text){
        if(text != null){                   
            myList.add(text);
        }
    }
    
    public List<String> getList(){
        return myList;
    }
}

*/