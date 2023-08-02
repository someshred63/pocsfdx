public class GNE_AP_Account_Ctrl {  
    public AP_Account_gne__c apAccount{get;set;}
    public List<Row> rows{get;set;}
    public Integer saveRow{get;set;}
        
    public GNE_AP_Account_Ctrl(ApexPages.StandardController controller){
        rows= new List<Row>();
        AP_Account_gne__c apAcc = (AP_Account_gne__c)controller.getRecord();
        if(apAcc != null && apAcc.Id != null){
            List<AP_Detail_gne__c> result = GNE_AP_DAO.getAccountPlanDetailsForAccount(apAcc.Id);
            if(result!=null&&result.size()>0){
                for(Integer i=0; i < result.size(); i++){
                    rows.add(new Row(result.get(i), i));            
                }
            }
        }else{
            apAccount = new AP_Account_gne__c();
        }
    }
    
    public void addRow(){
        Integer size = rows.size();
        rows.add(new Row(new AP_Detail_gne__c(AP_Account_gne__c = apAccount.Id ),size));
    }
    
    public PageReference saveAccPlan(){
      if(saveRow!=null){
          Database.upsert(rows.get(saveRow).record);
      }
      return null;  
    }
    
    public class Row{
       public AP_Detail_gne__c record{get;set;}
       public Integer id{get;set;}
       public Row(AP_Detail_gne__c record,Integer id){
           this.record = record;
           this.id = id;
       }  
    }
}