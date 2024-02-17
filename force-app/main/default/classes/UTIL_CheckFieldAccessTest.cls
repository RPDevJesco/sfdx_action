/**
 * Created by Jesse Glover on 2/15/2023.
 * 100% code coverage reported as of 2/15/2023.
 */

@IsTest
private class UTIL_CheckFieldAccessTest {
    @IsTest
    static void positivetest_UTIL_CheckFieldAccess() {
        System.assertEquals(true, UTIL_CheckFieldAccess.checkAccessibility('Case', 'Status'));
    }
    @IsTest
    static void negativetest_UTIL_CheckFieldAccess() {
        System.assertNotEquals(false, UTIL_CheckFieldAccess.checkAccessibility('Case', 'Status'));
    }

    @IsTest
    static void neutraltest_UTIL_CheckFieldAccess() {
        System.assert(UTIL_CheckFieldAccess.checkAccessibility('Case', 'Comments'));
    }
}