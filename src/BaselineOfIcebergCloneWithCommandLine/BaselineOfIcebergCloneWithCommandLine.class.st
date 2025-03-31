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
		spec 
			package: 'Iceberg-Git-Tool' ].

]
