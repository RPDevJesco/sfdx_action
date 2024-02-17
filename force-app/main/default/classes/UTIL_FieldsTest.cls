/**
 * Created by Jesse Glover on 5/1/2023.
 */

@IsTest
private class UTIL_FieldsTest {
    @TestSetup
    static void initializeTestData() {
        Account accountInstance = new Account();
        accountInstance.Name = 'Test Account For Testing 1234567890';
        insert accountInstance;
    }

    @IsTest
    static void additionalTesting() {
        Account accountInstance = [SELECT Id, Name, Description, CreatedDate, AccountNumber, AccountSource, Active__c,
                AnnualRevenue, BillingCity, BillingCountry, BillingGeocodeAccuracy, BillingPostalCode, BillingState,
                BillingStreet FROM Account];
        System.assertEquals(accountInstance.Name, 'Test Account For Testing 1234567890');
        System.assertEquals(accountInstance.Description, null);
        System.assertEquals(accountInstance.CreatedDate, Datetime.now());
        System.assertEquals(accountInstance.AccountNumber, null);
        System.assertEquals(accountInstance.AccountSource, null);
        System.assertEquals(accountInstance.Active__c, null);
        System.assertEquals(accountInstance.AnnualRevenue, null);
        System.assertEquals(accountInstance.BillingCity, null);
        System.assertEquals(accountInstance.BillingCountry, null);
        System.assertEquals(accountInstance.BillingGeocodeAccuracy, null);
        System.assertEquals(accountInstance.BillingPostalCode, null);
        System.assertEquals(accountInstance.BillingState, null);
        System.assertEquals(accountInstance.BillingStreet, null);
    }

    @IsTest
    static void leftPadFieldTest() {
        Account accountInstance = [SELECT Id, Name FROM Account LIMIT 1];
        String comparison = UTIL_Fields.leftPadField(accountInstance, 'Name', 12);

        System.assertEquals(accountInstance.Name, comparison);
    }

    @IsTest
    static void leftPadFieldObjectNullTest() {
        Account accountInstance = [SELECT Id, Name FROM Account LIMIT 1];
        String comparison = UTIL_Fields.leftPadField(null, 'Name', 12);

        System.assertNotEquals(accountInstance.Name, comparison);
    }

    @IsTest
    static void getFilteredPicklistValuesTest() {
        List<String> filteredValues = UTIL_Fields.getFilteredPicklistValues(Case.SObjectType, 'Status', 'Closed');
        List<String> comparison = new List<String>{'Closed'};
        System.assertEquals(filteredValues.size(), comparison.size());
    }

    @IsTest
    static void getFilteredPicklistValuesNullTest() {
        List<String> filteredValues = UTIL_Fields.getFilteredPicklistValues(Case.SObjectType, 'Status', '');
        List<String> comparison = new List<String>{'Closed','New', 'Working', 'Escalated'};
        System.assertEquals(filteredValues.size(), comparison.size());
    }

    @IsTest
    static void getAllFieldsForSObjectTest() {
        List<String> cases = UTIL_Fields.getAllFieldsForSObject('Case');
        System.assertEquals(cases.size(), 51);
    }

    @IsTest
    static void testDisallowSpecialCharactersAndSpaces() {
        // Create a test Account
        Account acc = [SELECT Id, Description FROM Account];

        // Prepare the input for the method with special characters
        String fieldName = 'Description';
        acc.Description = 'Special Characters!@#';
        List<SObject> newRecords = new List<SObject>{acc};
        Map<Id, SObject> oldRecordsMap = new Map<Id, SObject>{acc.Id => [SELECT Id, Description FROM Account WHERE Id = :acc.Id LIMIT 1]};

        // Call the method to test
        UTIL_Fields.disallowSpecialCharactersAndSpaces(newRecords, oldRecordsMap, fieldName);

        // Assert that the special characters were replaced with the error message
        System.assertEquals('Spaces and special characters are not allowed.', newRecords[0].get(fieldName));
    }

    @IsTest
    static void testContainsAny() {
        // Test with characters contained in the target
        Boolean result1 = UTIL_Fields.containsAny('abc123', 'c1');
        System.assertEquals(true, result1, 'The target contains the specified characters');

        // Test with characters not contained in the target
        Boolean result2 = UTIL_Fields.containsAny('abc123', '!@#');
        System.assertEquals(false, result2, 'The target does not contain the specified characters');

        // Test with empty target
        Boolean result3 = UTIL_Fields.containsAny('', 'c1');
        System.assertEquals(false, result3, 'An empty target does not contain any characters');

        // Test with empty characters
        Boolean result4 = UTIL_Fields.containsAny('abc123', '');
        System.assertEquals(false, result4, 'An empty characters string should return false');
    }
}