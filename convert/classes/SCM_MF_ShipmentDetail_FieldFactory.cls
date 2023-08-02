public class SCM_MF_ShipmentDetail_FieldFactory {
    private static Shipment_gne__c shipmentDetail;
    
    
    private static Shipment_gne__c getShipmentDetail(Case selectedCase)
    {
        if( shipmentDetail == null )
        {
            try{
               List<Shipment_gne__c> shipmentDetailList = 
                [select c.Quantity_1_gne__c, Order_Number_gne__c, Name, Name_gne__c
                 from Shipment_gne__c c
                 where c.Case_Shipment_gne__c = :selectedCase.Id
                 order by c.LastModifiedDate desc];
           
                if(shipmentDetailList.size()>0)
                    shipmentDetail=shipmentDetailList[0];
            }catch(Exception e){
                System.debug('Inside Catch of getShipmentDetail...Message:' + e.getMessage());
                return null;
            }
         }
        return shipmentDetail;
    }
    
    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        
        return mf;
    }
    
    public static SCM_MergeField DocumentNumber(Case selectedCase)
    {
    	SCM_MergeField mf = createMergeField('Documentnumber');
    
     try {
        
        mf.fieldValue='';
        if( getShipmentDetail(selectedCase)!=null && 
            getShipmentDetail(selectedCase).Order_Number_gne__c!=null )
        {
            mf.fieldValue = getShipmentDetail(selectedCase).Order_Number_gne__c;
        }}
        catch(exception ex){
        	mf.fieldValue = '';
        }
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false; 
       
        return mf;
    }
    
    public static SCM_MergeField PurchaseNumber(Case selectedCase)
    {
    	SCM_MergeField mf = createMergeField('Purchasenumber');
    try {
        System.debug('ShipId in factory ' + getShipmentDetail(selectedCase).Id);
        
        mf.fieldValue='';
        if( getShipmentDetail(selectedCase)!=null && 
            getShipmentDetail(selectedCase).Name!=null )
        {
            mf.fieldValue = 'PO-' + getShipmentDetail(selectedCase).Name;
        }}
       catch(exception ex){
        	mf.fieldValue = '';
        }
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false; 
        return mf;
    }
    
}