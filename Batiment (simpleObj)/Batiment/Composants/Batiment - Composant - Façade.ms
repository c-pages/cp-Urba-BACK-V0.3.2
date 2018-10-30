
plugin simpleObject		batiment_composant_facade
name:"Façade"
classID:#(0x52a049eb, 0xc56c437)
category:"CP | Bâtiment	| Composant"
-- invisible:true
(
	
	parameters params_global rollout:rol_global	(
		longueur 		type:#worldUnits 	ui:spn_longueur 			default:0
		hauteur 			type:#worldUnits 	ui:spn_hauteur 			default:0
		profondeur	 	type:#worldUnits 	ui:spn_profondeur		default:0
	)
	parameters params_general rollout:roll_parametres	(
		
		sequence					type:#maxObjectTab	tabSizeVariable:true
		sequence_elem_long		type:#floatTab			tabSizeVariable:true
		
	
	)	-----	fin parametres --------------------
	parameters params_divers rollout:roll_divers	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee	default:3
		
	)	-----	fin parametres --------------------
	
	rollout rol_global  "Global"	(
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_profondeur		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
	)
	
	rollout roll_parametres  "Paramètres"	(		
		
		fn get_menuiserie_plugins =(
			local geo_classes			=	GeometryClass.classes 
			local menuiseries_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"urba_menuiserie_" != undefined	 and geo_classe != urba_menuiserie_ensemble	collect	geo_classe
			menuiseries_classes
		)
		fn creer_RCM_ajouter	=(

			--- on recupere les plug necessaires ---------
			local menuiseries_plugins = get_menuiserie_plugins ()
			
			--- on ecrit le menu ---------
			local menu_txt=""
			menu_txt += "rcmenu  menu_ajouter (\n"
			
			
			---- les boutons ------------------------
			---- menuiseries ------------
			menu_txt +=			"subMenu \"Menuiseries\" (\n"
			for menuis_plug in menuiseries_plugins do
				menu_txt += "menuItem	btn_" + menuis_plug.name as string + "	\"" + menuis_plug.name + "\"\n" 
			
			menu_txt += "menuItem	btn_ensemble 	\"Ensemble menuisé\"\n" 
			
-- 			menu_txt += "separator sep1\n"
			menu_txt +=			")\n"
			
			---- les evenements ----
			for menuis_plug in menuiseries_plugins do
				menu_txt += "on		btn_" + menuis_plug.name as string + " picked do $.ajouter_element " + menuis_plug as string+ "\n" 
			menu_txt += ")"
			
			---- on ouvre le menu -----
			RCmenu_ajouter	=	execute menu_txt
			popUpMenu	RCmenu_ajouter
			
		) --- fin creer_RCM_ajouter ---------------
		
		
-- 		spinner 	spn_aling_prof 		"Alignement" 		type:#worldunits range:[0,1e20,0]
		
		button 		btn_ajouter 		"+"			across:4
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"
		
		listBox		lbx_sequence		""	height:5
		
		spinner 	spn_elem_long		"Longeur" 		type:#worldunits range:[0,1e20,0]
		
		subrollout	subroll_param		""	height:300
		
		fn actualiser =(
			lbx_sequence.items =  for compo in sequence collect ( classof compo ).name
			
			--- les parametres de l'element (le subrollout)  ---------------			
			if lbx_sequence.selection > 0 do (
				
				--- on retire les vieux rollouts --------
				if subroll_param.rollouts.count > 0 do 
					for subRoll in subroll_param.rollouts  do
						removeSubRollout subroll_param	subRoll
				
				---- on ajoute le nouveau -----------------
				local composant_actif 		=  sequence[  lbx_sequence.selection ]
				addSubRollout 	subroll_param		composant_actif.roll_parametres
				
				spn_elem_long.value = sequence_elem_long[  lbx_sequence.selection ]
			)
			
		) --- fin actualiser -----------
		
		
		
		
		
		on roll_parametres		open 				do 	actualiser ()
		on lbx_sequence 		selected sel 	do	actualiser ()
		
		
		
		
		on btn_ajouter 		pressed 			do 	creer_RCM_ajouter ()
		on btn_retirer 		pressed 			do	retirer_element 		lbx_sequence.selection 
		on btn_monter 		pressed 			do	monter_element 		lbx_sequence.selection 
		on btn_descendre 	pressed		 	do	descendre_element 	lbx_sequence.selection 
		on spn_elem_long 	changed val	do	(
			sequence_elem_long[  lbx_sequence.selection ] = val
			redrawviews ()
		)
		
	)
	
	rollout roll_divers  "Divers"	(
		group "Qualité" (
			checkbox	shk_lowPoly				"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 			"Menuiseries" 			type:#integer 			range:[1,1000,1]
			spinner spn_matId_vitrage 			"Vitrage" 				type:#integer 			range:[1,1000,1]
			spinner spn_matId_poignee 			"Poignée" 				type:#integer 			range:[1,1000,1]
		)
		
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	
	
	on hasUVW do map_coords
		
	on setGenUVW bool do map_coords = bool
		
	
	on buildMesh do
	(
		
		--- on vide le mesh ----------
		delete mesh
		/* 
		--- on place les points ---------
		local pt_1	=	[0,0,0]
		local pt_2	=	[longueur,0,0]
		local pt_3	=	[longueur,0,hauteur]
		local pt_4	=	[0,0,hauteur]
		local pt_5	=	[0,profondeur,hauteur]
		local pt_6	=	[longueur,profondeur,hauteur]
		local pt_7	=	[0,profondeur,0]
		local pt_8	=	[longueur,profondeur,0]
		
		local pts 	= #(pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8) 
		
		----- on creer les faces --------------
		local faces = #(	[1,2,3], [1,3,4],		[2,8,6], [2,6,3],		[7,1,4], [7,4,5]  ,		[4,3,6], [4,6,5],		[8,7,5], [8,5,6],		[2,1,7], [2,7,8] )
	
		--- mat ID ------
		local matIDs	= for i in faces collect MatId
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts	faces:faces	materialIDs:matIDs
		
		----- On clean le mesh 	--------------
		meshop.autoSmooth		mesh 	#{1..mesh.numfaces} 		10
		meshop.autoEdge 		mesh 	#{1..mesh.Edges.count}	10	
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		 */
	) --------- fin on build mesh --------------------------
	
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				4: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	hauteur 					= length ( gridPoint - pt_hauteur )
			)
		
	) ----- fin tool create -------------
) --------- fin plugin --------------


