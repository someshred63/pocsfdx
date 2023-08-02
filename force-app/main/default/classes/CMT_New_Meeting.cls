public without sharing class CMT_New_Meeting 
{
    public List<CMT_Meeting_gne__c> prevMeetings {get{
    	return (List<CMT_Meeting_gne__c>)controller.getRecords();
    } set;}
    
    public CMT_Meeting_gne__c newMeeting;
    public List<CMT_Agenda_gne__c> meetingAgendas {get; set;}
    public CMT_Agenda_gne__c meetingAgenda;
    public String colorPicker {get; set;}
   	public Boolean editMode{get; set;}
   	public String chosenMeeting {get; set; }
	public Boolean chooseMeeting{get; set;}
	
  	private ApexPages.StandardSetController controller {
		get {
			
			if(controller == null) {
				controller = new ApexPages.StandardSetController([select Title_gne__c, Id from CMT_Meeting_gne__c order by Title_gne__c]);
				controller.setPageSize(20);
			}
			return controller;
		}
		set;
	}
    public CMT_New_Meeting (){
        colorPicker= '/resource/jscolor/jscolor.js';
        PageReference pageRef = System.currentPageReference();
        String url = pageRef.getUrl();
        String meetingId = pageRef.getParameters().get('id');
        if(meetingId == null)
        {
            newMeeting = new CMT_Meeting_gne__c();
            meetingAgendas = new List<CMT_Agenda_gne__c>();
            editMode=false;
            chooseMeeting=false;
        }
        else
        {
            newMeeting = [Select Title_gne__c, Start_Date_gne__c, Meeting_Type_gne__c, Location_gne__c, Is_Meeting_Active_gne__c, Hexadecimal_Color_gne__c, End_Date_gne__c, Timezone__c from CMT_Meeting_gne__c where Id =: meetingId];
            meetingAgendas = [Select Id from CMT_Agenda_gne__c where Meeting_gne__c =: meetingId];
            editMode=true;
            chooseMeeting=false;
        } 
    }
    public CMT_Meeting_gne__c getNewMeeting() 
     {  
        return this.newMeeting;
     }
     public void setNewMeeting(CMT_Meeting_gne__c mtg)
     { 
        this.newMeeting = mtg;
     }
     public CMT_Agenda_gne__c getNewAgenda() 
     {  
        return this.meetingAgenda;
     }
     public void setNewAgenda(CMT_Agenda_gne__c agd)
     { 
        this.meetingAgenda = agd;
     }
     public PageReference save() 
     { 
        upsert newMeeting;
        if(meetingAgendas.size()==0)
        {
            meetingAgenda = new CMT_Agenda_gne__c();
            meetingAgenda.Meeting_gne__c = newMeeting.Id;
            meetingAgenda.Name = CMT_Config.AGENDA_GROUP_NAME;
            insert  meetingAgenda;
        }
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>meetingAgenda=' +meetingAgenda);
        String meetingId = newMeeting.Id;
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_Event_Summary_Page?id='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
            
     }
          
     public PageReference copy()  {
     	System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>chosenMeeting '+chosenMeeting);
     	
     	CMT_Meeting_gne__c oldMeeting = (CMT_Meeting_gne__c) getObjectToClone('CMT_Meeting_gne__c','id',chosenMeeting).get(0);
     	newMeeting = oldMeeting.clone(false, true);
     	newMeeting.Is_Archived__c=false;
     	upsert newMeeting;
 	
	    Map<Id, Id> ids = new Map<Id,Id>();
	    ids.put(oldMeeting.Id, newMeeting.Id);		
	    		
     	Map<String, String> referencesObjects = new Map<String,String>{'Franchise_gne__c'=>'CMT_Franchise_gne__c', 'Session_gne__c'=>'CMT_Session_gne__c','Agenda_gne__c'=>'CMT_Agenda_gne__c'};
     	List<SObject> oldFranchise2Sessions = getObjectToClone('CMT_FranchiseToSession_gne__c','Meeting_gne__c',chosenMeeting,referencesObjects);
		
		List<CMT_FranchiseToSession_gne__c> franchises2Sessions = new List<CMT_FranchiseToSession_gne__c>();
	 
		Map<Id,CMT_Franchise_gne__c> franchises = new Map<Id,CMT_Franchise_gne__c>();
	 
		Map<Id,CMT_Session_gne__c> sessions = new Map<Id,CMT_Session_gne__c>();
	 
	 	Map<Id,CMT_Agenda_gne__c> agendas = new Map<Id,CMT_Agenda_gne__c>();
	 	
		for(SObject obj:oldFranchise2Sessions){				
			CMT_FranchiseToSession_gne__c oldFranchise2Session = (CMT_FranchiseToSession_gne__c )obj;
			CMT_FranchiseToSession_gne__c newFranchise2Session = oldFranchise2Session.clone(false,true);
			newFranchise2Session.Meeting_gne__c=newMeeting.Id;	
			CMT_Franchise_gne__c oldFranchise = oldFranchise2Session.Franchise_gne__r;
			CMT_Franchise_gne__c newFranchise = oldFranchise.clone(false,true);
			newFranchise.Meeting_gne__c=newMeeting.Id;	
			franchises.put(oldFranchise.Id,newFranchise);
			CMT_Session_gne__c oldSession = oldFranchise2Session.Session_gne__r;
			CMT_Session_gne__c newSession = oldSession.clone(false,true);
			newSession.Commercial_Meeting_gne__c=newMeeting.Id;
			sessions.put(oldSession.Id,newSession);
			CMT_Agenda_gne__c oldAgenda = oldFranchise2Session.Agenda_gne__r;
			CMT_Agenda_gne__c newAgenda = oldAgenda.clone(false,true);
			newAgenda.Meeting_gne__c=newMeeting.Id;
			agendas.put(oldAgenda.Id,newAgenda);
			franchises2Sessions.add(newFranchise2Session);
		}
		List<SObject> clonedObjects = new List<SObject>();		
		clonedObjects.addAll((List<SObject>)franchises.values());
		clonedObjects.addAll((List<SObject>)sessions.values());
		clonedObjects.addAll((List<SObject>)agendas.values());
		insert clonedObjects;
		
		if(!franchises.isEmpty()){
			String qryCond = 'CMT_Franchise_gne__c IN(';
			
			for(String fKey:franchises.keySet()){
				qryCond = qryCond+'\''+fkey+'\',';
			}
			qryCond = qryCond.substring(0,qryCond.length()-1)+')';

			Map<Id,CMT_Intermediate_Level_gne__c> interLevels = new Map<Id,CMT_Intermediate_Level_gne__c>();
			for(SObject obj:getObjectToClone('CMT_Intermediate_Level_gne__c',qryCond)){
				CMT_Intermediate_Level_gne__c oldInterLevel = (CMT_Intermediate_Level_gne__c) obj;
				CMT_Intermediate_Level_gne__c newInterLevel = oldInterLevel.clone(false,true);
				newInterLevel.CMT_Franchise_gne__c = franchises.get(oldInterLevel.CMT_Franchise_gne__c).Id;
				interLevels.put(oldInterLevel.Id,newInterLevel);
			}
			insert interLevels.values();
		
			for(CMT_Intermediate_Level_gne__c level: interLevels.values()){
				if(level.Parent_Id_gne__c!=null){
					CMT_Intermediate_Level_gne__c parent = interLevels.get(level.Parent_Id_gne__c);
					level.Parent_Id_gne__c =  parent!=null ? parent.Id:null;
				}
			}
			update interLevels.values();
		
			for(CMT_FranchiseToSession_gne__c f2s:franchises2Sessions){
				if (f2s.Franchise_gne__c!=null)
				{		
					ids.put(f2s.Franchise_gne__c,franchises.get(f2s.Franchise_gne__c).Id);
					f2s.Franchise_gne__c = franchises.get(f2s.Franchise_gne__c).Id;
				}
				if (f2s.Session_gne__c!=null)
				{	
					ids.put(f2s.Session_gne__c,sessions.get(f2s.Session_gne__c).Id);
					f2s.Session_gne__c = sessions.get(f2s.Session_gne__c).Id;
				}
				if(f2s.Agenda_gne__c!=null)
				{
					ids.put(f2s.Agenda_gne__c,agendas.get(f2s.Agenda_gne__c).Id);
					f2s.Agenda_gne__c = agendas.get(f2s.Agenda_gne__c).Id;
				}
				if(f2s.CMT_Intermediate_Level_gne__c!=null)
				{	
					ids.put(f2s.CMT_Intermediate_Level_gne__c,interLevels.get(f2s.CMT_Intermediate_Level_gne__c).Id);
					f2s.CMT_Intermediate_Level_gne__c =interLevels.get(f2s.CMT_Intermediate_Level_gne__c).Id;
				}	
			}
		
			insert franchises2Sessions;
		}
			   			
		Map<Id,CMT_Contact_Category_Group_gne__c> contactCategoryGrps = new Map<Id,CMT_Contact_Category_Group_gne__c>();
		
        for(SObject obj: getObjectToClone('CMT_Contact_Category_Group_gne__c','Meeting_gne__c',chosenMeeting))
	     	{	
	     		CMT_Contact_Category_Group_gne__c oldContactCategoryGroup = (CMT_Contact_Category_Group_gne__c) obj;
	     		CMT_Contact_Category_Group_gne__c newContactCategoryGroup = oldContactCategoryGroup.clone(false, true);
	     		newContactCategoryGroup.Meeting_gne__c = newMeeting.Id;
	     		contactCategoryGrps.put(oldContactCategoryGroup.Id, newContactCategoryGroup);
	     	}
     	
     	referencesObjects = new Map<String,String>{'Category_gne__c'=>'CMT_Contact_Category_gne__c'};
  		Map<Id,CMT_Contact_Category_gne__c> contactCategories = new Map<Id,CMT_Contact_Category_gne__c>();       
       	Map<Id,CMT_Contact_gne__c> contacts = new Map<Id,CMT_Contact_gne__c>();
       	
     	for(SObject obj: getObjectToClone('CMT_Contact_gne__c','Meeting_gne__c',chosenMeeting, referencesObjects))
	     	{		     				     		 		
				CMT_Contact_gne__c oldContact= (CMT_Contact_gne__c) obj;
		     	CMT_Contact_gne__c newContact = oldContact.clone(false, true);	     		
		     	newContact.Meeting_gne__c = newMeeting.Id;
		     	contacts.put(oldContact.Id, newContact);
		     	CMT_Contact_Category_gne__c oldContactCategory = oldContact.Category_gne__r;
		     	CMT_Contact_Category_gne__c newContactCategory = oldContactCategory.clone(false,true);
		     	newContactCategory.Meeting_gne__c = newMeeting.Id;
				contactCategories.put(oldContact.Category_gne__c,newContactCategory);
	     	}
     	insert contactCategoryGrps.values();
     	
     	for(CMT_Contact_Category_gne__c contactCategory:contactCategories.values()){
     		ids.put(contactCategory.Contact_Category_Group_gne__c, contactCategoryGrps.get(contactCategory.Contact_Category_Group_gne__c).Id);
     		contactCategory.Contact_Category_Group_gne__c =contactCategoryGrps.get(contactCategory.Contact_Category_Group_gne__c).Id;
     	}     	
     	insert contactCategories.values();
     	
     	
     	for(CMT_Contact_gne__c contact:contacts.values()){
     		ids.put(contact.Category_gne__c, contactCategories.get(contact.Category_gne__c).Id);
     		contact.Category_gne__c =contactCategories.get(contact.Category_gne__c).Id;
     	}	
     	insert contacts.values();
  		
  		for(Id key:contacts.keySet()){
  			ids.put(key,contacts.get(key).Id);
  		}
  		
  		Map<Id, CMT_Abstract_Category_Group_gne__c>  acgs =new Map<Id,CMT_Abstract_Category_Group_gne__c>();	
     	for(SObject obj:getObjectToClone('CMT_Abstract_Category_Group_gne__c','Meeting_gne__c',chosenMeeting))
	     	{	
	     		CMT_Abstract_Category_Group_gne__c oldAbstrCatGrp = (CMT_Abstract_Category_Group_gne__c) obj;
	     		CMT_Abstract_Category_Group_gne__c newAbstrCatGrp = oldAbstrCatGrp.clone(false, true);
	     		newAbstrCatGrp.Meeting_gne__c = newMeeting.Id;
	     		acgs.put(oldAbstrCatGrp.Id, newAbstrCatGrp);
	     	}
	    insert acgs.values();  
     	
     	for(Id key:acgs.keySet()){
  			ids.put(key,acgs.get(key).Id);
  		}
  		
     	referencesObjects = new Map<String,String>{'Category_gne__c'=>'CMT_Abstract_Category_gne__c'}; 
		
		Map<Id,CMT_Abstract_gne__c> abstracts = new Map<Id,CMT_Abstract_gne__c>();		
		Map<Id,CMT_Abstract_Category_gne__c> abstractCategories = new Map<Id,CMT_Abstract_Category_gne__c>();
		
	    for(SObject obj: getObjectToClone('CMT_Abstract_gne__c','Meeting_gne__c',chosenMeeting, referencesObjects))
	     	{	
	     		CMT_Abstract_gne__c oldAbstract = (CMT_Abstract_gne__c) obj;
	     		CMT_Abstract_gne__c newAbstract = oldAbstract.clone(false, true);
	     		newAbstract.Meeting_gne__c = newMeeting.Id;
	     		
	     		CMT_Abstract_Category_gne__c oldAbstractCategory =  oldAbstract.Category_gne__r;
	     		CMT_Abstract_Category_gne__c newAbstractCategory  = oldAbstractCategory.clone(false, true);
	     		newAbstractCategory.Meeting_gne__c = newMeeting.Id;
	     		newAbstractCategory.Abstract_Group_gne__c = acgs.get(newAbstractCategory.Abstract_Group_gne__c).Id;
	     		abstracts.put(oldAbstract.Id, newAbstract);
	     		abstractCategories.put(oldAbstractCategory.Id, newAbstractCategory);	
	    	 }
	    insert abstractCategories.values();
	    
	    for(CMT_Abstract_gne__c a:abstracts.values()){
	    	ids.put(a.Category_gne__c,abstractCategories.get(a.Category_gne__c).Id);
	    	a.Category_gne__c = abstractCategories.get(a.Category_gne__c).Id;
	    } 
	    insert abstracts.values();
	    
	    for(Id key:abstracts.keySet()){
  			ids.put(key,abstracts.get(key).Id);
  		}
  			
	    clonedObjects = new List<SObject>();
	
	    Map<Id,CMT_Hotel_gne__c> hotels = new Map<Id,CMT_Hotel_gne__c>(); 	
     	for(SObject obj:getObjectToClone('CMT_Hotel_gne__c','Meeting_gne__c',chosenMeeting))
	     	{	
	     		CMT_Hotel_gne__c oldHotel = (CMT_Hotel_gne__c) obj;
	     		CMT_Hotel_gne__c newHotel = oldHotel.clone(false, true);
	     		newHotel.Meeting_gne__c = newMeeting.Id;
	     		hotels.put(oldHotel.Id, newHotel);
	     	}    	
	   	clonedObjects.addAll((List<SObject>) hotels.values());

	    Map<Id,CMT_Shuttle_gne__c> shuttles = new Map<Id,CMT_Shuttle_gne__c>();	    
     	for(SObject obj:getObjectToClone('CMT_Shuttle_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Shuttle_gne__c oldShuttle = (CMT_Shuttle_gne__c) obj;
	     		CMT_Shuttle_gne__c newShuttle = oldShuttle.clone(false, true);
	     		newShuttle.Meeting_gne__c = newMeeting.Id;
	     		shuttles.put(oldShuttle.Id, newShuttle);     		
	    }
	   	clonedObjects.addAll((List<SObject>) shuttles.values());   		
		
		Map<Id,CMT_Parking_gne__c> parkings = new Map<Id,CMT_Parking_gne__c>();
		for(SObject obj : getObjectToClone('CMT_Parking_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Parking_gne__c oldParking = (CMT_Parking_gne__c) obj;
	     		CMT_Parking_gne__c newParking = oldParking.clone(false, true);
	     		newParking.Meeting_gne__c = newMeeting.Id;
	     		parkings.put(oldParking.Id, newParking);	     		
	    }	    
		clonedObjects.addAll((List<SObject>) parkings.values());  
		
		Map<Id, CMT_Taxi_Company_gne__c> taxCompanies = new Map<Id,CMT_Taxi_Company_gne__c>();
		for(SObject obj : getObjectToClone('CMT_Taxi_Company_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Taxi_Company_gne__c oldTaxCompany = (CMT_Taxi_Company_gne__c) obj;
	     		CMT_Taxi_Company_gne__c newTaxCompany = oldTaxCompany.clone(false, true);
	     		newTaxCompany.Meeting_gne__c = newMeeting.Id;
				taxCompanies.put(oldTaxCompany.Id, newTaxCompany);     			  
	    }
		clonedObjects.addAll((List<SObject>) taxCompanies.values());
		
		Map<Id,CMT_Event_gne__c> events = new Map<Id,CMT_Event_gne__c>();
		for(SObject obj : getObjectToClone('CMT_Event_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Event_gne__c oldEvent = (CMT_Event_gne__c) obj;
	     		CMT_Event_gne__c newEvent = oldEvent.clone(false, true);
	     		newEvent.Meeting_gne__c = newMeeting.Id;
	     		events.put(oldEvent.Id, newEvent);
	    }	    	    
     	clonedObjects.addAll((List<SObject>) events.values());
     	
    	Map<Id,CMT_Exhibit_gne__c> exhibits = new Map<Id,CMT_Exhibit_gne__c>();
     	for(SObject obj : getObjectToClone('CMT_Exhibit_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Exhibit_gne__c oldExhibit = (CMT_Exhibit_gne__c) obj;
	     		CMT_Exhibit_gne__c newExhibit = oldExhibit.clone(false, true);
	     		newExhibit.Meeting_gne__c = newMeeting.Id;
	     		exhibits.put(oldExhibit.Id,newExhibit);
	    }	    	    
     	clonedObjects.addAll((List<SObject>) exhibits.values());
     	
    	Map<Id,CMT_Expo_gne__c> exposes = new Map<Id,CMT_Expo_gne__c>();
     	for(SObject obj : getObjectToClone('CMT_Expo_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Expo_gne__c oldExpos = (CMT_Expo_gne__c) obj;
	     		CMT_Expo_gne__c newExpos = oldExpos.clone(false, true);
	     		newExpos.Meeting_gne__c = newMeeting.Id;
	     		exposes.put(oldExpos.Id, newExpos);	    
	    }
     	clonedObjects.addAll((List<SObject>) exposes.values());
     	
     	Map<Id,CMT_Meet_Green_Group_gne__c> meetGreenGrp = new Map<Id,CMT_Meet_Green_Group_gne__c>();
     	for(SObject obj : getObjectToClone('CMT_Meet_Green_Group_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Meet_Green_Group_gne__c oldMeetGreenGrp = (CMT_Meet_Green_Group_gne__c) obj;
	     		CMT_Meet_Green_Group_gne__c newMeetGreenGrp = oldMeetGreenGrp.clone(false, true);
	     		newMeetGreenGrp.Meeting_gne__c = newMeeting.Id;
	     		meetGreenGrp.put(oldMeetGreenGrp.Id, newMeetGreenGrp);
	    }
     	insert meetGreenGrp.values();
     	
     	Map<Id,CMT_Meet_Green_gne__c> meetGreens= new Map<Id,CMT_Meet_Green_gne__c>();    	
     	for(SObject obj : getObjectToClone('CMT_Meet_Green_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Meet_Green_gne__c oldMeetGreen = (CMT_Meet_Green_gne__c) obj;
	     		CMT_Meet_Green_gne__c newMeetGreen = oldMeetGreen.clone(false, true);
	     		newMeetGreen.Meeting_gne__c = newMeeting.Id;
	     		newMeetGreen.Meet_Green_Group_gne__c = meetGreenGrp.get(oldMeetGreen.Meet_Green_Group_gne__c).Id; 
	     		meetGreens.put(oldMeetGreen.Id, newMeetGreen);
	    }
  		clonedObjects.addAll((List<SObject>) meetGreens.values());
		
		Map<Id,CMT_Information_Group_gne__c> informationGroups = new Map<Id,CMT_Information_Group_gne__c>();
		for(SObject obj : getObjectToClone('CMT_Information_Group_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Information_Group_gne__c oldInformationGroup = (CMT_Information_Group_gne__c) obj;
	     		CMT_Information_Group_gne__c newInformationGroup = oldInformationGroup.clone(false, true);
	     		newInformationGroup.Meeting_gne__c = newMeeting.Id;
	     		informationGroups.put(oldInformationGroup.Id, newInformationGroup);	     		
	    }      
	    clonedObjects.addAll((List<SObject>) informationGroups.values());

		insert clonedObjects;
		  	
		for(Id key:hotels.keySet()){
  			ids.put(key,hotels.get(key).Id);
  		}

		for(Id key:shuttles.keySet()){
  			ids.put(key,shuttles.get(key).Id);
  		}

		for(Id key:parkings.keySet()){
  			ids.put(key,parkings.get(key).Id);
  		}
		
		for(Id key:taxCompanies.keySet()){
  			ids.put(key,taxCompanies.get(key).Id);
  		}

		for(Id key:events.keySet()){
  			ids.put(key,events.get(key).Id);
  		}

		for(Id key:exhibits.keySet()){
  			ids.put(key,exhibits.get(key).Id);
  		}

		for(Id key:exposes.keySet()){
  			ids.put(key,exposes.get(key).Id);
  		}

 		for(Id key:meetGreenGrp.keySet()){
  			ids.put(key,meetGreenGrp.get(key).Id);
  		}
  		
      	for(Id key:meetGreens.keySet()){
  			ids.put(key,meetGreens.get(key).Id);
  		}
  		
  		for(Id key:informationGroups.keySet()){
  			ids.put(key,informationGroups.get(key).Id);
  		}
  		
    
      	
      	 
      	
      	Map<String, String> refChildren = new Map<String, String>{'Addresses__r'=>'CMT_Information_Address_gne__c','Yelp_Address__r'=>'CMT_Yelp_Address_gne__c'};
      	 
      	List<SObject> oldInformations= getObjectToCloneFromParent('CMT_Information_gne__c','Meeting_gne__c',chosenMeeting, refChildren);
        
        Map<Id,CMT_Information_gne__c> informations = new Map<Id,CMT_Information_gne__c>();
        Map<Id,CMT_Yelp_Address_gne__c> yelpAddrs = new Map<Id,CMT_Yelp_Address_gne__c>();
        Map<Id,CMT_Information_Address_gne__c> informationAddrs = new Map<Id,CMT_Information_Address_gne__c>();
        
        for(SObject obj:oldInformations){
        	CMT_Information_gne__c oldInformation = (CMT_Information_gne__c) obj;
        	CMT_Information_gne__c newInformation = oldInformation.clone(false,true);
        	newInformation.Meeting_gne__c = newMeeting.Id;
        	newInformation.Group_gne__c = informationGroups.get(oldInformation.Group_gne__c).Id;
        	if(oldInformation.Yelp_Address__r!=null){
        		for(CMT_Yelp_Address_gne__c oldYelpAddr:oldInformation.Yelp_Address__r){
        			CMT_Yelp_Address_gne__c newYelpAddr = oldYelpAddr.clone(false,true);
        			newYelpAddr.Meeting_gne__c = newMeeting.Id;
        			yelpAddrs.put(oldYelpAddr.Id, newYelpAddr);
        		}
        	}
        	if(oldInformation.Addresses__r!=null){
        		for(CMT_Information_Address_gne__c oldInfoAddr:oldInformation.Addresses__r){
        			CMT_Information_Address_gne__c newInfoAddr =oldInfoAddr.clone(false,true);
        			newInfoAddr.Meeting_gne__c = newMeeting.Id;
        			informationAddrs.put(oldInfoAddr.Id, newInfoAddr);
        		}
        	}
        	
        	informations.put(oldInformation.Id, newInformation); 	
        }
        
        insert informations.values();
       	
       	for(CMT_Yelp_Address_gne__c yelp:yelpAddrs.values()){
       		yelp.Information_gne__c = informations.get(yelp.Information_gne__c).Id;
       	}
       	
       	for(CMT_Information_Address_gne__c addr:informationAddrs.values()){
       		addr.Information_gne__c = informations.get(addr.Information_gne__c).Id;
       	}
       	
       	clonedObjects = new List<SObject>();
       	clonedObjects.addAll((List<SObject>) yelpAddrs.values());
        clonedObjects.addAll((List<SObject>) informationAddrs.values());
     	insert clonedObjects;
     	     
        for(Id key:informations.keySet()){
  			ids.put(key,informations.get(key).Id);
  		}
  		
  		for(Id key:yelpAddrs.keySet()){
  			ids.put(key,yelpAddrs.get(key).Id);
  		}
        
        for(Id key:informationAddrs.keySet()){
  			ids.put(key,informationAddrs.get(key).Id);
  		}
        
     
        
        List<CMT_Announcement_gne__c> announcments = new List<CMT_Announcement_gne__c>();
     	

     	for(Sobject obj:getObjectToClone('CMT_Announcement_gne__c','Meeting_gne__c',chosenMeeting)){
     			CMT_Announcement_gne__c oldAnnouncement = (CMT_Announcement_gne__c) obj;
	     		CMT_Announcement_gne__c newAnnouncement = oldAnnouncement.clone(false, true);
	     		newAnnouncement.Meeting_gne__c = newMeeting.Id;
	     		newAnnouncement.Record_Id_gne__c = ids.get(oldAnnouncement.Record_Id_gne__c);
				announcments.add(newAnnouncement);
	     }        
     	      	
        	
		clonedObjects = new List<SObject>();
		clonedObjects.addAll((List<SObject>)announcments);
	
	  	Map<Id,CMT_Attachment_gne__c> attachments = new Map<Id,CMT_Attachment_gne__c>();
		
		String parentIdSet ='';
     	for(Sobject obj:getObjectToClone('CMT_Attachment_gne__c','Meeting_gne__c',chosenMeeting)){
     		CMT_Attachment_gne__c oldAttachment=(CMT_Attachment_gne__c) obj;
     		CMT_Attachment_gne__c newAttachment = oldAttachment.clone(false, true);
		    newAttachment.Meeting_gne__c = newMeeting.Id;
		    newAttachment.Parent_Id_gne__c = ids.get(oldAttachment.Parent_Id_gne__c);
		    attachments.put(oldAttachment.Id,newAttachment);
		    parentIdSet=parentIdSet+',\''+oldAttachment.Id+'\'';
     	}
     	parentIdSet=parentIdSet.replaceFirst(',','');
     	
		clonedObjects.addAll((List<SObject>)attachments.values());
			
		insert clonedObjects;

		List<Attachment> sysAttachments = new List<Attachment>();
		if(attachments.size()>0){
     		String whereCond1='ParentId in ('+parentIdSet+')';
			for(SObject obj:getObjectToClone('Attachment', whereCond1)){
					Attachment oldSysAttachment=(Attachment)obj;
					Attachment newSysAttachment = oldSysAttachment.clone(false,true);
					newSysAttachment.ParentId = attachments.get(oldSysAttachment.ParentId).Id;
					sysAttachments.add(newSysAttachment);			
			}	
		}
		
		insert sysAttachments;
	     			
     	System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>chosenMeeting '+chosenMeeting);   	
     	System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>newMeeting '+newMeeting.Id);
     	String orgURL = ApexPages.currentPage().getUrl();
     	Integer indexApex = orgURL.indexOf('apex');
     	String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String redirectURL = partOneURL + 'apex/CMT_New_Meeting?id='+newMeeting.Id+'&cloned=true';
        PageReference pageRef = new PageReference(redirectURL);
     	pageRef.setRedirect(true);
        return pageRef; 
     }
     
     public PageReference cancel()
     {
        String meetingId = newMeeting.Id;
        
     	System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>meetingId '+meetingId);
     	
     	String cloneParam = ApexPages.currentPage().getParameters().get('cloned');
     	Boolean cloned =Boolean.valueOf((cloneParam!=null && cloneParam!='')?cloneParam:'false');
        	
        if(meetingId == null || meetingId =='' || !editMode)
        {	
            String orgURL = ApexPages.currentPage().getUrl();
            Integer indexApex = orgURL.indexOf('apex');
            String partOneURL = orgURL.substring(0,indexApex);
            String redirectURL = partOneURL + 'apex/CMT_All_Meetings';
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else if(cloned){        	
     		System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>remove meeting '+meetingId);
        	delete newMeeting;      	
         	String orgURL = ApexPages.currentPage().getUrl();
            Integer indexApex = orgURL.indexOf('apex');
            String partOneURL = orgURL.substring(0,indexApex);
            String redirectURL = partOneURL + 'apex/CMT_All_Meetings';
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            String orgURL = ApexPages.currentPage().getUrl();
            Integer indexApex = orgURL.indexOf('apex');
            String partOneURL = orgURL.substring(0,indexApex);
            String redirectURL = partOneURL + 'apex/CMT_Event_Summary_Page?id='+meetingId;
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true); 
            return pageRef;
        }
       
     }
     private List<CMT_Attachment_gne__c> attachments;
     private List<CMT_Announcement_gne__c> announcments;
     
     private List<CMT_Attachment_gne__c> newAttachments;
     private List<CMT_Announcement_gne__c> newAnnouncments;
     
     private void cloneAttachments(String oldMeetingId, String oldParentId, String newMeetingId, String newParentId){    		
	     		for(CMT_Attachment_gne__c oldAttachment:attachments){
					if (oldParentId.equals(oldAttachment.Parent_Id_gne__c)){	     		
		     			CMT_Attachment_gne__c attachment = oldAttachment.clone(false, true);
		     			attachment.Meeting_gne__c = newMeetingId;
		     			attachment.Parent_Id_gne__c = newParentId;
		     			newAttachments.add(attachment);
					}
	     		}
	     		
	     		
	     		
     }
     
    private void cloneAnnouncements(String oldMeetingId, String oldRecordId, String newMeetingId, String newRecordId){  		
	     		for(CMT_Announcement_gne__c oldAnnouncement:announcments){
	     			if(oldRecordId.equals(oldAnnouncement.Record_Id_gne__c)){
	     			CMT_Announcement_gne__c announcement = oldAnnouncement.clone(false, true);
	     			announcement.Meeting_gne__c = newMeetingId;
	     			announcement.Record_Id_gne__c = newRecordId;
					newAnnouncments.add(announcement);
	     			}        		
	     		}
     } 
  	
  	private List<SObject> getObjectToCloneFromParent(String objName, String colName, String colValue, Map<String, String> refChildren){
     	String columns = getObjcCols(objName);
     	String qr= 'SELECT ';
     	String tmp ='';	
     	for(String refName:refChildren.keySet())
     		{	
     			String refChildObj = refChildren.get(refName);
     			String refObjColumns = getObjcCols(refChildObj);
     			tmp = tmp+'(SELECT '+refObjColumns+' FROM '+refName+'),';		 		  	
     		}
        
         qr = qr+tmp+columns+' FROM '+objName +' WHERE '+colName+'=\'' + colValue+'\'';
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>'+qr);
        
        return (List<SObject>) Database.query(qr); 	
    }
          
	private List<SObject> getObjectToClone(String objName, String colName, String colValue, Map<String, String> referencesParentOrLookup){
     	String columns = getObjcCols(objName);
     		
     	for(String refColumnName:referencesParentOrLookup.keySet())
     		{
     			String refObjName = referencesParentOrLookup.get(refColumnName);
     			String refObjColumns = getObjcCols(refObjName);
     			String refName = refColumnName.replace('__c','__r');
     			refObjColumns = refName+'.'+refObjColumns.replace(',',' ,'+refName+'.');
     			columns = columns.replace(refColumnName,refObjColumns);  		 		  	
     		}
        
        String qr= 'SELECT ' + columns + ' FROM '+objName +' WHERE '+colName+'=\'' + colValue+'\'';
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>'+qr);
        
        return (List<SObject>) Database.query(qr); 	
    }
       
    private List<SObject> getObjectToClone(String objName, String condition){
       String columns = getObjcCols(objName);
        String qr= 'SELECT ' + columns + ' FROM '+objName +' WHERE '+condition;
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>'+qr);
        
        return (List<SObject>) Database.query(qr);   
    } 
    
    private List<SObject> getObjectToClone(String objName, String colName, String colValue){
     	String columns = getObjcCols(objName);
        String qr= 'SELECT ' + columns + ' FROM '+objName +' WHERE '+colName+'=\'' + colValue+'\'';
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>'+qr);
        
        return (List<SObject>) Database.query(qr); 	
    }   
    
    private String getObjcCols(String objName){
    
      	String columns = ''; 
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe().Fields.getMap();
        List<String> selectFields = new List<String>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){
                Schema.DescribeFieldResult fd = ft.getDescribe();
                if (fd.isCreateable()){
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                	columns += s + ',';               
            }
            	columns = columns.substring(0,columns.lastIndexOf(','));             
        }
    	return columns;
    }
    public Boolean hasNext {
		get {
			return controller.getHasNext();
		}
		set;
	}
 
	// indicates whether there are more records before the current page set.
	public Boolean hasPrevious {
		get {
			return controller.getHasPrevious();
		}
		set;
	}
 
	// returns the page number of the current page set
	public Integer pageNumber {
		get {
			return controller.getPageNumber();
		}
		set;
	}
		
 	public void first() {
 		chooseMeeting=true;
 		controller.first();
 	}
 	public void last() {
 		chooseMeeting=true;
 		controller.last();
 	}
 	
 	public void previous() {
 		chooseMeeting=true;
 		controller.previous();
 	}
 	public void next() {
 		chooseMeeting=true;
 		controller.next();
 	}
 	
 	public PageReference showAllMeetings()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_All_Meetings';
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
}