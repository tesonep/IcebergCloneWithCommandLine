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
					stdErr := errString ]  ]
		ifFalse: [ 
			self 
				executeUsingWindowsSubProcessRepoDirectory: repoDirectory 
				parent: parent 
				onExit:  [ :process :outString :errString |
					succedded := process isSuccess.
					stdOut := outString.
					stdErr := errString ] 
			 ].
	
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

{ #category : 'executing' }
IceGitCloneUsingCommandLineTool >> executeUsingWindowsSubProcessRepoDirectory: repoDirectory parent: parent onExit: onExitBlock [

	| stderrFile stdoutFile command return |
	stderrFile := FileLocator temp / 'git-stderr.txt'.
	stdoutFile := FileLocator temp / 'git-stdout.txt'.

	command := String streamContents: [ :stream |
		           stream
			           nextPutAll: 'git clone ';
			           nextPutAll: url;
			           nextPutAll: ' ';
			           nextPutAll: repoDirectory;
			           nextPutAll: ' 2> ';
			           nextPutAll: stderrFile fullName;
			           nextPutAll: ' 1> ';
			           nextPutAll: stdoutFile fullName ].

	return := OSWSWinProcess new
		          shellCommand: command;
		          workingDirectory: parent fullName;
		          runAndWait.

	onExitBlock
		value: return
		value: stdoutFile contents
		value: stderrFile contents.

	stderrFile ensureDelete.
	stdoutFile ensureDelete
]

{ #category : 'accessing' }
IceGitCloneUsingCommandLineTool >> location: aFileLocator [ 
	location := aFileLocator
]

{ #category : 'accessing' }
IceGitCloneUsingCommandLineTool >> url: aString [ 
	url := aString
]
