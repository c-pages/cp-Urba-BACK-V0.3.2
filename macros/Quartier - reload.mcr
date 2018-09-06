macroScript Urba_quartier
category:"#CPages"
buttonText:"reload Quartier"
toolTip:"DEBUG : recompile le plugin Urba | Quartier"
(

		gc()
		clearListener ()
		
		filein	 ( getdir #userStartupScripts + "\Quartier - Startup.ms" )
		
		for obj in geometry where classof obj == Urba_quartier	do delete obj
		popo = Urba_quartier()
		select popo
		
)
