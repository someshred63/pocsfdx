public with sharing class CFAR_SecurityUtils {

    class SecurityException extends Exception {}

    public static void deleteRecord(SObject sObj) {
        deleteRecords(new List<SObject>{sObj});
    }

    public static void deleteRecords(List<SObject> sObjList) {
        if(sObjList.isEmpty()){
            return;
        }
        if (sObjList[0].getSObjectType().getDescribe().isDeletable()) {
            delete sObjList;
        } else {
            throw new SecurityException(Label.CFAR_DELETE_NO_ACCESS);
        }
    }

    public static List<Database.SaveResult> insertRecord(SObject sObj) {
        return insertRecords(new List<SObject>{sObj});
    }

    public static List<Database.SaveResult> insertRecords(List<SObject> sObjList) {
        if (sObjList.isEmpty()) {
            return null;
        }

        Boolean flsAccess = true;
        Map<String, Schema.SObjectField> mapSchema = sObjList[0].getSObjectType().getDescribe().fields.getMap();
        for (String fieldToCheck :  getAllPopulatedFields(sObjList)) {
            if (!mapSchema.get(fieldToCheck).getDescribe().isCreateable()) {
                flsAccess = false;
                break;
            }
        }

        if (flsAccess) {
            return Database.insert(sObjList, false);
        } else {
            throw new SecurityException(Label.CFAR_INSERT_NO_ACCESS);
        }
    }

    public static List<Database.SaveResult> updateRecord(SObject sObj) {
        return updateRecords(new List<SObject>{sObj});
    }

    public static List<Database.SaveResult> updateRecords(List<SObject> sObjList) {
        if (sObjList.isEmpty()) {
            return null;
        }

        Boolean flsAccess = true;
        Map<String, Schema.SObjectField> mapSchema = sObjList[0].getSObjectType().getDescribe().fields.getMap();
        for (String fieldToCheck :  getAllPopulatedFields(sObjList)) {
            if (!mapSchema.get(fieldToCheck).getDescribe().isUpdateable()) {
                flsAccess = false;
                break;
            }
        }
        if (flsAccess) {
            return Database.update(sObjList, false);
        } else {
            throw new SecurityException(Label.CFAR_UPDATE_NO_ACCESS);
        }
    }

    public static List<Database.UpsertResult> upsertRecord(SObject sObj, SObjectType sObjectType) {
        return upsertRecords(new List<SObject>{sObj}, sObjectType);
    }

    public static List<Database.UpsertResult> upsertRecords(List<SObject> sObjList, SObjectType sObjectType) {
        if (sObjList.isEmpty()) {
            return null;
        }

        Boolean flsInsertAccess = true;
        Boolean flsUpdatetAccess = true;
        Map<String, Schema.SObjectField> mapSchema = sObjList[0].getSObjectType().getDescribe().fields.getMap();
        List<SObject> sObjListForInsert = new List<SObject>();
        List<SObject> sObjListForUpdate = new List<SObject>();

        for(SObject obj : sObjList){
            if(obj.Id == null){
                sObjListForInsert.add(obj);
            } else {
                sObjListForUpdate.add(obj);
            }
        }

        if (!sObjListForInsert.isEmpty()) {
            for (String fieldToCheck :  getAllPopulatedFields(sObjListForInsert)) {
                if (!mapSchema.get(fieldToCheck).getDescribe().isCreateable()) {
                    flsInsertAccess = false;
                    break;
                }
            }
        }

        if (!sObjListForUpdate.isEmpty()) {
            for (String fieldToCheck :  getAllPopulatedFields(sObjListForUpdate)) {
                if (!mapSchema.get(fieldToCheck).getDescribe().isUpdateable()) {
                    flsUpdatetAccess = false;
                    break;
                }
            }
        }

        if (flsUpdatetAccess && flsInsertAccess) {
            String listType = 'List<' + sObjectType + '>';
            List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
            castRecords.addAll(sObjList);
            return Database.upsert(castRecords, false);
        } else {
            throw new SecurityException(Label.CFAR_UPSERT_NO_ACCESS);
        }
    }

    private static Set<String> getAllPopulatedFields(List<SObject> sObjList) {
        Map<String, Schema.SObjectField> mapSchema = sObjList[0].getSObjectType().getDescribe().fields.getMap();
        Set<String> allPopulatedFields = new Set<String>();
        for (SObject obj : sObjList) {
            for (String fieldName : obj.getPopulatedFieldsAsMap().keySet()) {
                if (fieldName != 'Id' && !fieldName.contains('__r') && !mapSchema.get(fieldName).getDescribe().isCalculated()) {
                    allPopulatedFields.add(fieldName);
                }
            }
        }
        return allPopulatedFields;
    }
}