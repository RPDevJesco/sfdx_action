@IsTest
private class ApexDocumentationControllerTest {
    @TestSetup
    static void GenerateDocumentation() {
        ApexCodeDocumentation__c documentation = new ApexCodeDocumentation__c();
        documentation.ParentClass__c = 'ApexDocumentationBatchLauncher';
        documentation.MethodName__c = 'launchApexDocumentationBatch';
        documentation.MethodSignature__c = 'global static void';
        documentation.Parameters__c = 'Integer batchSize';
        documentation.FieldReference__c = 'Database.executeBatch';
        documentation.Description__c = '@param batchSize size of the batch';
        documentation.Return__c = 'not documented';
        insert documentation;
    }

    @IsTest
    static void getDocumentationTest() {
        List<ApexCodeDocumentation__c> documentations = ApexDocumentationController.getDocumentation();

        System.assertEquals( 'ApexDocumentationBatchLauncher', documentations[0].ParentClass__c);
        System.assertEquals( 'launchApexDocumentationBatch', documentations[0].MethodName__c);
        System.assertEquals( 'global static void', documentations[0].MethodSignature__c);
        System.assertEquals( 'Integer batchSize', documentations[0].Parameters__c);
        System.assertEquals( 'Database.executeBatch', documentations[0].FieldReference__c);
        System.assertEquals( '@param batchSize size of the batch', documentations[0].Description__c);
        System.assertEquals( 'not documented', documentations[0].Return__c);

    }
}