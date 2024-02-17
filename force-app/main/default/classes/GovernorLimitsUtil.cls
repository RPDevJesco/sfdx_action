/**
 * Utility class for generating reports on Salesforce governor limits.
 * This class provides methods to retrieve current usage against the set governor limits in various categories.
 */
global class GovernorLimitsUtil {

    /**
     * Generates a report on SOQL query governor limits.
     * @return String report detailing current SOQL query limits usage.
     */
    global static String getSOQLReports() {
        String report = '';

        report += '--- SOQL Query Limits ---\n';
        report += 'SOQL Queries: ' + Limits.getQueries() + ' out of ' + Limits.getLimitQueries() + '\n';
        report += 'Aggregate Queries: ' + Limits.getAggregateQueries() + ' out of ' + Limits.getLimitAggregateQueries() + '\n';
        report += 'Records Retrieved by SOQL: ' + Limits.getQueryRows() + ' out of ' + Limits.getLimitQueryRows() + '\n';
        return report;
    }

    /**
     * Generates a report on SOSL query governor limits.
     * @return String report detailing current SOSL query limits usage.
     */
    global static String getSOSLReports() {
        String report = '';
        report += '--- SOSL Query Limits ---\n';
        report += 'SOSL Queries: ' + Limits.getSoslQueries() + ' out of ' + Limits.getLimitSoslQueries() + '\n';
        return report;
    }

    /**
     * Generates a report on DML and record processing governor limits.
     * @return String report detailing current DML and record processing limits usage.
     */
    global static String getDMLRecordProcessingReports() {
        String report = '';
        report += '--- DML and Record Processing Limits ---\n';
        report += 'DML Statements: ' + Limits.getDMLStatements() + ' out of ' + Limits.getLimitDMLStatements() + '\n';
        report += 'DML Rows: ' + Limits.getDMLRows() + ' out of ' + Limits.getLimitDMLRows() + '\n';
        report += 'Query Locator Rows: ' + Limits.getQueryLocatorRows() + ' out of ' + Limits.getLimitQueryLocatorRows() + '\n';
        return report;
    }

    /**
     * Generates a report on asynchronous processing governor limits.
     * @return String report detailing current asynchronous processing limits usage.
     */
    global static String getAsynchronousProcessingReports() {
        String report = '';
        report += '--- Asynchronous Processing Limits ---\n';
        report += 'Future Calls: ' + Limits.getFutureCalls() + ' out of ' + Limits.getLimitFutureCalls() + '\n';
        report += 'Queueable Jobs: ' + Limits.getQueueableJobs() + ' out of ' + Limits.getLimitQueueableJobs() + '\n';
        report += 'Async Calls (Reserved): ' + Limits.getAsyncCalls() + ' out of ' + Limits.getLimitAsyncCalls() + '\n';
        return report;
    }

    /**
     * Generates a report on system resource governor limits.
     * @return String report detailing current system resource limits usage.
     */
    global static String getSystemResourceReports() {
        String report = '';
        report += '--- System Resource Limits ---\n';
        report += 'CPU Time: ' + Limits.getCpuTime() + ' out of ' + Limits.getLimitCpuTime() + ' milliseconds\n';
        report += 'Heap Size: ' + Limits.getHeapSize() + ' out of ' + Limits.getLimitHeapSize() + '\n';
        return report;
    }

    /**
     * Generates a report on email invocation governor limits.
     * @return String report detailing current email invocation limits usage.
     */
    global static String getEmailInvocationReports() {
        String report = '';
        report += 'Email Invocations: ' + Limits.getEmailInvocations() + ' out of ' + Limits.getLimitEmailInvocations() + '\n';
        return report;
    }

    /**
     * Generates a report on mobile push Apex call governor limits.
     * @return String report detailing current mobile push Apex call limits usage.
     */
    global static String getMobilePushReports() {
        String report = '';
        report += 'Mobile Push Apex Calls: ' + Limits.getMobilePushApexCalls() + ' out of ' + Limits.getLimitMobilePushApexCalls() + '\n';
        return report;
    }

    /**
     * Generates a report on publish immediate DML governor limits.
     * @return String report detailing current publish immediate DML limits usage.
     */
    global static String getPublishImmediateDMLReports() {
        String report = '';
        report += 'Publish Immediate DML: ' + Limits.getPublishImmediateDML() + ' out of ' + Limits.getLimitPublishImmediateDML() + '\n';
        return report;
    }

    /**
     * Generates a combined report on common Apex resource usage governor limits.
     * @return String report detailing current usage of common Apex resource governor limits.
     */
    global static String getApexResourceUsageReports() {
        String report = '';

        // Concatenate reports from each category
        report += getSOQLReports();
        report += getDMLRecordProcessingReports();
        report += getAsynchronousProcessingReports();
        report += getSystemResourceReports();

        return report;
    }

    /**
     * Generates a comprehensive report on all Salesforce governor limits.
     * @return String report detailing current usage of all Salesforce governor limits.
     */
    global static String getLimitsReport() {
        String report = '';

        // Concatenate reports from each category
        report += getSOQLReports();
        report += getSOSLReports();
        report += getDMLRecordProcessingReports();
        report += getAsynchronousProcessingReports();
        report += getSystemResourceReports();
        report += getEmailInvocationReports();
        report += getMobilePushReports();
        report += getPublishImmediateDMLReports();

        return report;
    }
}