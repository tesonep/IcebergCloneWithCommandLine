Extension { #name : 'IceGitClone' }

{ #category : '*Iceberg-Git-Tool' }
IceGitClone class >> cloneOperationClass [

	^ self propertyAt: #cloneOperationClass ifAbsent: [ self defaultCloneOperationClass ]


]

{ #category : '*Iceberg-Git-Tool' }
IceGitClone class >> cloneOperationClass: aClass [

	^ self propertyAt: #cloneOperationClass put: aClass

]

{ #category : '*Iceberg-Git-Tool' }
IceGitClone class >> defaultCloneOperationClass [

	^ IceGitCloneUsingCommandLineTool 
]

{ #category : '*Iceberg-Git-Tool' }
IceGitClone class >> settingsOn: aBuilder [ 

	<systemsettings>
	
	(aBuilder pickOne: #'cloneOperationClass')
		parent: #Iceberg;
		target: self;
		default: self defaultCloneOperationClass;
		label: 'Clone Operation Strategy';
		description: 'Clone Strategy to use';
		domainValues: {
			'Use Libgit' -> IceGitClone.
			'Use GIT external tool' -> IceGitCloneUsingCommandLineTool}.

]
