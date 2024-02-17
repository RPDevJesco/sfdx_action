@IsTest
private class AzureWorkItemTest {

    @IsTest
    static void testAzureWorkItemCreation() {
        // Arrange
        AzureWorkItem item = new AzureWorkItem();

        // Act
        item.Id = 123;
        item.State = 'New';
        item.AssignedTo = 'John Doe';
        item.Title = 'Test Work Item';
        item.WorkItemType = 'Bug';
        item.Tags = 'Tag1; Tag2';
        item.Description = 'This is a test work item';
        item.Comments = new List<String>{ 'Comment1', 'Comment2' };

        // Assert
        System.assertEquals(123, item.Id, 'Id should be 123');
        System.assertEquals('New', item.State, 'State should be New');
        System.assertEquals('John Doe', item.AssignedTo, 'AssignedTo should be John Doe');
        System.assertEquals('Test Work Item', item.Title, 'Title should be Test Work Item');
        System.assertEquals('Bug', item.WorkItemType, 'WorkItemType should be Bug');
        System.assertEquals('Tag1; Tag2', item.Tags, 'Tags should be Tag1; Tag2');
        System.assertEquals('This is a test work item', item.Description, 'Description should be This is a test work item');
        System.assertEquals(2, item.Comments.size(), 'There should be 2 comments');
        System.assertEquals('Comment1', item.Comments[0], 'First comment should be Comment1');
        System.assertEquals('Comment2', item.Comments[1], 'Second comment should be Comment2');
    }
}