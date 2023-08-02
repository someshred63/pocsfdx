global class New_Speaker_Contract_WS {

	global class Messages {
		webservice String Status;
		webservice String Message;
	}	
	
	//Define an object in apex that is exposed in apex web service
   global class New_Contract {
   	  webservice String ID; //ask about where to map this
   	  webservice String Bureau_ID;
   	  webservice String Contract_Works_Template_ID;
      webservice String Contract_Works_Template_Desc;
      webservice String vendor_agreement_ID;
      webservice String Parent_Agreement_ID;
      webservice Date begin_date;
      webservice Date end_date;
      webservice Date sign_date;
	  webservice String Agreement_Party_Type_Code;
	  webservice String Agreement_Type_Code;
	  webservice String amendment_type_code;
	  webservice String Contracted_Party_Name;
	  webservice String Contracted_Party_ID;
	  webservice String Speaker_Classification;
	  webservice String status_code;
	  webservice String Street_Address;
	  webservice String City;
	  webservice String State;
	  webservice String ZIP_Code;
	  webservice String Country;	  	  
	  webservice String Business_Unit;
	  webservice String brands; //multiple brands csv style
	  webservice String Created_By;
	  webservice Date Created_Date;
	  webservice String Vendor_Name;
	  //add line item object as list within contract
	  webservice List<New_Contract_line_item> line_items;
   }
   
   global class New_Contract_line_item {
      webservice String service_fee_category_code;
      webservice Double activity_pricing_term_amount;      	  	  	  	              
   }      
	
	webservice static Messages create_new_contract(New_Contract nc){
		Messages msg = new Messages();
		
		if(nc.Contracted_Party_ID == null){
			msg.Status = 'FAILURE';
			msg.Message = 'NO CONTRACTED PARTY ID TO PROCESS';
			return msg;
		}
				
		if(!em3_utils.party_check(nc)){
			msg.Status = 'FAILURE';
			msg.Message = 'CHECK FOR VALID PARTY ID\'S FAILED';
			return msg;
		}
		
		if(!em3_utils.required_fields_check(nc)){
			msg.Status = 'FAILURE';
			msg.Message = 'CHECK FOR REQUIRED FIELDS FAILED';
			return msg;	
		}
				
		Speaker_Contract_gne__c contract = em3_utils.ins_upd_contract(nc);
		
		try {
			upsert contract;
		} catch (System.DmlException e){
			system.debug(LoggingLevel.ERROR, e.getMessage());
			msg.Status = 'FAILURE';
			msg.Message = 'INS/UPD CONTRACT ERROR:'+e.getMessage();
			return msg;				
		}
		
		List<Speaker_Contract_Line_Item_gne__c>contractLineItemsToDelete = [SELECT id FROM Speaker_Contract_Line_Item_gne__c WHERE Speaker_Contract_gne__r.vendor_agreement_ID_gne__c= :contract.vendor_agreement_ID_gne__c];
		delete contractLineItemsToDelete;
		
		if(nc.line_items != null){
			List<Speaker_Contract_Line_Item_gne__c>contract_line_items_list = em3_utils.ins_line_items(nc.line_items, contract);
			try {
				upsert contract_line_items_list;
			}catch(System.DMLException e){
				system.debug(LoggingLevel.ERROR, e.getMessage());
				msg.Status = 'FAILURE';
				msg.Message = 'INS/UPD LINE ITEMS ERROR:'+e.getMessage();
				return msg;	
			}
		}
		
		String status = em3_utils.tie_contracts_to_memberships(contract, nc.Bureau_ID, nc.Contracted_Party_ID);
		if(status != 'SUCCESS'){
			List<String> error = status.split(',');
			msg.status = error[0];
			msg.Message = error[1];
			return msg;
		}	 		
		
		msg.Status = 'SUCCESS';
		msg.Message = '';	
		return msg;
	}
}