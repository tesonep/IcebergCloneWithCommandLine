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
					stdErr := errString ] ]
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

	| outFullStream errFullStream osUnixSubprocessClass |

	osUnixSubprocessClass := self class environment 
		at: #OSSUnixSubprocess 
		ifAbsent: [ self error: 'Missing OSSUnixSubprocess class' ]. 

	outFullStream := WriteStream on: (String new: 10000).
	errFullStream := WriteStream on: (String new: 10000).

	osUnixSubprocessClass new
		command: '/usr/bin/git';
		arguments: {
				'clone'.
				'--progress'.
				url.
				repoDirectory };
		workingDirectory: parent fullName;
		redirectStdout;
		redirectStderr;
		runAndWaitPollingEvery: 1000 milliSecond asDelay 
		doing: [:process :stdStream :errStream | 
			outFullStream nextPutAll: stdStream upToEnd.
			errFullStream nextPutAll: errStream upToEnd.
			self updateJobStatus: errFullStream contents]

		onExitDo: [:process :stdStream :errStream | 
			
			outFullStream nextPutAll: stdStream upToEnd.
			errFullStream nextPutAll: errStream upToEnd.
			onExitBlock 				
				value: process 
				value: outFullStream contents
				value: errFullStream contents. ].

]

{ #category : 'executing' }
IceGitCloneUsingCommandLineTool >> executeUsingWindowsSubProcessRepoDirectory: repoDirectory parent: parent onExit: onExitBlock [

	| stderrFile stdoutFile command return osWSWinProcessClass |

	osWSWinProcessClass := self class environment 
		at: #OSWSWinProcess 
		ifAbsent: [ self error: 'Missing OSWSWinProcess class' ]. 

	stderrFile := FileLocator temp / 'git-stderr.txt'.
	stdoutFile := FileLocator temp / 'git-stdout.txt'.

	command := String streamContents: [ :stream |
		           stream
			           nextPutAll: 'git clone --progress ';
			           nextPutAll: url;
			           nextPutAll: ' ';
			           nextPutAll: repoDirectory;
			           nextPutAll: ' 2>> ';
			           nextPutAll: stderrFile fullName;
			           nextPutAll: ' 1>> ';
			           nextPutAll: stdoutFile fullName ].

	return := osWSWinProcessClass new
		          shellCommand: command;
					 creationFlags: 16r08000000 "CREATE_NO_WINDOW";
		          workingDirectory: parent fullName;
		          run.

	[return isRunning ] 
		whileTrue: [ 
			[self updateJobStatus: stderrFile contents] on: FileDoesNotExistException do: [  ].
			MorphicRenderLoop new doOneCycle.
			1 second wait ].

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

{ #category : 'executing' }
IceGitCloneUsingCommandLineTool >> updateJobStatus: outputString [

	| job lines lastLine progress matches |
	job := CurrentJob value.
	job ifNil: [ ^ self ].

	lines := outputString lines.
	lines ifEmpty: [ ^ self ].
	
	lastLine := lines last.
	
	(lastLine includesSubstring: 'Counting objects')
		ifTrue: [progress := 0].	
		
	(lastLine includesSubstring: 'Compressing objects')
		ifTrue: [progress := 25].	
			
	(lastLine includesSubstring: 'Receiving objects')
		ifTrue: [progress := 50].

	(lastLine includesSubstring: 'Resolving deltas')
		ifTrue: [progress := 75].
		
	(lastLine includesSubstring: 'done.')
		ifTrue: [progress := 100].
	
	matches := lastLine allRegexMatches: '(\d+)%'.
	matches ifNotEmpty: [  
		progress := progress + (matches first allButLast asNumber / 4)
	].
		
	progress ifNil: [ ^ self ].
	
	job value: progress
]

{ #category : 'accessing' }
IceGitCloneUsingCommandLineTool >> url: aString [ 
	url := aString
]
