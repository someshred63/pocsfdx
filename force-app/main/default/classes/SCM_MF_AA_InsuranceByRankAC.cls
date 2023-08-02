public class SCM_MF_AA_InsuranceByRankAC extends SCM_MergeField{
public SCM_MF_AA_InsuranceByRankAC(Case SelectedCase,string Rank)
	{
		 Case SelCase = SelectedCase;
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		key = 'AA_InsuranceName' + Rank;
		displayLabel = false;
		
		try {
			List<Insurance_gne__c> Ins = [Select i.Payer_gne__r.name, Payer_gne__r.Record_Type_Text_GNE__c,ins_Network_IPA_gne__c,ins_Network_IPA_gne__r.Name From Insurance_gne__c i where Case_Insurance_gne__c = :SelectedCase.id and Rank_gne__c = :Rank];
			if (Ins.size() == 1) {
				fieldvalue = Ins[0].Payer_gne__r.name == null? '': Rank + ':' + Ins[0].Payer_gne__r.name;
				if (Ins[0].ins_Network_IPA_gne__c != null) {
						
				fieldvalue += '\r\nNetwork/IPA:' + Ins[0].ins_Network_IPA_gne__r.name;
					
				} 
			}
			else if (Ins.size() > 1)
			{
				List<Insurance_gne__c> InsPMB = new List<Insurance_gne__c>();
				List<Insurance_gne__c> InsNoPMB = new List<Insurance_gne__c>();
				
				//filter by pbm
				for(Insurance_gne__c i : Ins) 
				{
					if (i.Payer_gne__r.Record_Type_Text_GNE__c != null)
					{
						if (i.Payer_gne__r.Record_Type_Text_GNE__c == 'PBM') 
						{
							InsPMB.add(i);
						}
						else 
						{
							InsNoPMB.add(i);							
						}
					}
					
				}
				//create list non pbm first
				fieldValue = Rank + ':';
				string ipa = '';
				for(Insurance_gne__c i : InsNoPMB) 
				{
					fieldValue +=  i.Payer_gne__r.name;
					if (i.ins_Network_IPA_gne__c != null) {
						
						ipa +=  i.ins_Network_IPA_gne__r.name + ', ';
					
						} 
						
					fieldValue += '/';
				} 
				for(Insurance_gne__c i : InsPMB) 
				{
					fieldValue +=  + i.Payer_gne__r.name ;
					if (i.ins_Network_IPA_gne__c != null) {
						
						ipa += i.ins_Network_IPA_gne__r.name + ', ';
						} 
						
				
					
					fieldValue += '/';
				}
				//remove the last "/"
			fieldvalue = fieldValue.substring(0, fieldvalue.length() - 1);
				   if (ipa.length() > 0){
				   ipa = '\r\nNetwork/IPA:' + ipa.substring(0, ipa.length() - 2);
				
				fieldvalue += ipa;
				   }
			}
			else 
			{
				fieldValue = '';
			}
			
			
			
		}
		catch (exception ex){
			fieldvalue = '';	
		}
	}
}