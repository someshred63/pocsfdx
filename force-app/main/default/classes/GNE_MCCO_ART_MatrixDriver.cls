public with sharing class GNE_MCCO_ART_MatrixDriver {

    //Created By Chatham Reed/ Will Larter of Veeva Systems for November 2009 SFA R2 Release 
    //Version #: 1
    //Date: 8/7/2009

    
    //Begin Code:    
        
    //Maps to hold all LMIs for a paticular ART Site
    List<ART_Issue_gne__c> lmi_list = new List<ART_Issue_gne__c>();
    List<ART_Site_gne__c> art_rectypeid = new List<ART_Site_gne__c>();
    List<RecordType> rectypeids = new List<RecordType>();
    ID art_id;
    
    
    List<ART_Issue_gne__c> c1 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> c2 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> c3 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> b1 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> b2 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> b3 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> a1 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> a2 = new List<ART_Issue_gne__c>();
    List<ART_Issue_gne__c> a3 = new List<ART_Issue_gne__c>();
    
    
    public GNE_MCCO_ART_MatrixDriver(ApexPages.StandardController controller) {
        art_id = Apexpages.currentPage().getParameters().get('id');
        
        //pull back the ART Site Id/ RecTypeId
        art_rectypeid = [select id, recordtypeid from ART_Site_gne__c Where id=:art_id limit 1];
        
        //Query for the ART Site Record Types
        rectypeids = [select id, name from RecordType Where sObjectType='ART_Site_gne__c' and isActive=true];
        
        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String,String> artrectypemap = new Map<String,String>{};
        for (RecordType rt: rectypeids)
            artrectypemap.put(rt.Name,rt.Id);

        
        //Determine what type of ART Site user is on and run the appropriate query to populate the ART Site Matrix
        if(art_rectypeid[0].recordtypeid==artrectypemap.get('Local Market ART Site')){
            //use ART_Site_Local_gne__c to query as this is for a Local ART Site Matrix
            lmi_list=[select id, name, Matrix_Coordinate_gne__c from ART_Issue_gne__c where ART_Site_Local_gne__c =:art_id and Issue_Status_gne__c='Open'];
            
        }else if(art_rectypeid[0].recordtypeid==artrectypemap.get('National ART Site')){
            //use ART_Site_Local_gne__c to query as this is for a Local ART Site Matrix            
            lmi_list=[select id, name, Matrix_Coordinate_gne__c from ART_Issue_gne__c where ART_Site_National_gne__c =:art_id and Issue_Status_gne__c='Open'];
            
        }else if(art_rectypeid[0].recordtypeid==null){
            //error case, no record type assigned, use ART_Site_Local_gne__c to query          
            lmi_list=[select id, name, Matrix_Coordinate_gne__c from ART_Issue_gne__c where ART_Site_Local_gne__c =:art_id and Issue_Status_gne__c='Open'];
        }
        
        
        for (ART_Issue_gne__c a_x : lmi_list){
            if (a_x.Matrix_Coordinate_gne__c != null){
                if (a_x.Matrix_Coordinate_gne__c.contains('A1')) {
                    a1.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('A2')) {
                    a2.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('A3')) {
                    a3.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('B1')) {
                    b1.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('B2')) {
                    b2.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('B3')) {
                    b3.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('C1')) {
                    c1.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('C2')) {
                    c2.add(a_x);
                }
                if (a_x.Matrix_Coordinate_gne__c.contains('C3')) {
                    c3.add(a_x);
                }
            }
            
        }
        
        
    }
    public List<ART_Issue_gne__c> getc1 () {
        return c1;
    }
    public List<ART_Issue_gne__c> getc2 () {
        return c2;
    }
    public List<ART_Issue_gne__c> getc3 () {
        return c3;
    }
    public List<ART_Issue_gne__c> getb1 () {
        return b1;
    }
    public List<ART_Issue_gne__c> getb2 () {
        return b2;
    }
    public List<ART_Issue_gne__c> getb3 () {
        return b3;
    }
    public List<ART_Issue_gne__c> geta1 () {
        return a1;
    }
    public List<ART_Issue_gne__c> geta2 () {
        return a2;
    }
    public List<ART_Issue_gne__c> geta3 () {
        return a3;
    }




}