Class {
	#name : 'BaselineOfIcebergCloneWithCommandLine',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfIcebergCloneWithCommandLine',
	#package : 'BaselineOfIcebergCloneWithCommandLine'
}

{ #category : 'baselines' }
BaselineOfIcebergCloneWithCommandLine >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		
		Smalltalk os isWindows
			ifTrue: [ self osWinSubprocess: spec ]
			ifFalse: [ self osSubprocess: spec ].
		
		spec 
			package: 'Iceberg-Git-Tool' ].

]

{ #category : 'baselines' }
BaselineOfIcebergCloneWithCommandLine >> osSubprocess: spec [

	spec 
		baseline: #OSSubprocess
		with: [ spec repository: 'github://pharo-contributions/OSSubprocess:master/repository' ]
]

{ #category : 'baselines' }
BaselineOfIcebergCloneWithCommandLine >> osWinSubprocess: spec [

	spec 
		baseline: #OSWinSubprocess
		with: [ spec repository: 'github://pharo-contributions/OSWinSubprocess:master/src' ]

]
