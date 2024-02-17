/**
 * Created by jglov on 7/28/2023.
 */

public class UpdateCaseAgeBatch implements Database.Batchable<SObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(UTIL_SObjectToQueryableString.sObjectToQueryableString('Case'));
    }

    public void execute(Database.BatchableContext context, List<Case> scope) {
        List<Holiday> holidayList = [SELECT Id, RecurrenceStartDate FROM Holiday];
        Integer daysBetween = 0;
        for (Case caseRecord : scope) {
            Boolean isClosed = caseRecord.IsClosed;
            Datetime closedDate = caseRecord.ClosedDate;
            Datetime createdDate = caseRecord.CreatedDate;
            Date today = Date.today();

            Date startDate = Date.valueOf(createdDate);
            Date endDate = isClosed ? Date.valueOf(closedDate) : today;

            System.debug('startDate: ' + startDate);
            System.debug('endDate: ' + endDate);
            Integer numHolidays = UTIL_TimeCalculation.subtractHolidays(startDate, endDate, holidayList);
            System.debug('numHolidays: ' + numHolidays);
            Integer workingDays = UTIL_TimeCalculation.calculateWorkingDays(startDate, endDate);
            Integer dayCount = workingDays - numHolidays;
            System.debug('workingDays: ' + workingDays);
            System.debug('dayCount: ' + dayCount);

            if (createdDate > today) {
                daysBetween = dayCount != null ? dayCount * -1 : null;
            } else {
                daysBetween = dayCount != null ? dayCount : null;
            }
            System.debug('daysBetween: ' + daysBetween);
            System.debug('daysBetween * 24: ' + daysBetween * 24);
            caseRecord.Case_Age__c = daysBetween * 24;
        }
        update scope;
    }

    public void finish(Database.BatchableContext context) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
        FROM AsyncApexJob
        WHERE Id = :context.getJobId()];
        System.debug('job.Id: ' + job.Id);
        System.debug('job.Status: ' + job.Status);
        System.debug('job.NumberOfErrors: ' + job.NumberOfErrors);
        System.debug('job.JobItemsProcessed: ' + job.JobItemsProcessed);
        System.debug('job.TotalJobItems: ' + job.TotalJobItems);
        System.debug('job.CreatedBy.Email: ' + job.CreatedBy.Email);
    }

    public void execute(SchedulableContext context) {
        UpdateCaseAgeBatch updateCaseAgeBatch = new UpdateCaseAgeBatch();
        Database.executeBatch(updateCaseAgeBatch, 200);
    }
}