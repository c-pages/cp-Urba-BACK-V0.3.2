macroScript Urba_quartier_reload
category:"#CPages"
buttonText:"reload quartier"
-- icon:#("Labib", 1)
toolTip:""
(
	clearListener ()
	
	--- on importe
	filein	 ( getdir #userStartupScripts + "\Quartier - Startup.ms" )
	

)