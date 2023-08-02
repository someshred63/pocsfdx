public class SPLOA_MCC_Req_Controller {
    
    map<string,string> stateCodes= new map<string,string>();
    
    public Map<String,String> statepicklistvalues{
        get {
            if (statepicklistvalues == null) {
                
                statepicklistvalues = new Map<String,String>();
                Schema.DescribeFieldResult field = C_ops_MCC_Request__c.State__c.getDescribe();
                
                for (Schema.PicklistEntry f : field.getPicklistValues())
                    statepicklistvalues.put(f.getLabel().touppercase(),f.getLabel().touppercase());
                
            }
            
            return statepicklistvalues;          
        }
        set;
    }
    
    public void checkfordupe(List<C_ops_MCC_Request__c> oldList , List<C_ops_MCC_Request__c> newList){
        for(C_ops_MCC_Request__c mccreq : newList){
            /*
if(isValidDEA(mccreq.DEA_Number__c) == false){
mccreq.addError('Invalid DEA');
}
*/
            if(isValidZip(mccreq.ZIP__c) == false){
                mccreq.addError('Invalid ZIP');
            }
            if(mccreq.Effective_Date__c > mccreq.Anticipated_termination_Date__c){
                mccreq.addError('Effective Date should be earlier than Anticipated Termination Date');
            }
            if(mccreq.State__c != null){
                loadStateCodes();
                if(stateCodes.containsKey( mccreq.State__c.touppercase())){ 
                    mccreq.State__c = stateCodes.get(mccreq.State__c.touppercase());
                }
                if(!stateCodes.containsKey( mccreq.State__c.touppercase()) && !statepicklistvalues.containsKey(mccreq.State__c.touppercase())
                  ){
                      mccreq.addError('Invalid State');
                  }
            }
        }
    }
    
    public boolean isValidZip(string z){        
        if(z.length() == 0){            
            return false;
        }
        
        Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
        Matcher zipMatcher = ZipCodeChecker.matcher(z);
        
        return (zipMatcher.matches());            
    }
    /*
public boolean isValidDEA(string z){        
if(z.length() == 0 ){            
return false;
}

Pattern zipCodeChecker = Pattern.compile('[a-zA-Z]{2}[0-9]{7}');
Matcher zipMatcher = ZipCodeChecker.matcher(z);

return (zipMatcher.matches());            
}
*/
    public void loadStateCodes(){
        if(stateCodes!=null && stateCodes.size()>0) return;
        stateCodes.put('AL', 'Alabama');
        stateCodes.put('AK', 'Alaska');
        stateCodes.put('AZ', 'Arizona');
        stateCodes.put('AR', 'Arkansas');
        stateCodes.put('CA', 'California');
        stateCodes.put('CO', 'Colorado');
        stateCodes.put('CT', 'Connecticut');
        stateCodes.put('DE', 'Delaware');
        stateCodes.put('DC', 'District of Columbia');
        stateCodes.put('FL', 'Florida');
        stateCodes.put('GA', 'Georgia');
        stateCodes.put('HI', 'Hawaii');
        stateCodes.put('ID', 'Idaho');
        stateCodes.put('IL', 'Illinois');
        stateCodes.put('IN', 'Indiana');
        stateCodes.put('IA', 'Iowa');
        stateCodes.put('KS', 'Kansas');
        stateCodes.put('KY', 'Kentucky');
        stateCodes.put('LA', 'Louisiana');
        stateCodes.put('MA', 'Massachusetts');
        stateCodes.put('ME', 'Maine');
        stateCodes.put('MD', 'Maryland');
        stateCodes.put('ME', 'Massachusetts');
        stateCodes.put('MI', 'Michigan');
        stateCodes.put('MN', 'Minnesota');
        stateCodes.put('MS', 'Mississippi');
        stateCodes.put('MO', 'Missouri');
        stateCodes.put('MT', 'Montana');
        stateCodes.put('NE', 'Nebraska');
        stateCodes.put('NV', 'Nevada');
        stateCodes.put('NH', 'New Hampshire');
        stateCodes.put('NJ', 'New Jersey');
        stateCodes.put('NM', 'New Mexico');
        stateCodes.put('NY', 'New York');
        stateCodes.put('NC', 'North Carolina');
        stateCodes.put('ND', 'North Dakota');
        stateCodes.put('OH', 'Ohio');
        stateCodes.put('OK', 'Oklahoma');
        stateCodes.put('OR', 'Oregon');
        stateCodes.put('PA', 'Pennsylvania');
        stateCodes.put('PR', 'Puerto Rico');
        stateCodes.put('RI', 'Rhode Island');
        stateCodes.put('SC', 'South Carolina');
        stateCodes.put('SD', 'South Dakota');
        stateCodes.put('TN', 'Tennessee');
        stateCodes.put('TX', 'Texas');
        stateCodes.put('UT', 'Utah');
        stateCodes.put('VT', 'Vermont');
        stateCodes.put('VA', 'Virginia');
        stateCodes.put('WA', 'Washington');
        stateCodes.put('WV', 'West Virginia');
        stateCodes.put('WI', 'Wisconsin');
        stateCodes.put('WY', 'Wyoming');        
    }
    
}