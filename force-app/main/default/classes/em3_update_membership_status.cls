public class em3_update_membership_status {
    
    public static void contracted_status(List<Speaker_Contract_gne__c> contracts, set<ID> related_accounts){
        //to hold the list of membership records to update
        List<Speaker_Bureau_Membership_gne__c> updates = new List<Speaker_Bureau_Membership_gne__c>();
        
        //creates a list of membership records which relate to an account and in which the speaker status = 'reviewed'
        //or 'approved'
        List<Speaker_Bureau_Membership_gne__c> members = [select ID, Speaker_status_gne__c, Contract_End_Date_gne__c,
        Contract_Start_Date_gne__c, Bureau_Member_gne__c from Speaker_Bureau_Membership_gne__c where 
        Bureau_Member_gne__c IN  :related_accounts and (Speaker_Status_gne__c = 'Reviewed' or Speaker_Status_gne__c = 'Approved') for update];
        
            
        if(members.size() > 0){                 
        
            Map<ID, List<Speaker_Bureau_Membership_gne__c>> id_to_memberships = new Map<ID, List<Speaker_Bureau_Membership_gne__c>>();              
            
            //create a map for each membership record mapping an account id to it's list of memberships records
            for(Speaker_Bureau_Membership_gne__c membership : members){
                if(!id_to_memberships.keySet().contains(membership.Bureau_member_gne__c)){
                    id_to_memberships.put(membership.Bureau_member_gne__c,new List<Speaker_Bureau_Membership_gne__c>());
                }
                id_to_memberships.get(membership.Bureau_member_gne__c).add(membership);
            }       
            
            
            //for all contracts in the trigger, return the related list of membership associated to the 
            //speaker on the contract and update the membership record 
            for(Speaker_Contract_gne__c contract: contracts){           
                List<Speaker_Bureau_Membership_gne__c> membership = id_to_memberships.get(contract.Contracted_Party_ID__c);
                for(Speaker_Bureau_Membership_gne__c mem : membership){
                    if(mem.Contract_End_Date_gne__c == contract.begin_date_gne__c && mem.contract_end_date_gne__c == contract.end_date_gne__c){
                        mem.Speaker_Status_gne__c = 'Contracted';
                        mem.Contract_Start_Date_gne__c = contract.begin_Date_gne__c;
                        mem.Contract_End_Date_gne__c = contract.end_date_gne__c;
                        updates.add(mem);       
                    }               
                }           
            }
        }
        try{
            update(updates);            
        }catch(DmlException e){
            System.debug(e.getMessage());
        }        
    }
}