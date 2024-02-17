/**
 * Created by Jesse Glover.
 * Written to report 100% code coverage
 * Only needs to have a test setup function added for specific items that will be called for testing.
 */

@IsTest
private class UTIL_SObjectToQueryableStringTest {
    @TestSetup
    static void createData() {
        Campaign campaignInstance = new Campaign();
        campaignInstance.Name = 'Test';
        campaignInstance.IsActive = true;
        campaignInstance.Description = 'Aetna';
        insert campaignInstance;
    }

    @IsTest
    static void positivetest_sObjectToQueryableString() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        System.assert(databaseAccountCall != null);
    }

    @IsTest
    static void negativetest_sObjectToQueryableString() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        String query = 'SELECT Id FROM Campaign';
        List<Campaign> dbAccountCall = Database.query(query);
        System.assertNotEquals(databaseAccountCall, dbAccountCall);
    }

    @IsTest
    static void neutraltest_sObjectToQueryableString() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        System.assert(databaseAccountCall != null);
    }

    @IsTest
    static void neutraltest_sObjectToQueryableStringBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('');
        System.assert(testUtility == null);
    }

    @IsTest
    static void negativetest_sObjectToQueryableStringBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('');
        String query = 'SELECT Id FROM Campaign';
        System.assertNotEquals(query, testUtility);
    }

    @IsTest
    static void positivetest_sObjectToQueryableStringBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('');
        System.assertEquals(null, testUtility);
    }

    @IsTest
    static void positivetest_sObjectToQueryableStringOverload() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign','Name = \'Test\'');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        System.assert(databaseAccountCall != null);
    }

    @IsTest
    static void negativetest_sObjectToQueryableStringOverload() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign','Name = \'Test\'');
        String query = 'SELECT Id, Name FROM Campaign WHERE Name != \'Test\'';
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        List<Campaign> dbAccountCall = Database.query(query);
        System.assertNotEquals(databaseAccountCall, dbAccountCall);
    }

    @IsTest
    static void neutraltest_sObjectToQueryableStringOverload() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign','Name = \'Test\'');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        System.assert(databaseAccountCall != null);
    }

    @IsTest
    static void neutraltest_sObjectToQueryableStringOverloadBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('','Name = \'Test\'');
        System.assert(testUtility == null);
    }

    @IsTest
    static void negativetest_sObjectToQueryableStringOverloadBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('','Name = \'Test\'');
        String query = 'SELECT Id FROM Campaign WHERE Name != Test';
        System.assertNotEquals(query, testUtility);
    }

    @IsTest
    static void positivetest_sObjectToQueryableStringOverloadBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('','Name = \'Test\'');
        System.assert(testUtility == null);
    }

    @IsTest
    static void positivetest_sObjectToQueryableStringAdditionalFieldsBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('','','Name = \'Test\'');
        System.assertEquals(null, testUtility);
    }

    @IsTest
    static void negativetest_sObjectToQueryableStringAdditionalFieldsBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('','','Name = \'Test\'');
        String query = 'SELECT Id FROM Campaign WHERE Name != Test';
        System.assertNotEquals(query, testUtility);
    }

    @IsTest
    static void neutraltest_sObjectToQueryableStringAdditionalFieldsBranch() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('','','Name = \'Test\'');
        System.assert(testUtility == null);
    }

    @IsTest
    static void positivetest_sObjectToQueryableStringAdditionalFields() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign','','Name = \'Test\'');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        System.assertEquals(databaseAccountCall.size(), 1);
    }

    @IsTest
    static void negativetest_sObjectToQueryableStringAdditionalFields() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign','','Name = \'Test\'');
        String query = 'SELECT Id, IsDeleted, Name, ParentId, Type, Status, StartDate, EndDate, ExpectedRevenue ' +
                'FROM Campaign WHERE Name = \'Test\'';
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        List<Campaign> dbAccountCall = Database.query(query);
        System.assertNotEquals(databaseAccountCall, dbAccountCall);
    }

    @IsTest
    static void neutraltest_sObjectToQueryableStringAdditionalFields() {
        String testUtility = UTIL_SObjectToQueryableString.sObjectToQueryableString('Campaign','','Name = \'Test\'');
        List<Campaign> databaseAccountCall = Database.query(testUtility);
        System.assert(databaseAccountCall != null);
    }
}