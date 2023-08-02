/**
 *  Class intended to provide generic functilality that can work across multiple objects
 **/
public with sharing class gFRS_ObjectUtil {

    /**
     *  Finds objects in the list that have duplicate field values
     *  @param List<SObject> objectList
     *  @param List<SObjects> - list to place duplicate SObjects into
     *  @param fieldName (String) - Id type field to test
     *  @return Boolean - whether duplicates were found (true) or not (false)
     **/
    public static Boolean hasDuplicateIdFields( List<SObject> lSourceObjects, List<SObject> lDuplicates, String fieldName ) {
        Map<Id, SObject> myMap = new Map<Id, SObject>();
        Id myKey;

        if ( lDuplicates == null ) {
            return false;
        }

        Set<SObject> sDuplicates = new Set<Sobject>();

        lDuplicates.clear();

        for ( SObject obj : lSourceObjects ) {
            myKey = (Id)obj.get( fieldName );

            if ( myMap.containsKey( myKey )) {
                lDuplicates.add( obj );
                lDuplicates.add( myMap.get( myKey ));
            }
            else {
                myMap.put( myKey, obj );
            }
        }

        lDuplicates.addAll(sDuplicates);

        return !lDuplicates.isEmpty();
    }

    /**
     *  Creates a set of ids from a list of objects
     *  <p>Allows for more than selecting the same 'id' field on objects, but allows telling distinct MD or Lookup relationship targets</p>
     *  @param objectList (List<SObject>)
     *  @param idField (String)
     *  @return Set<Id> - list of unique values used in the idField for those objects
     **/
    public static Set<Id> createIdFieldSet( List<SObject> objectList, String idField ) {
        Set<Id> sIds = new Set<Id>();
        Id idVal;

        for ( SObject sobj : objectList ) {
            idVal = (Id) sobj.get( idField );
            sIds.add( idVal );
        }

        return sIds;
    }

    /**
     *  Creates a distinct list of strings from a set of objects
     *  @param objectList (List<SObject>)
     *  @param stringField (String)
     *  @return Set<String> - list of unique values used in the stringField for those objects
     **/
    public static Set<String> createStringFieldSet( List<SObject> objectList, String stringField ) {
        Set<String> stringSet = new Set<String>();
        String stringVal;

        for ( SObject sobj : objectList ) {
            stringVal = String.valueOf( sobj.get( stringField ) );
            stringSet.add( stringVal );
        }

        return stringSet;
    }

    /**
     *  Creates a Map from a List of SObjects according to a specific id field
     *  @param objectList (List<SObject>)
     *  @param field (String) - The Id field to use as a key
     *  @param targetMap (Map<Id,SObject>) - map to place the objects into
     **/
    public static void createIdFieldMap( List<SObject> objectList, String field, Map<id, SObject> targetMap ) {
        Id soId;

        if ( targetMap == null ) return;
        targetMap.clear();

        for ( SObject so : objectList ) {
            soId = (Id) so.get( field );
            if ( soId != null ) {
                targetMap.put( soId, so );
            }
        }
    }

    /**
     *  Creates a Map from a List of SObjects according to a specific string field
     *  @param objectList (List<SObject>)
     *  @param field (String) - The String field to use as a key
     *  @param targetMap (Map<string,SObject>) - map to place the objects into
     **/
    public static void createStringFieldMap( List<SObject> objectList, String field, Map<string, SObject> targetMap ) {
        String soString;

        if ( targetMap == null ) return;
        targetMap.clear();

        for ( SObject so : objectList ) {
            soString = (string) so.get( field );
            if ( soString != null ) {
                targetMap.put( soString, so );
            }
        }
    }

    /**
     *  Filters list of SObjects based on the value of a particular string field
     *  @param newList (List<SObject>)
     *  @param field (String)
     *  @param targetVal (String)
     *  @param targetList (List<SObject>)
     **/
    public static void filterListByString( List<SObject> myList, String field, String targetValue, List<SObject> resultList ) {
        if ( resultList == null ) return;
        resultList.clear();

        for ( SObject obj : myList ) {
            if ( obj.get( field ) == targetValue ) {
                resultList.add( obj );
            }
        }
    }

    /**
     *  Determines whether two specific objects have different values
     *  @param object1 (SObject)
     *  @param object2 (SObject)
     *  @param prop (String) - the property to compare
     *  @return Whether the values are different
     **/
    public static Boolean isPropertyDifferent( SObject object1, SObject object2, String prop ) {
        return ( object1 == null || object2 == null || object1.get( prop ) != object2.get( prop ));
    }

    /**
     *  Filters list of SObjects based on whether the value of a particular field has changed
     *  <p>Note: this returns the objects in the 'new' list that have changed the values
     *  @param newList List<SObject>
     *  @param oldMap (Map<id<SObject>)
     *  @param fieldName (String) the field to check for differences on
     *  @param resultList (List<SObject>) - the list to put the 'new' objects that have changed
     **/
    public static void filterChangedObjects( List<SObject> newList, Map<Id, SObject> oldMap, String fieldName, List<SObject> resultList ) {
        if ( resultList == null ) return;
        resultList.clear();

        //-- if oldMap is null, then all items must be new
        if ( oldMap == null ) {
            resultList.addAll( newList );
            return;
        }

        SObject old;
        for ( SObject obj : newList ) {
            if ( obj.id != null ) {
                if ( oldMap.containsKey( obj.id )) {
                    old = oldMap.get( obj.id );
                    if ( old.get( fieldName ) != obj.get(fieldName ) ) {
                        resultList.add( obj );
                    }
                }
                else {
                    resultList.add( obj );
                }
            }
            else {
                resultList.add( obj );
            }
        }
    }
    
      /**
     *  Filters list of SObjects based on whether the value of a particular field has changed
     *  <p>Note: this returns the objects in the 'new' list that have changed the values
     *  @param newList List<SObject>
     *  @param oldMap (Map<id<SObject>)
     *  @param fieldName (String) the field to check for differences on
     *  @param resulSet (Set<SObject>) - the set to put the 'new' objects that have changed
     **/
    public static Set<SObject> filterChangedObjects(List<SObject> newList, Map<Id, SObject> oldMap, String fieldName) {
        final List<SObject> resultList = new List<SObject>();
        filterChangedObjects(newList, oldMap, fieldName, resultList);
        return new Set<SObject>(resultList);
    }
    
    /**
     *  Filters list of SObjects based on whether the value of a particular field has NOT changed
     *  <p>Note: this returns the objects in the 'new' list that have NOT changed the values
     *  @param newList List<SObject>
     *  @param oldMap (Map<id<SObject>)
     *  @param fieldName (String) the field to check for differences on
     *  @param resultList (List<SObject>) - the list to put the 'new' objects that have not changed
     **/
    public static void filterNotChangedObjects( List<SObject> newList, Map<Id, SObject> oldMap, String fieldName, List<SObject> resultList ) {
        if ( resultList == null ) return;
        resultList.clear();

        //-- if oldMap is null, then all items must be new
        if ( oldMap == null ) {
            resultList.addAll( newList );
            return;
        }

        SObject old;
        for ( SObject obj : newList ) {
            if ( obj.id != null ) {
                if ( oldMap.containsKey( obj.id )) {
                    old = oldMap.get( obj.id );

                    if ( old.get( fieldName ) == obj.get(fieldName ) ) {
                        resultList.add( obj );
                    }
                }
                else {
                    resultList.add( obj );
                }
            }
            else {
                resultList.add( obj );
            }
        }
    }

    /**
     *  Checks map of sObjects for sObjects from list and 
     *  @param newList (List<SObject>)
     *  @param oldMap (Map<Id,SObject>)
     *  @param targetList (List<SObject>)
     **/
    public static void getMapListItems( List<SObject> lSObjects, Map<Id, SObject> mapSObjects, List<SObject> targetList ) {
        if ( targetList == null ){
        	return;
        }
        targetList.clear();

        for ( SObject obj : lSObjects ) {
            if ( mapSObjects.containsKey( obj.Id )) {
                targetList.add( mapSObjects.get( obj.Id ));
            }
        }
    }

    /**
     *  Deep clones a list, to clear out ids.
     *  <p>Allows for 'rolling-back' groups of items if an insert fails.
     *  Still would be great if simply obj.id = null would work instead of cloning</p>
     *  @param sourceList List<SObject>
     *  @param targetList List<SObject>
     **/
    public static void cloneListWithoutIds( List<SObject> sourceList, List<SObject> targetList ) {
        if ( targetList == null ) return;
        targetList.clear();

        for ( SObject obj : sourceList ) {
            targetList.add( obj.clone( false, false ));
        }
    }

    /**
     *  Removes the items that match a particular value
     *  @param sList (List<SObject>)
     *  @param propName (String)
     *  @param targetVal (Long)
     **/
    public static SObject removeMatchingLong( List<SObject> sList, String propName, Long targetVal ) {
        //System.debug( 'targetVal:' + targetVal );
        if ( targetVal == null ) return ( null );

        SObject oldObj;
        for ( Integer i = 0; i < sList.size(); i++ ) {
            oldObj = sList[i];
            if ( oldObj.get( propName ) == targetVal ) {
                sList.remove( i );
                return ( oldObj );
            }
        }

        return ( null );
    }

    /**
     *  Finds the item tht matches a particular value
     *  @param sList (List<SObject>)
     *  @param propName (String)
     *  @param targetVal (Long)
     *  @return SObject
     **/
    public static SObject findMatchingLong( List<SObject> sList, String propName, Long targetVal ) {
        if ( targetVal == null ) return ( null );

        for ( SObject oldObj : sList ) {
            if ( oldObj.get( propName ) == targetVal ) {
                return ( oldObj );
            }
        }
        return ( null ); //-- not found
    }

    /**
     *  Finds the index of the item tht matches a particular value
     *  @param sList (List<SObject>)
     *  @param propName (String)
     *  @param targetVal (Long)
     *  @return Integer - index of the sobject in sList that matching targetVal or -1 if it was not found
     **/
    public static Integer findMatchingLongIndex( List<SObject> sList, String propName, Long targetVal ) {
        if ( targetVal == null ) return ( null );

        SObject oldObj;
        for ( Integer i = 0; i < sList.size(); i++ ) {
            oldObj = sList[i];
            if ( oldObj.get( propName ) == targetVal ) {
                return ( i );
            }
        }
        return ( -1 ); //-- not found
    }

    /**
     *  Transfers objects from a List of SObjects to a concrete list
     *  <p>Apex does not allow upcasting from a list defined as List<SObject>
     *  but it does allow downcasting.</p>
     *  <p>For example:
     *  List<Account> sourceList = ...
     *  List<SObject> newObjects = gFRS_ObjectUtil.filterNewObjects( sourceList, true );
     *  List<Account> resultList = gFRS_ObjectUtil.combineSList( newObjects, new List<Account>() );
     *  </p>
     *
     *  @param sourceList (List<SObject>)
     *  @param targetList (List<SObject>)
     *  @return List<SObject> - same as targetList for convenience
     **/
    public static List<SObject> combineSList( List<SObject> sourceList, List<SObject> targetList ) {
        targetList.addAll( sourceList );
        return ( targetList );
    }

    /**
     *  Transfers all the items from sourceMap into targetMap
     *  @param sourceMap Map<Id,SObject>
     *  @param targetMap Map<Id,SObject>
     **/
    public static Map<Id, SObject> transferSMap( Map<Id, SObject> sourceMap, Map<Id, SObject> targetMap ) {
        Set<Id> sourceKeys = sourceMap.keySet();

        targetMap.clear();
        for ( Id i : sourceKeys ) {
            targetMap.put( i, sourceMap.get(i));
        }

        return ( targetMap );
    }

    /**
     *  Converts a list of objects to a map based on a set of string keys
     *  <p>This creates a map where the objects that share the same value under 'propName'
     *  are placed under the same list.</p>
     *
     *  <p>If targetMap is null, then an appropriate targetMap is created, for returning.</p>
     *
     *  <p>For now, unlike other methods, this test must use SObjects for targetMap, instead
     *  of subclasses, as the lists must be returned. Because of this, results from the map
     *  will need to be casted - ex: (Account)myResult.get(city);</p>
     *
     *  @param List<SObject> - list of objects to utilize
     *  @param propName String - property name that we should use
     *  @param targetMap Map<String,SObject[]> - map to apply keys and sobjects to. (If null, then one is created and returned)
     *  @return Map<String,List<SOBject>> - where all the objects that match that key value.
     **/
    public static Map<String, SObject[]> indexByStringKey( SObject[] sourceList, String propName, Map<String, SObject[]> targetMap ) {
        if ( targetMap == null ) targetMap = new Map<String, SObject[]>();

        String key = null;
        for ( SObject sobj : sourceList ) {
            key = (String)sobj.get( propName );
            if ( targetMap.containsKey( key )) {
                targetMap.get( key ).add( sobj );
            }
            else {
                targetMap.put( key, new SObject[] { sobj } );
            }
        }

        return ( targetMap );
    }

    /**
     * Adds a single item to the map created by indexByStringKey.
     * <p>Used in occasions where it is impractical to create a list of items,
     * then use indexByStringKey.</p>
     *
     * <p>Unlike indexByStringKey - targetMap is required and cannot be null,
     * this avoids an unneccessary check for additional overhead</p>
     *
     * @see gFRS_ObjectUtil.indexByStringKey
     *
     * @param sobj (SObject) - object to add to the list
     * @param propName String
     * @param targetMap (Map<String,SObject[]>) - identical style map as indexByStringKey (to avoid additional overhead, the method throws an exception if targetmap is null)
     * @return targetmap (Map<String,Sobject[]>)
     **/
    public static Map<String, SObject[]> addIndividualIndexByStringKey( SObject sobj, String propName, Map<String, Sobject[]> targetMap ) {
        if ( targetMap == null ) targetMap = new Map<String, SObject[]>();

        String key = (String)sobj.get( propName);
        if ( targetMap.containsKey( key ) ) {
            targetMap.get( key ).add( sobj );
        }
        else {
            targetMap.put( key, new SObject[] { sobj } );
        }

        return ( targetMap );
    }

    /**
    * @author ADMD Team
    * @date 08/20/2013
    * @description filterChangedFieldsUnderRecord method - helper method which tracking if there was any change under fields passed in fieldNames parameter.
    *
    */
    public static void filterChangedFieldsUnderRecord( List<SObject> newList, Map<Id, SObject> oldMap, List<String> fieldNames, List<SObject> resultList ) {
        if ( resultList == null ) return;
        resultList.clear();

        //-- if oldMap is null, then all items must be new
        if ( oldMap == null ) {
            resultList.addAll( newList );
            return;
        }

        SObject old;
        for ( SObject obj : newList ) {
            if ( obj.id != null ) {
                if ( oldMap.containsKey( obj.id )) {
                    old = oldMap.get( obj.Id );
                    //System.debug( 'old[' + fieldName + ']:' + old.get(fieldName) + ', ob[]:' + obj.get(fieldName) );
                    for (String fieldName : fieldNames) {
                        if ( old.get( fieldName ) != obj.get(fieldName ) ) {
                            resultList.add( obj );
                            break;
                        }
                    }
                }
                else {
                    resultList.add( obj );
                }
            }
            else {
                resultList.add( obj );
            }
        }
    }
}