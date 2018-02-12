

macroScript Urba_OSM_importer
category:"#CPages"
buttonText:"OSM"
-- icon:#("Labib", 1)
toolTip:""
(
	/* 
	fileIn	 "$userScripts\cp-urba\Urba - OSM Importer.ms" 

	
	 on execute do (
		::OSMImporter.toggle_ouverture ()
	 )
	
	on isChecked return try ( ::OSMImporter.estOuvert () )  catch	( false )	 
	 */
	
		try 	destroydialog ::OSMImporter.m_dialog		catch ()
		clearListener ()
	fileIn	 "$userScripts\cp-urba\Urba - OSM Importer.ms" 
		::OSMImporter.toggle_ouverture ()
	
)
