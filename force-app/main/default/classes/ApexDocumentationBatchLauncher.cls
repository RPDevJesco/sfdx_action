global class ApexDocumentationBatchLauncher {
    /**
     * Global function for launching the managed package's batch class for generating documentation.
     * @param batchSize size of the batch
     */
    global static void launchApexDocumentationBatch(Integer batchSize) {
        ApexDocumentationBatch batchInstance = new ApexDocumentationBatch();
        Database.executeBatch(batchInstance, batchSize);
    }
}