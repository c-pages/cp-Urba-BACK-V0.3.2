macroScript Urba
category:"#CPages"
buttonText:"reload BatMod"
toolTip:"DEBUG : recompile le plugin Urba | Batiments"
(
/* 	
	global urba  	=	fileIn	 "$userScripts\cp-Urba\Urba.ms"  
		on execute do 	(
		
		if ( urba.estOuvert () )	
			then	urba.fermer	()
			else 	urba.ouvrir 	()
		
	)
	
	on isChecked return try ( urba.estOuvert () )  catch	( false )
	*/

-- 	on execute do 	(
		gc()
		clearListener ()
		
		for obj in objects where classof obj == Urba_Batiment do (
			try obj.vp_cacher_tout() catch ()
			delete obj
		)
		filein	 ( getdir #userStartupScripts + "\Batiment - Startup.ms" )
		
-- 			nvBat = Urba_Batiment ()
-- 		try 
-- 		cibleShape = $'OSM - B�timent - 022'
-- 		cibleShape = $'OSM - B�timent - 208'
-- 		cibleShape = $'OSM - B�timent - 186'
-- 			if cibleShape != undefined do (
-- 				trace = cibleShape
-- 				nvBat.assigner_shape 		nvBat		trace
-- 			)
-- 			catch ()
-- 			select nvBat
-- 			nvBat.pos=[0,0,0]
	-- 		::OSMImporter.ouvrir 	()		
-- 		) catch ()
-- 	)
)