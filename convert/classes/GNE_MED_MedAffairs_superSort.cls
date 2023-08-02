public class GNE_MED_MedAffairs_superSort {

    /*This method takes 3 arguments, the List of objects to sort, the field to sort, 
    and the order, asc or desc*/
    public static void sortListWrapper(List<UserWrapperClass> items, String sortField, String order){
        
        Map<string, UserWrapperClass> objectMap = new Map<string, UserWrapperClass>();
        List<UserWrapperClass> temp= new List<UserWrapperClass>();
        List<String> SortItem = new list<String>();
        Set<String> tempSet = new Set<String>();    
        String keyString = NULL;
        System.debug('######## sortField'+sortField);
        System.debug('######## items'+items);
        System.debug('######## order'+order);
        
        integer z = 0;
        Integer iBlank=0;
        integer iCheck=0;
            for (UserWrapperClass i : items) {
                
                if(sortField == 'FullName'){
                    keyString = i.userObj.Name;
                }
                else if(sortField == 'Title'){
                    keyString = i.userObj.Title;
                }
                else if(sortField == 'Role'){
                    keyString = i.userObj.UserRole.Name;
                }
                else if(sortField == 'Profile'){
                    keyString = i.userObj.Profile_Name_gne__c;
                }
                /*else if(sortField == 'Email'){
                    keyString = i.Email;
                }
                else if(sortField == 'Phone'){
                    keyString = i.Phone;
                }
                else if(sortField == 'State'){
                    keyString = i.State;
                }*/
                else if(sortField == 'TherapeuticArea'){
                    keyString = i.TherapeuticArea;
                }
        
                System.debug('#### keyString'+keyString);
                System.debug('#### tempSet'+tempSet);
                if(tempSet.Contains(keyString))
                {
                    String tempString = keyString+z;
                    tempSet.Add(tempString);
                    objectMap.put(tempString,i);
                    SortItem.add(tempString);
                    z++;
                }
                else if (keyString=='')
                {
                    String tempString = keyString+iBlank;
                    tempSet.Add(tempString);
                    objectMap.put(tempString,i);
                    SortItem.add(tempString);
                    iBlank++;
                }
                else 
                {
                    System.debug('#### in else keyString=>'+keyString);
                    System.debug('#### in else tempSet=>'+tempSet);
                    String tempString = keyString+z;
                    tempSet.Add(keyString);
                    objectMap.put(keyString,i);
                    SortItem.add(keyString);
                    System.debug('#### in else SortItem=>'+SortItem);
                    z++;
                }
            }
        for (string s : SortItem)       
        {
            System.debug('#### before sort SortItem'+s);
            
            iCheck++;
            
        }
        System.debug('#### iCheck'+iCheck);
        SortItem.sort();
        for (string s : SortItem) 
        System.debug('#### after sort SortItem'+s);
        for (string s : SortItem){
            temp.add(objectMap.get(s));
        }
        System.debug('######## temp'+temp);
        //Apply the sorted values to the source list in Asc or Desc
        System.debug('######## before clear items'+items);
        items.clear();
        System.debug('######## after clear items'+items);
        System.debug('######## order'+order);
        if(order.toLowerCase() == 'ASC'){
            for(string s : SortItem){
                items.add(objectMap.get(s));  
            }
        }
        else if(order.toLowerCase() == 'DESC'){
            for(integer i = SortItem.size()-1; i >= 0; i--){
                items.add(objectMap.get(SortItem[i]));   
            }
        }
        /*
        for (UserWrapperClass UWC : items){
            //System.debug('*****Printing Sorted Desc or Asc List FullName from wrapper class: '+UWC.FullName);
        }*/

    }
    
    public static void sortList(List<sObject> items, String sortField, String order){
        /*I must give credit where it is due as the sorting algorithm I am using is the 
        one supplied by Andrew Waite here: http://blog.sforce.com/sforce/2008/09/sorting-collect.html */
        
        Boolean isSortFieldReference = false;
        Map<Id,String> referenceName;
         
        /*Determine the type of the field that needs to be sorted, if it is a 
        reference we will want sort by the name of the related object, not the 
        ID itself*/
        if(items[0].getSObjectType().getDescribe().fields.getMap().get(sortField).getDescribe().getType().Name() == 'REFERENCE'){
            isSortFieldReference = true;
            referenceName = new Map<Id,String>();
            
            /*Determine the type of this object and populate the Id to Name map*/
            Set<Id> referenceIds = new Set<Id>();
            for(sObject s : items){
               referenceIds.add((Id)s.get(sortField));
            }
            
            // DevAngel - EDIT - Because you may not have a value for the reference field in the first record
            // in the table you are sorting, this approach will fail on the substring method.  Below is
            // is a more reliable method using describe calls
            /*
            String objectID = (String)items[0].get(sortField);
            String prefix = objectID.substring(0,3);
            String objectType;
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values()){
                if(prefix == s.getDescribe().getKeyPrefix()){
                    objectType = s.getDescribe().Name;
                }
            }
            */

            // DevAngel - EDIT - New approach...
            List<Schema.Sobjecttype> objType = items[0].getSObjectType().getDescribe().fields.getMap().get(sortField).getDescribe().getReferenceTo();
            String objectType = objType[0].getDescribe().getName();

            //Query the related objects for the name and populate the Id -> Name map
            String queryString = 'select Id, Name from ' + objectType + ' where ID IN :referenceIDs';
            for(sObject s : Database.query(queryString )){
                // DevAngel - EDIT - if the reference field is null then we will not have a result, so we need to "create one"
                if (s.get('Name') == null) {
                    referenceName.put((Id)s.get('Id'), 'n/a');
                } else {
                    referenceName.put((Id)s.get('Id'),(String)s.get('Name'));
                }
            }
        }
                
        /*Declare a list that will contain the sorted results. I think this is one of the 
        coolest parts of this method as the system will not let you declare a list of 
        sObjects (List<sObject> objects = new List<sObjects>();) but using a 
        wrapper class you can bypass this system limitation to create this type of list */
        List<cObject> resultList = new List<cObject>();
    
        //Create a map that can be used for sorting 
        Map<object, List<cObject>> objectMap = new Map<object, List<cObject>>();
        
        for(sObject ob : items){
            if(isSortFieldReference == false){
                if(objectMap.get(ob.get(sortField)) == null){ 
                    objectMap.put(ob.get(sortField), new List<cObject>()); 
                }
                cObject o = new cObject(ob);
                objectMap.get(ob.get(sortField)).add(o);
            }else{
                if(objectMap.get(referenceName.get((Id)ob.get(sortField))) == null){ 
                    objectMap.put(referenceName.get((Id)ob.get(sortField)), new List<cObject>()); 
                }
                cObject o = new cObject(ob);
                objectMap.get(referenceName.get((Id)ob.get(sortField))).add(o);
            }
        }
        
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
        
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
        
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(cObject ob : resultList){
                items.add(ob.obj);  
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i].obj);   
            }
        }
    }
    
    public class cObject{
        sObject obj {get; set;}
        
        public cObject(sObject obj){
            this.obj = obj; 
        }
    }
    
 
}