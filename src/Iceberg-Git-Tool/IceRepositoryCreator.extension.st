Extension { #name : 'IceRepositoryCreator' }

{ #category : '*Iceberg-Git-Tool' }
IceRepositoryCreator >> cloneRepository [
	IceGitClone cloneOperationClass new
		location: self locationToUse;
		url: self remoteToUse url;
		execute.

	self repository location: self locationToUse.
		
	self repository pluginManager repositoryWillBeCreated: self repository.	

	self repository workingCopy initializePackagesFromRepository.
	self doEnsureProject.
		
	self repository pluginManager repositoryWasCreated: self repository.
	^ self repository
]
