public class OrphanBranchCreator {

    @InvocableMethod
    public static List<string> FlowEntryPoint(List<string> ids)
    {
        return new List<string> { GetSourceCodeFileNames(ids) };
    }

    private static string GetSourceCodeFileNames(List<string> userStoryIds)
    {
        string format = GetRepositorySourceCodeFormat(userStoryIds);

        Map<string,Source_Code_Format_Mapping__mdt> folderMappings = GetSourceCodeFolderPathMappings(format);

        List<copado__User_Story_Metadata__c> userStoryMetadata = [SELECT    copado__Metadata_API_Name__c
                                                                  FROM      copado__User_Story_Metadata__c
                                                                  WHERE     copado__User_Story__c IN : userStoryIds];

        string pipeDelimitedFilePaths = '';
        for(copado__User_Story_Metadata__c metadata : userStoryMetadata)
        {
            if(pipeDelimitedFilePaths.length() > 0)
            {
                pipeDelimitedFilePaths += '|';
            }

            string fullMetadataName = metadata.copado__Metadata_API_Name__c;
            string[] splitMetadata = fullMetadataName.split('\\.');

            if(splitMetadata.size() != 2 && splitMetadata.size() != 3)
            {
                throw new OrphanBranchException('Invalid Metadata Name: ' + fullMetadataName + ' Size: ' + splitMetadata.size());
            }
            
            string folderName = splitMetadata[0];
            string fileName = splitMetadata[1];

            if(!folderMappings.containsKey(folderName))
            {
                throw new OrphanBranchException('No metadata source format mapping was found for: ' + folderName);
            }

            Source_Code_Format_Mapping__mdt mapping = folderMappings.get(folderName);

            if(mapping.MasterLabel == 'AuraDefinitionBundle')
            {
                folderName = '/' + mapping.Folder_Path__c + '/' + fileName + '/';
            }
            if(mapping.MasterLabel == 'CustomLabel')
            {
                folderName = '/' + mapping.Folder_Path__c + '/';
                fileName = mapping.MasterLabel + 's';
            }
            else 
            {
                folderName = '/' + mapping.Folder_Path__c + '/';
            }
            
            string extension = mapping.File_Extension__c;
            if(!extension.startsWith('.'))
            {
                extension = '.' + extension;
            }

            pipeDelimitedFilePaths += folderName + fileName + extension;
        }
        
        return pipeDelimitedFilePaths;
    }

    private static Map<string,Source_Code_Format_Mapping__mdt> GetSourceCodeFolderPathMappings(string format)
    {
        List<Source_Code_Format_Mapping__mdt> sourceMappings = [SELECT  MasterLabel, Folder_Path__c, File_Extension__c 
                                                                FROM    Source_Code_Format_Mapping__mdt
                                                                WHERE   Format__c = :format];

        Map<string,Source_Code_Format_Mapping__mdt> mappings = new Map<string,Source_Code_Format_Mapping__mdt>();
        for(Source_Code_Format_Mapping__mdt mapping : sourceMappings)
        {
            if(mappings.containsKey(mapping.MasterLabel))
            {
                continue;
            }

            mappings.put(mapping.MasterLabel, mapping);
        }

        return mappings;
    }

    private static string GetRepositorySourceCodeFormat(List<string> userStoryIds)
    {
        AggregateResult[] repositories = [SELECT    copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__c copado__Git_Repository__c
                                          FROM      copado__User_Story__c
                                          WHERE     ID IN :userStoryIds
                                          GROUP BY copado__Project__r.copado__Deployment_Flow__r.copado__Git_Repository__c];

        if(repositories.size() == 0)
        {
            throw new OrphanBranchException('User Stories are not associated to a Git Repository.');
        }

        if(repositories.size() > 1)
        {
            throw new OrphanBranchException('User Stories are associated to multiple Git Repositories.');
        }

        AggregateResult userStoryRepository = repositories[0];
        string repositoryId = (string)userStoryRepository.get('copado__Git_Repository__c');

        List<copado__Git_Repository__c> repositoryDetails = [SELECT    copado__Source_Format__c
                                                        FROM      copado__Git_Repository__c
                                                        WHERE     ID = :repositoryId];   

        if(repositoryDetails.size() == 0)
        {
            throw new OrphanBranchException('Could not find Git Repository details.');
        }

        return repositoryDetails[0].copado__Source_Format__c;
    }
}