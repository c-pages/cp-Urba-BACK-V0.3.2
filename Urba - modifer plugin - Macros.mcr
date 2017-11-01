

macroScript creerBatiments
category:"#CPages"
buttonText:"Batiments"
toolTip:"Creer un batiment sur chacune des splines selectionnées."
(
	with redraw off (
		local bats = #()
		for obj in selection where superClassof obj == shape do(
			bat = urba_batiment ()
			bat.assigner_trace 	obj	bat
			bat.wirecolor = obj.wireColor
			append bats bat
		)
		select bats
	)
)



macroScript collerStyle_Batiments
category:"#CPages"
buttonText:"coller style Bat."
toolTip:""
(
	with redraw off (
		
		for obj in selection where classof obj as string == "urba_batiment" do(
			format "obj : %\n" obj.name
			obj.presets.coller obj
			
			obj.facades.params_toStructs 	obj
		
			obj.trace.actualiser obj
			obj.construire.batiment obj
			obj.actualiser_rollouts()
		)
		
	)
)


