@isTest
public class OrphanBranchCreatorTests {
    @isTest(seeAllData=true)
    public static void FlowEntryPoint()
    {
        copado__Git_Repository__c repo = new copado__Git_Repository__c(
            copado__Git_Provider__c = 'Github',
            copado__Branch_Base_URL__c = 'main',
            copado__Source_Format__c = 'Metadata'
        );

        insert repo;

        copado__Deployment_Flow__c pipeline = new copado__Deployment_Flow__c(
            copado__Git_Repository__c = repo.id,
            COPADO__ENABLE_COPADO_DX__C = false,
            COPADO__MAIN_BRANCH__C = 'main'
        );

        insert pipeline;

        copado__Project__c project = new copado__Project__c(
            Name = 'Project',
            copado__Deployment_Flow__c = pipeline.id
        );

        insert project;

        copado__User_Story__c userStory = new copado__User_Story__c(
            copado__User_Story_Title__c = 'User Story 1',
            copado__Project__c = project.id
        );

        insert userStory;

        List<copado__User_Story_Metadata__c> metadata = new List<copado__User_Story_Metadata__c> {
            new copado__User_Story_Metadata__c(copado__User_Story__c = userStory.id, copado__Metadata_API_Name__c='ApexClass.TestClass'),
            new copado__User_Story_Metadata__c(copado__User_Story__c = userStory.id, copado__Metadata_API_Name__c='ApexClass.TestClass2')
        };

        insert metadata;

        Test.startTest();

        List<string> pipeDelimitedList = OrphanBranchCreator.FlowEntryPoint(new List<string> { userStory.ID });

        Test.stopTest();

        System.assertEquals('/classes/TestClass.cls|/classes/TestClass2.cls', pipeDelimitedList[0]);

    }
}