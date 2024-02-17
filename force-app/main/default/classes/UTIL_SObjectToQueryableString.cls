public class UTIL_SObjectToQueryableString {
    /**
    * @param objectName The SObject that we want to query from.
    * This will grab all the accessible Fields from the SObject to reduce the need for writing queries.
    * @return returns a Database.query usable string.
    */
    public static String sObjectToQueryableString(String objectName) {
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();

        Schema.SObjectType sObjectTypeInstance = sObjectMap.get(objectName);
        String fieldNames = ' ';

        if(sObjectTypeInstance == null) return null;

        // Grabs all the Fields for current sObject
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeInstance.getDescribe().fields.getMap();

        for(Schema.SObjectField field: fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            // Follows best practices in order to ensure that we are accessing fields that are accessible, which ensures security is kept in check.
            if(fieldResult.isAccessible()) {
                fieldNames += fieldResult.getName() + ', ';
            }
        }

        // Removes the extra comma and space from the end of the string.
        fieldNames = fieldNames.substring(0, fieldNames.length() - 2);
        // build out our query.
        String query =
                'SELECT' +
                        fieldNames +
                        ' FROM ' + objectName ;
        System.debug(query);
        return query;
    }

    /**
     * @param objectName  The SObject that we want to query from.
     * @param additionalFields Additional Fields you want to query for that are related to the SObject either via Master-Detail or Lookup Relationships.
     * @param whereClause string for the where clause (please omit the WHERE in the string as it is already accounted for).
     * This will grab all the accessible Fields from the SObject to reduce the need for writing queries.
     * @return returns a Database.query usable string which incorporates a where clause.
     */
    public static String sObjectToQueryableString(String objectName, String additionalFields, String whereClause) {
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();

        Schema.SObjectType sObjectTypeInstance = sObjectMap.get(objectName);
        String fieldNames = ' ';

        if(sObjectTypeInstance == null) return null;

        // Grabs all the Fields for current sObject
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeInstance.getDescribe().fields.getMap();

        for(Schema.SObjectField field: fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            // Follows best practices in order to ensure that we are accessing fields that are accessible, which ensures security is kept in check.
            if(fieldResult.isAccessible()) {
                fieldNames += fieldResult.getName() + ', ';
            }
        }
        // Error handling for in case the additionalFields string is empty.
        // Remove the extra comma and space from the end of the string.
        if (String.isEmpty(additionalFields) || additionalFields == '') fieldNames = fieldNames.substring(0, fieldNames.length() - 2);
        // Error handling for in case the whereClause string is empty. It will exit the function and call the version of the code without the where string.
        if (String.isEmpty(whereClause) || whereClause == '') return sObjectToQueryableString(objectName);
        // Provided that the whereClause string is not empty, we will build out our query with the where clause added.
        // build out our query.
        String query =
                'SELECT' +
                        fieldNames + additionalFields +
                        ' FROM ' + objectName + ' WHERE ' + whereClause;
        System.debug(query);
        return query;
    }

    /**
     * @param objectName The SObject that we want to query from.
     * @param whereClause string for the where clause (please omit the WHERE in the string as it is already accounted for).
     * This will grab all the accessible Fields from the SObject to reduce the need for writing queries.
     * @return returns a Database.query usable string which incorporates a where clause.
     */
    public static String sObjectToQueryableString(String objectName, String whereClause) {
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();

        Schema.SObjectType sObjectTypeInstance = sObjectMap.get(objectName);
        String fieldNames = ' ';

        if(sObjectTypeInstance == null) return null;

        // Grabs all the Fields for current sObject
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeInstance.getDescribe().fields.getMap();

        for(Schema.SObjectField field: fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            // Follows best practices in order to ensure that we are accessing fields that are accessible, which ensures security is kept in check.
            if(fieldResult.isAccessible()) {
                fieldNames += fieldResult.getName() + ', ';
            }
        }

        // Removes the extra comma and space from the end of the string.
        fieldNames = fieldNames.substring(0, fieldNames.length() - 2);

        // Error handling for in case the whereClause string is empty. It will exit the function and call the version of the code without the where string.
        if (String.isEmpty(whereClause) || whereClause == '') return sObjectToQueryableString(objectName);
        // Provided that the whereClause string is not empty, we will build out our query with the where clause added.
        String query =
                'SELECT' +
                        fieldNames +
                        ' FROM ' + objectName + ' WHERE ' + whereClause;
        System.debug(query);
        return query;
    }
}