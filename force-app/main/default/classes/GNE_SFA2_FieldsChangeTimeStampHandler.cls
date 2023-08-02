public without sharing class GNE_SFA2_FieldsChangeTimeStampHandler {
    public static void onChange(List<SObject> triggerOld, List<SObject> triggerNew, String timeStampField, Set<String> trackedFields) {
        DateTime now = System.now();
        Set<String> tFields = new Set<String>();
        
        for(String tField : trackedFields) {
            tFields.add(tField.toLowerCase());
        }
        
        Integer idx=0;
        for(SObject recNew : triggerNew) {
            SObject recOld = triggerOld!=null && !triggerOld.isEmpty() ? triggerOld[idx] : null;
            Set<String> tFieldsClone = tFields;
            
            if(recNew instanceof Account) {
                Account acc = (Account)recNew;
                tFieldsClone = new Set<String>(tFields);
                
                if(acc.IsPersonAccount) {
                    tFieldsClone.remove('name');
                } else {
                    tFieldsClone.remove('firstname');
                    tFieldsClone.remove('lastname');
                }
            }
            
            onChange(recOld, recNew, timeStampField, tFieldsClone, now);
            idx++;
        }
    }
    
    private static void onChange(SObject recOld, SObject recNew, String timeStampField, Set<String> trackedFields, DateTime now) {
        Boolean isChanged = false;
        
        for(String tField : trackedFields) {
            String valNew = null;
            String valOld = null;
            
            if(recNew instanceof Account && (tField=='name' || tField=='lastname' || tField=='firstname')) {
                Account accNew = (Account)recNew;
                Account accOld = (Account)recOld;
                
                valNew = tField=='name' ? accNew.Name : tField=='lastname' ? accNew.LastName : accNew.FirstName;
                valOld = accOld!=null ? (tField=='name' ? accOld.Name : tField=='lastname' ? accOld.LastName : accOld.FirstName) : null;
            } else {
                valNew = String.valueOf(recNew.get(tField));
                valOld = String.valueOf(recOld!=null ? recOld.get(tField) : null);
            }
		    
		    if((isChanged |= !(valOld!=null ? valOld : '').equals(valNew!=null ? valNew : ''))) {
	           break;
            }
        }
        
        if(isChanged) {
            recNew.put(timeStampField, now);
        }
    }
}