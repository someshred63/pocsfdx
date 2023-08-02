public with sharing class SFA_sendInteractionEmail {
 
            public String subject { get; set; }
            public String body { get; set; }
            public String addbody { get; set; }
            public String accId;
            
            
            public SFASearch_gne__c eId1 {get; set;}
            public SFASearch_gne__c eId2 {get; set;}
            public SFASearch_gne__c eId3 {get; set;}
            public SFASearch_gne__c eId4 {get; set;}
            public SFASearch_gne__c eId5 {get; set;}
           
            public List<Call2_vod__c> call2;
            public List<Call2_Discussion_vod__c> Call2_Discussions;
            public List<Call2_vod__c> Call2_Attendees;
            
            PageReference accountPage = ApexPages.currentPage();
            public String currPageURL = accountPage.getParameters().get('accid');
            public String accPageURL = currPageURL;
            
            public void intIT() {
	            	getInterlist();
	            	eId1 = new SFASearch_gne__c();
	            	eId2 = new SFASearch_gne__c();
	            	eId3 = new SFASearch_gne__c();
	            	eId4 = new SFASearch_gne__c();
	            	eId5 = new SFASearch_gne__c(); 
	                return ; 
              }
            
            //To generate Interaction list
            List<Call2_vod__c>  interlist;
            public List<Call2_vod__c> getInterlist() {
	                try{
	                String qur = 'select ID, Purpose_of_Meeting_gne__c, Date_of_Interaction_gne__c, Detailed_Products_vod__c, Name from Call2_vod__c where Account_vod__c =\''+ accPageURL +'\'and parent_Call_vod__c = null Order By call_Date_vod__c DESC limit 1000';
                    System.debug('@#@#@##interlist: '+ qur);
	                interlist  =  [select ID, Purpose_of_Meeting_gne__c, call_Date_vod__c, Date_of_Interaction_gne__c, Detailed_Products_vod__c, Name from Call2_vod__c where Account_vod__c =: accPageURL and parent_Call_vod__c = null Order By call_Date_vod__c DESC limit 1000 ];// '0017000000WRtMi'];
	                System.debug('List Size: '+ interlist.size());
	                }catch (ListException e) { System.debug(e); }
	                catch (Exception e) { System.debug(e); }
	                return interlist;
            }
            
            String inter;
            public String getInter() {return inter; }
            public void setInter(String inter) { this.inter = inter; setEmailBody(inter);}
            
            
            public List<SelectOption> getInteractions() {
                    System.debug('Reached here: 1');           
                    List<SelectOption> interoptions = new List<SelectOption>();
                     try{
                         if(interlist != NULL)
                          {
                            interoptions.add(new SelectOption('','--SELECT INTERACTION--'));
                            System.debug('Reached here: 2');   
                            for (Integer i = 0; i < interlist.size(); i++){
                                if (interlist[i].Purpose_of_Meeting_gne__c != null){ 
                                   System.debug('Reached here: 3-'+i);   
                                   try {
	                                   	Integer n ;
	                                    n = interlist[i].Purpose_of_Meeting_gne__c.length();
	                                   	if(n >50)
	                                    { 
	                                   	  n = 50;
	                                    }
	                                    interoptions.add(new SelectOption(interlist[i].ID, String.valueOf(interlist[i].call_Date_vod__c)+' - '+interlist[i].Purpose_of_meeting_gne__c.substring(0,n)));
	                                    //interoptions.add(new SelectOption(interlist[i].ID, interlist[i].Date_of_Interaction_gne__c+' - '+interlist[i].Purpose_of_meeting_gne__c));
                                   }catch(StringException e) { System.debug(e); }
                                }
                                else{ 
                                	System.debug('Reached here: 4-'+i);
                                	interoptions.add(new SelectOption(interlist[i].ID, String.valueOf(interlist[i].call_Date_vod__c)));
                               }
                            } 
                          } 
                         } catch (ListException e) { System.debug(e); }// List Exception handling code here 
                           catch (Exception e) { System.debug(e); }
                         System.debug('Reached here: 5');
                         return interoptions;
                   }// Interaction list Ends here
            
           
            //To create email body text
            public void setEmailBody(String interactionID){
            
		                String ID_gne = 'a04Q0000000p7kBIAQ';  String attendessnames = ''; String usrGroupName = '%PFT%';
		                if(interactionID != 'none'){ 
		                       
			                    //Query to determine Interaction on call:
			                    String queryString = 'select Name, Account_vod__r.name, Contact_vod__r.name, Date_of_Interaction_gne__c, Purpose_of_Meeting_gne__c, Ideal_Outcomes_gne__c, Agenda_gne__c, Meeting_Outcome_gne__c, Next_Steps_gne__c, Detailed_Products_vod__c from Call2_vod__c where Id =\''+ interactionID +'\'';
			                    //Query to determine product discussion
			                    System.debug('@#@#queryString:'+ queryString);
			                    String queryDiscussions = 'select Activity_gne__c, Contract_Round_gne__c, Discussion_Message_gne__c, Program_gne__c, Portfolio_Material_gne__c, Promotional_Material_gne__c, Video_series_gne__c, call2_vod__r.owner.profile.name, recordtype.name, user_vod__r.name from Call2_Discussion_vod__c where call2_vod__r.Id =\''+ interactionID +'\'';
			                    System.debug('@#@#queryDiscussions:'+ queryDiscussions);
			                    //Query to determine attendees on call:
			                    String queryCall2_Attendees = 'select parent_call_vod__c, account_vod__r.name, contact_vod__r.name from Call2_vod__c where parent_call_vod__c =\''+interactionID +'\'';
			                    System.debug('@#@#queryCall2_Attendees:'+ queryCall2_Attendees);
				                            //make db query 
						                            try {
						                                    Call2 = Database.query(queryString);
						                                    System.debug('Qry1: '+queryString);
						                                    Call2_Discussions = Database.query(queryDiscussions);
						                                    System.debug('Qry2: '+ queryDiscussions);
						                                    Call2_Attendees = Database.query(queryCall2_Attendees); 
						                                    System.debug('Qry3: '+queryCall2_Attendees);
						                                }catch (ListException e) { System.debug(e); }// List Exception handling code here 
						                            catch (Exception e) { System.debug(e); }
						                            System.debug('A---');
						                            // Replace null results with blank space
						                            for (Integer j=0; j < Call2_Attendees.size() ; j++)     { System.debug('B---');
						                              if(Call2_Attendees[j].account_vod__r != null && Call2_Attendees[j].account_vod__r.name != null){ System.debug('C---');
						                              	 attendessnames += '\n\t'+Call2_Attendees[j].account_vod__r.name; System.debug('After: '+attendessnames); 
						                              }
						                              else{
						                                if(Call2_Attendees[j].contact_vod__r != null && Call2_Attendees[j].contact_vod__r.name != null ){System.debug('D---');
						                                	 attendessnames += '\n\t'+Call2_Attendees[j].contact_vod__r.name; 
						                                }
						                              }
						                           } 
				            if(Call2[0].Purpose_of_Meeting_gne__c == null) {Call2[0].Purpose_of_Meeting_gne__c = '---';}System.debug('E---');
				            if(Call2[0].Ideal_Outcomes_gne__c == null) {Call2[0].Ideal_Outcomes_gne__c = '---';}System.debug('F---');
				            if(Call2[0].Agenda_gne__c == null) {Call2[0].Agenda_gne__c = '---';}System.debug('G---');
				            if(Call2[0].Meeting_Outcome_gne__c == null) {Call2[0].Meeting_Outcome_gne__c = '---';}System.debug('H---');
				            if(Call2[0].Next_Steps_gne__c == null) {Call2[0].Next_Steps_gne__c = '---';}System.debug('I---');
				            System.debug('Discussion isnull' + Call2_Discussions == null);
				            System.debug('Discussion size' + Call2_Discussions.size() );
				            string Discussions='';
				            if(Call2_Discussions.size() > 0 && Call2_Discussions[0].Discussion_Message_gne__c != null) {
				            		for (integer i=0; i<Call2_Discussions.size(); i++)
				                                Discussions += '\n\t'+Call2_Discussions[i].Discussion_Message_gne__c;
				            }else{
				                            	Discussions = 'No discussion in Interaction';
				                  }
				            System.debug('J---');
				            if(attendessnames == null) { 
				            	attendessnames = '---';
				            }System.debug('K---');
			                
					    //Attach all query results to body text 
					        body = '\n\n* Interaction Name: '+ Call2[0].Name+'\n\n* Account Name: '+Call2[0].Account_vod__r.name+
					                  '\n\n* Date Of Interaction: '+Call2[0].Date_of_Interaction_gne__c+'\n\n* Purpose of Meeting: '+
					                   Call2[0].Purpose_of_Meeting_gne__c+'\n\n* Ideal Outcome: '+Call2[0].Ideal_Outcomes_gne__c+
					                  '\n\n* Agenda: '+Call2[0].Agenda_gne__c+'\n\n* Meeting Outcome: '+Call2[0].Meeting_Outcome_gne__c+
					                  '\n\n* Next Steps: '+Call2[0].Next_Steps_gne__c+'\n\n* Products Discussed: '+
					                  Discussions+'\n\n* Actual Attendees: '+attendessnames; 
					           System.debug('Email body ----------: '+body ); 
		                }
		                else
		                {
				               body = 'No details Available  '; 
				               subject = 'Interaction Details';
				               System.debug('No Email body ----------: '+body ); 
		                } 
            }
            
           public pageReference cancel() {
		       
			          PageReference accPage = new PageReference('/'+accPageURL);
			          accPage.setRedirect(true);
			          return accPage;
		    }
           
            public PageReference send() {
			                   // Define the email
			                   System.debug('@@@@2');
			                   Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			                
			                   String addresses;
			                   if(this.eId1.OwnerId == null){  
				     				 system.debug('I am there');              
				      				 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select an Email Address'));
				      				 return null;
			    			   }else{
				                	User a_x = new User();User b_x = new User();User c_x = new User();User d_x = new User();User e_x = new User();
							    	a_x = [select ID, Email from User where id = :this.eId1.OwnerId limit 1];
							    if(this.eId2.OwnerId != null)
							     	b_x = [select ID, Email from User where id = :this.eId2.OwnerId limit 1];
							    if(this.eId3.OwnerId != null)
							    	c_x = [select ID, Email from User where id = :this.eId3.OwnerId limit 1];
							    if(this.eId4.OwnerId != null)
							    	d_x = [select ID, Email from User where id = :this.eId4.OwnerId limit 1];
							    if(this.eId4.OwnerId != null)
							    	d_x = [select ID, Email from User where id = :this.eId4.OwnerId limit 1];
							    addresses = a_x.Email;
							    if(b_x != null && b_x.email != null)
							    	addresses = addresses+':'+b_x.Email;
							    if(c_x != null && c_x.email != null)
							    	addresses = addresses+':'+c_x.Email;
							    if(d_x != null && d_x.email != null)
							    	addresses = addresses+':'+d_x.Email;
							    if(e_x != null && e_x.email != null)
							    	addresses = addresses+':'+e_x.Email;
							    if(addresses == null){
							    	 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select an Email Address'));
				      				 return null;
							    }
							     
							    System.debug('Address are:'+addresses);
			                }
			                
			                String[] toAddresses = addresses.split(':', 0);
			                
			                // Sets the paramaters of the email
			                email.setSubject( subject );
			                email.setToAddresses( toAddresses );
			                email.setPlainTextBody( body+'\n\n Additional Information: '+addbody );
			                
			                // Sends the email
			                try{
			                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
			                }catch (ListException e) { System.debug(e); }// List Exception handling code here 
			                 catch (Exception e) { System.debug(e); }
			                
			                PageReference accPage = new PageReference('/'+accPageURL);
			                accPage.setRedirect(true);
			                return accPage;
	        }
          
	        // Create a constructor that populates the Account object
	        public SFA_sendInteractionEmail(ApexPages.StandardController stdController) {
	            
			            	System.debug('#@#@myId is :'+''+currPageURL+''+accPageURL);
			            	intIT();
				            System.debug('@@@@#2');
			    	        setEmailBody('none');
			            }
 }