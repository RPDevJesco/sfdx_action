/**
 * Created by Jesse Glover.
 * This class is used for following best practice for checking if items are createable, accessible and updateable
 * before making changes.
 * If any of the checks return false, it will not allow the code to deploy to the org.
 */
public with sharing class UTIL_CheckFieldAccess {
    /**
     * @param objectName Name of the Object you want to check.
     * @param fieldName Name of the Field you want to check.
     * @return true or false depending on if items are accessible, creatable or updateable.
     */
    public static Boolean checkAccessibility(String objectName, String fieldName) {
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (!objectType.getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible()){System.debug(fieldName + ' is not accessible'); return false;}
        if (!objectType.getDescribe().fields.getMap().get(fieldName).getDescribe().isCreateable()){System.debug(fieldName + ' is not createable'); return false;}
        if (!objectType.getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable()){System.debug(fieldName + ' is not updateable'); return false;}
        return true;
    }
}