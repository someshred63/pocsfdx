public without sharing class CFAR_Utils_WithoutSharing {

 	public static void deleteSObject(SObject sObj) {
    	Database.delete(sObj);
    }
    
    /*public static void deleteSObjectList(List<SObject> sObjList) {
    	Database.delete(sObjList);
    }*/
}