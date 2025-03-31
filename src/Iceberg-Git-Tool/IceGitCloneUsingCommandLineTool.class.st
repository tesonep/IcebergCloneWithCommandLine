Class {
	#name : 'IceGitCloneUsingCommandLineTool',
	#superclass : 'Object',
	#instVars : [
		'location',
		'url'
	],
	#category : 'Iceberg-Git-Tool',
	#package : 'Iceberg-Git-Tool'
}

{ #category : 'executing' }
IceGitCloneUsingCommandLineTool >> execute [

	| repoDirectory parent succedded stdOut stdErr |

	location exists ifTrue: [
		IceCloneLocationAlreadyExists signalFor: location ].

	repoDirectory := location basename.
	parent := location parent.
	parent ensureCreateDirectory.
		
	(OSPlatform current	in: [ :aPlatform | aPlatform isMacOSX or: [ aPlatform isUnix ] ])
		ifTrue: [ 
			self 
				executeUsingUnixSubProcessRepoDirectory: repoDirectory 
				parent: parent 
				onExit:  [ :process :outString :errString |
					succedded := process isSuccess.
					stdOut := outString.
					stdErr := errString ]  ].
	
	succedded 
		ifFalse: [ 
			location ensureDeleteAll.
			(stdErr includesSubstring: 'Permission denied (publickey)') ifTrue: [ IceAuthenticationError signal: stdErr ].
			IceGenericError signal: stdErr ].
]

{ #category : 'executing' }
IceGitCloneUsingCommandLineTool >> executeUsingUnixSubProcessRepoDirectory: repoDirectory parent: parent onExit: onExitBlock [

	OSSUnixSubprocess new
		command: '/usr/bin/git';
		arguments: {
				'clone'.
				url.
				repoDirectory };
		workingDirectory: parent fullName;
		redirectStdout;
		redirectStderr;
		runAndWaitOnExitDo: onExitBlock
]

{ #category : 'accessing' }
IceGitCloneUsingCommandLineTool >> location: aFileLocator [ 
	location := aFileLocator
]

{ #category : 'accessing' }
IceGitCloneUsingCommandLineTool >> url: aString [ 
	url := aString
]
