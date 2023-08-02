//Added By: Rajesh Sinha
//Condition as folllows:-->
//If Case.Product <> Nutropin OR Rituxan RA, then merge Case.Product
//Else
//If Case.Product = Nutropin, then
//Join Case to Medical History and if Medical History.Drug = 
//Nutropin 1x10 mg, then merge "Nutropin"
//Nutropin 1x5 mg, then merge "Nutropin"
//Nutropin AQ 1x10 mg, then merge "Nutropin AQ"
//Nutropin AQ Cartridge 1x10 mg, then merge "NAQ Cartridge"
//Nutropin AQ Cartridge 1x20 mg, then merge "NAQ Cartridge"
//Nutropin Depot, then merge "Nutropin Depot"
//If Case.Product = Rituxan RA, then merge "Rituxan"

public class SCM_MF_Drug_Tnk  extends SCM_MergeField {
    protected Case DrugHistoryList;
    private String case_Id;
    private String productType;
    
    public SCM_MF_Drug_Tnk (Case selectedCase) {
        key = 'Drug_Tnk';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_Drug_Tnk';
        case_Id = selectedCase.id;
        productType = selectedCase.Product_gne__c ;
     }
   
    public override String getFieldValue() {
        if((productType != 'Nutropin') ||(productType != 'Rituxan RA') ){
        	fieldValue = productType;
        }
        
        else{
        	if(productType == 'Nutropin'){
        		List<Case> DrugHistory = [Select c.Medical_History_gne__r.Drug_gne__c, 
        		c.Medical_History_gne__c, c.Id From Case c where  c.Id = :case_Id Limit 100];
      			
      			if(DrugHistory.size() > 0){
      			DrugHistoryList = DrugHistory[0];
      				
      				if(DrugHistoryList.Medical_History_gne__r.Drug_gne__c == 'Nutropin 1x10 mg') {
      					fieldValue = 'Nutropin';
      				}
      		        else if (DrugHistoryList.Medical_History_gne__r.Drug_gne__c == 'Nutropin 1x5 mg') {
      		        	fieldValue = 'Nutropin';
      		        }
      		        else if (DrugHistoryList.Medical_History_gne__r.Drug_gne__c == 'Nutropin AQ 1x10 mg') {
      		        	fieldValue = 'Nutropin AQ';
      		        }
      		        else if (DrugHistoryList.Medical_History_gne__r.Drug_gne__c == 'AQ Cartridge 1x10 mg') {
      		        	fieldValue = 'NAQ Cartridge';
      		        }
      		        else if (DrugHistoryList.Medical_History_gne__r.Drug_gne__c == 'AQ Cartridge 1x20 mg') {
      		        	fieldValue = 'NAQ Cartridge';
      		        }
      		        else if (DrugHistoryList.Medical_History_gne__r.Drug_gne__c == 'Depot') {
      		        	fieldValue = 'Nutropin Depot';
      		        }
      			}
      			else if(productType == 'Rituxan RA')
      				fieldValue = 'Rituxan';
      				
      			
        	}
       				
        }
        return fieldValue;
    }
}