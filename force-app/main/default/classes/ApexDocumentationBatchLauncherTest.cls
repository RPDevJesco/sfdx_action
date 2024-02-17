@IsTest
private class ApexDocumentationBatchLauncherTest {

    @IsTest static void testLaunchApexDocumentationBatch() {
        // Setup test data if needed

        // Call the method to launch the batch
        Test.startTest();
        ApexDocumentationBatchLauncher.launchApexDocumentationBatch(200); // 200 or whatever batch size you prefer
        Test.stopTest();

        // Assert that the batch job has been queued or executed
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors
        FROM AsyncApexJob
        WHERE JobType = 'BatchApex'
        AND ApexClass.Name = 'ApexDocumentationBatch'];

        System.assertEquals(1, jobs.size(), 'Expected one batch job to be executed');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'Expected no errors in batch job');
    }
}