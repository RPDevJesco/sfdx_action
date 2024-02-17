/**
 * Created by Jesse Glover on 7/21/2023.
 */

@IsTest
private class  UTIL_TimeCalculationTest {
    @TestSetup
    static void initializeTestData() {
        Account accountInstance = new Account();
        accountInstance.Name = 'Test Account For Testing 1234567890';
        insert accountInstance;

        Case caseInstance = new Case();
        caseInstance.Status = 'Closed';
        caseInstance.Account = accountInstance;
        insert caseInstance;
    }

    @IsTest
    static void calculateWorkingDaysTest() {
        Case caseInstance = [SELECT Id, IsClosed, CreatedDate, ClosedDate, Status FROM Case LIMIT 1];

        Datetime createdDate = caseInstance.CreatedDate;
        Datetime closedDate = caseInstance.ClosedDate;

        System.assertEquals(UTIL_TimeCalculation.calculateWorkingDays(Date.valueOf(createdDate), Date.valueOf(closedDate)), 1);
    }

    @IsTest
    static void testSubtractHolidays() {
        // Test Case 1: No holidays in the list
        Date startDate1 = Date.newInstance(2023, 7, 1);
        Date endDate1 = Date.newInstance(2023, 7, 10);
        List<Holiday> holidayList1 = new List<Holiday>(); // Empty holiday list

        Integer result1 = UTIL_TimeCalculation.subtractHolidays(startDate1, endDate1, holidayList1);
        System.assertEquals(0, result1, 'Test Case 1 failed.');

        // Test Case 2: Holidays that fall within the range
        Date startDate2 = Date.newInstance(2023, 12, 15);
        Date endDate2 = Date.newInstance(2023, 12, 31);
        List<Holiday> holidayList2 = new List<Holiday>{
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 12, 18)),
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 12, 25)),
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 12, 28))
        };

        Integer result2 = UTIL_TimeCalculation.subtractHolidays(startDate2, endDate2, holidayList2);
        System.assertEquals(3, result2, 'Test Case 2 failed.');

        // Test Case 3: Holidays that partially fall within the range
        Date startDate3 = Date.newInstance(2023, 9, 1);
        Date endDate3 = Date.newInstance(2023, 9, 30);
        List<Holiday> holidayList3 = new List<Holiday>{
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 8, 30)), // Partially falls in September
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 9, 2)),  // Partially falls in September
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 9, 20)), // Fully falls in September
                new Holiday(RecurrenceStartDate = Date.newInstance(2023, 10, 5))  // Partially falls in September
        };

        Integer result3 = UTIL_TimeCalculation.subtractHolidays(startDate3, endDate3, holidayList3);
        System.assertEquals(2, result3, 'Test Case 3 failed.');
    }

    @IsTest
    static void getWorkingDaysTest() {
        List<Case> caseList = [SELECT Id, IsClosed, CreatedDate, ClosedDate, Status FROM Case LIMIT 1];
        System.assertEquals(UTIL_TimeCalculation.getWorkingDays(caseList) * 24, -24);
    }
}