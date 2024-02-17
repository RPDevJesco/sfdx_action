/**
 * Created by Jesse Glover on 5/1/2023.
 */

public with sharing class UTIL_Fields {

    public static String leftPadField(SObject record, String fieldName, Integer length) {
        if (record == null) {
            // The specified field does not exist in the record.
            return null;
        }

        String fieldValue = (String) record.get(fieldName);
        if (fieldValue == null) return null;

        String paddedValue = fieldValue.leftPad(length, '0');
        record.put(fieldName, paddedValue);

        return paddedValue;
    }

    /**
     * @param sObjectType The SObject to be iterated upon.
     * @param fieldApiName String value of the field needed.
     * @param startsWithValue Filter String. Eg: Complete
     * @return List of values that resides in the picklist.
     * If the startsWithValue parameter is null or an empty string, it will add all items to the list.
     */
    public static List<String> getFilteredPicklistValues(SObjectType sObjectType, String fieldApiName, String startsWithValue) {
        List<String> picklistValues = new List<String>();

        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Schema.DescribeFieldResult fieldDescribe = sObjectDescribe.fields.getMap().get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            picklistValues.add(picklistEntry.getValue());
        }

        List<String> filteredValues = new List<String>();
        if (String.isNotBlank(startsWithValue)) {
            for (String value : picklistValues) {
                if (value.startsWith(startsWithValue)) {
                    filteredValues.add(value);
                }
            }
        } else {
            filteredValues = picklistValues;
        }

        return filteredValues;
    }

    @AuraEnabled(Cacheable=true)
    public static List<String> getAllFieldsForSObject(String objectName) {
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe();

        Schema.SObjectType sObjectTypeInstance = sObjectMap.get(objectName);
        List<String> fieldNames = new List<String>();

        if(sObjectTypeInstance == null) return null;

        // Grabs all the Fields for current sObject
        Map<String, Schema.SObjectField> fieldMap = sObjectTypeInstance.getDescribe().fields.getMap();

        for(Schema.SObjectField field: fieldMap.values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            // Follows best practices in order to ensure that we are accessing fields that are accessible, which ensures security is kept in check.
            if(fieldResult.isAccessible() && fieldResult.isUpdateable() && fieldResult.isCreateable()) {
                fieldNames.add(fieldResult.getName() + ' : ' + fieldResult.getType());
            }
        }

        // Removes the extra comma and space from the end of the string.
        return fieldNames;
    }

    /**
     * @param newRecords List of new SObject records.
     * @param oldRecordsMap Map of old SObject records.
     * @param fieldName The API name of the field to check.
     * Ensures that special characters cannot be placed in the specified field.
     */
    public static void disallowSpecialCharactersAndSpaces(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap, String fieldName) {
        String specialCharacters = '!@#$%^&*()_+={}[]|\\:;"<>,.?/~`';

        for (SObject newRecord : newRecords) {
            SObject oldRecord = oldRecordsMap.get(newRecord.Id);
            String newFieldValue = (String)newRecord.get(fieldName);
            String oldFieldValue = oldRecord != null ? (String)oldRecord.get(fieldName) : null;

            if (oldRecord != null && newFieldValue != null && !newFieldValue.equals(oldFieldValue) && containsAny(newFieldValue, specialCharacters)) {
                newRecord.put(fieldName, 'Spaces and special characters are not allowed.');
                newRecord.addError('Spaces and special characters are not allowed in ' + fieldName + '.');
            }
        }
    }

    /**
     * Check if the target string contains any character in the given characters string.
     * @param target The target string to check.
     * @param characters The characters to check for.
     * @return True if any character in characters is found in target, false otherwise.
     */
    @TestVisible
    private static Boolean containsAny(String target, String characters) {
        for (Integer i = 0; i < characters.length(); i++) {
            String character = characters.substring(i, i + 1);
            if (target.contains(character)) {
                return true;
            }
        }
        return false;
    }

    public enum ValidInfoType {
        EMAIL, PHONE, INVALID
    }

    public static ValidInfoType validateContactInfo(String input) {
        // Check if the input matches the email pattern
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailRegex = Pattern.compile(emailPattern);
        Matcher emailMatcher = emailRegex.matcher(input);

        if (emailMatcher.matches()) {
            return ValidInfoType.EMAIL;
        }

        // Check if the input matches the phone number pattern
        String phonePattern = '^(\\+\\d{1,3})?[-.\\s]?\\(?\\d{3}\\)?[-.\\s]?\\d{3}[-.\\s]?\\d{4}$';
        Pattern phoneRegex = Pattern.compile(phonePattern);
        Matcher phoneMatcher = phoneRegex.matcher(input);

        if (phoneMatcher.matches()) {
            return ValidInfoType.PHONE;
        }

        return ValidInfoType.INVALID;
    }
}