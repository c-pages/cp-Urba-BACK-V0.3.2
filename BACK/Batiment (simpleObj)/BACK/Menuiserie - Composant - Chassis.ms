
plugin simpleObject		menuiserie_composant_chassis
name:"Chassis"
classID:#(0x7094146b, 0x7896bea1)
category:"CP | Menuiserie | Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuis_fix"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -------------
		menuis_epaisseur	 			type:#worldUnits 	ui:spn_epaisseur			default:0.
		vitrage_epaisseur				type:#worldUnits 	default:2.
		
		----- les divisions -------------
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		------ cadre --------------
		cadre_use						type:#boolean 		ui:shk_cadre				default:true
		montant_G						type:#boolean 		ui:shk_montant_G		default:true
		montant_D						type:#boolean 		ui:shk_montant_D		default:true
		traverse_B						type:#boolean 		ui:shk_traverse_B		default:true
		traverse_B_epaisseur		type:#worldUnits 	ui:spn_traverse_B_ep	default:0.
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		----- pour rester dans valeurs corrects ------------------------
		on menuis_epaisseur 		set val do corriger_parametres ()
		on longueur 					set val do corriger_parametres ()
		on hauteur 					set val do corriger_parametres ()
		
		on menuis_epaisseur 		set val do corriger_parametres ()
		on profondeur			 		set val do corriger_parametres ()
		on hauteur 					set val do corriger_parametres ()
		on traverse_B_epaisseur 	set val do 	corriger_parametres ()
		
		
		on div_horiz			 		set val do corriger_parametres ()
		on div_verti 					set val do corriger_parametres ()
		on div_epaisseur			 	set val do (
			if val > profondeur do profondeur = val
			corriger_parametres ()
		)
		
	)	-----	fin parametres --------------------
	
	
	rollout roll_general  "Chassis"
	(
		group "Global" (
			spinner spn_longueur 			"longueur" 					type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 			"Hauteur" 					type:#worldunits range:[0,1e20,0]
		)
		group "Cadre" (
			checkbox	shk_cadre				"Cadre" 			
			spinner 	spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
			spinner 	spn_epaisseur	 		"Epaisseur" 				type:#worldunits range:[0,1e20,0]
			checkbox	shk_montant_G		"Montant gauche" 			
			checkbox	shk_montant_D		"Montant droit" 
			checkbox	shk_traverse_B		"traverse basse" 		
			spinner 	spn_traverse_B_ep	"Hauteur" 				type:#worldunits range:[0,1e20,0]
		)
		group "Division" (
			spinner spn_div_horiz	 		"Horizontale" 				type:#integer			range:[0,1e20,0]
			spinner spn_div_verti	 		"Verticale" 					type:#integer			range:[0,1e20,0]
			spinner spn_div_epaisseur	"Epaisseur" 					type:#worldunits 	range:[0,1e20,0]
		)
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 				type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 	"Vitrage" 					type:#integer range:[1,1000,1]
		)
		
		fn actualiser = (
			
			spn_profondeur.Indeterminate 	= not cadre_use
			spn_profondeur.enabled 			= cadre_use
			spn_epaisseur.Indeterminate 		= not cadre_use
			spn_epaisseur.enabled 				= cadre_use
			
			shk_montant_G.enabled 		= cadre_use
			shk_montant_D.enabled 		= cadre_use
			shk_traverse_B.enabled 		= cadre_use
			
			spn_traverse_B_ep.Indeterminate 	= not traverse_B or  not cadre_use
			spn_traverse_B_ep.enabled 			= traverse_B and cadre_use
		)
		
		on roll_general		open 				do	actualiser ()		
		on shk_cadre			changed val 	do	actualiser ()
		on shk_traverse_B	changed val 	do	actualiser ()
		
	) 	---- fin rollout	-----------------------
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn corriger_parametres 	=(
		
		local longueurMax	=	longueur/2
		if not montant_G	and montant_D 	or not montant_D	and montant_G do longueurMax = longueur
		local hauteurMax		= hauteur /2
		if not	traverse_B do hauteurMax =	hauteur
			
		
		if montant_G	or  montant_D 	do
			if menuis_epaisseur >longueurMax do menuis_epaisseur = longueurMax
		
		---- epaisseur des menuiseries --------
		if menuis_epaisseur + traverse_B_epaisseur > hauteur do (
			local rapport 				=  traverse_B_epaisseur	/	( menuis_epaisseur + traverse_B_epaisseur ) 
			menuis_epaisseur 		= 	hauteur *  ( 1- rapport)
			traverse_B_epaisseur 	=	hauteur *	rapport
		)
		 
		---- les divisions ----------
		if div_epaisseur > profondeur do  div_epaisseur = profondeur 
		if longueur - 2*menuis_epaisseur < div_horiz * div_epaisseur do 
			div_horiz = ( longueur - 2*menuis_epaisseur  ) / div_epaisseur
		local hauteurMax = if traverse_B 	then hauteur - ( menuis_epaisseur  + traverse_B_epaisseur )
														else	hauteur - menuis_epaisseur
		if  hauteurMax< div_verti * div_epaisseur do 
			div_verti = hauteurMax / div_epaisseur
		
	)
	
	

	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		
		--- Données  ---------------------------------------------------------------------------------------
		local posX_traverses	=	if montant_G	and cadre_use	then menuis_epaisseur 		else 0
		local posY_traverses	=	if traverse_B  	and cadre_use	then traverse_B_epaisseur 	else 0
		
		local espace_vide_H	=	longueur
		if montant_G	and cadre_use	do espace_vide_H 	-= menuis_epaisseur
		if montant_D	and cadre_use	do espace_vide_H -= menuis_epaisseur
		local espace_vide_V 	=  if  cadre_use	then	(hauteur - 	menuis_epaisseur	- posY_traverses		)	else 	(hauteur - 	posY_traverses		)	
		
		local espace_div_H 		= ( espace_vide_H - div_horiz * div_epaisseur ) / ( div_horiz + 1 )
		local depose_div_H		= [posX_traverses + espace_div_H, 	profondeur/2 -  div_epaisseur / 2,		posY_traverses	]
		local espace_div_V 		= ( espace_vide_V - div_verti * div_epaisseur ) / ( div_verti + 1 )
		local depose_div_V		= [posX_traverses, 	profondeur/2 -  div_epaisseur / 2,		posY_traverses  + espace_div_V 	]
		
		local pos_vitrage = if low_poly 	then		[posX_traverses,	profondeur/2, posY_traverses]
													else		[posX_traverses, profondeur/2 -  vitrage_epaisseur / 2,		posY_traverses ]	
		
		
		
		--- Construction ---------------------------------------------------------------------------------------
		----- les composants ----------------
		local compo_menuis	= 	if low_poly 	then	createInstance  urba_primitive_boite_U		matId:matId_menuis
														else	createInstance  urba_primitive_boite			matId:matId_menuis
		
		--- montant  gauche ----------
		if montant_G 	and cadre_use	do (
			compo_menuis.longueur			=	menuis_epaisseur
			compo_menuis.profondeur		=	profondeur
			compo_menuis.hauteur			=	hauteur
			
			mgr_mesh.attacher		mesh		compo_menuis
		)
		
		--- montant droite ----------
		if montant_D and cadre_use	do (
			compo_menuis.longueur			=	menuis_epaisseur
			compo_menuis.profondeur		=	profondeur
			compo_menuis.hauteur			=	hauteur
			compo_menuis.symetrie			=	true
			
			mgr_mesh.attacher		mesh		compo_menuis 	transf:[longueur - menuis_epaisseur,0,0]				
		)
		
		local compo_menuis	= 	if low_poly 	then	createInstance  urba_primitive_boite_L		matId:matId_menuis
														else	createInstance  urba_primitive_boite			matId:matId_menuis
		--- traverse basse ----------
		if traverse_B and cadre_use	do (			
			compo_menuis.longueur			=	espace_vide_H
			compo_menuis.profondeur		=	profondeur
			compo_menuis.hauteur			=	traverse_B_epaisseur
			compo_menuis.symetrie			=	false
			compo_menuis.horizontal		=	true
			
			mgr_mesh.attacher		mesh		compo_menuis 	transf:[posX_traverses,0,0]				
		)
		
		--- traverse	haute ----------
		if cadre_use	do (	
			compo_menuis.longueur			=	espace_vide_H
			compo_menuis.profondeur		=	profondeur
			compo_menuis.hauteur			=	menuis_epaisseur
			compo_menuis.symetrie			=	true
			compo_menuis.horizontal		=	true
			
			mgr_mesh.attacher		mesh		compo_menuis 	transf:[posX_traverses,0,hauteur - menuis_epaisseur]
		)
		
		
		---- le vitrage ----------
		local compo_vitrage = if low_poly 	then	 createInstance  urba_primitive_planVertical		matId:matId_vitrage
														else	 createInstance  urba_primitive_boite				matId:matId_vitrage
		
		compo_vitrage.longueur		=	espace_vide_H
		compo_vitrage.hauteur			=	espace_vide_V
		if not low_poly 	do compo_vitrage.profondeur		=	vitrage_epaisseur
		
		mgr_mesh.attacher		mesh		compo_vitrage 	transf:pos_vitrage
		
		
		
		
		-------- divisions  --------------
		local compo_div = if low_poly 	then	 createInstance  urba_primitive_boite_U		matId:matId_menuis
													else	 createInstance  urba_primitive_boite			matId:matId_menuis
		for i = 1 to div_horiz do (
			
			compo_div.longueur			=	div_epaisseur
			compo_div.profondeur		=	div_epaisseur
			compo_div.hauteur			=	espace_vide_V
			compo_div.symetrie			=	false
			compo_div.horizontal		=	false
			
			mgr_mesh.attacher		mesh		compo_div 	transf:depose_div_H
			
			depose_div_H.x += espace_div_H + div_epaisseur
		)
		
		-------- divisions verticales --------------
		for i = 1 to div_verti do (
			
			compo_div.longueur			=	espace_vide_H
			compo_div.profondeur		=	div_epaisseur
			compo_div.hauteur			=	div_epaisseur
			compo_div.symetrie			=	false
			compo_div.horizontal		=	true
			
			mgr_mesh.attacher		mesh		compo_div 	transf:depose_div_V
			
			depose_div_V.z += espace_div_V + div_epaisseur
		)
		
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
	)  ----- fin on buld mesh -----------------
		
		
		
		
		
		
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				5: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= 	length 		( gridPoint - pt_debut )
					local norm_dir 		=	normalize 	(gridPoint - pt_debut )
					local angle_pts		=	acos			(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= 	length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
				)
				5: (
					
					menuis_epaisseur 	= length ( gridPoint - pt_epaisseur )
					traverse_B_epaisseur = menuis_epaisseur
				)
			)		
	) --- fin tool create ---------
	
	
	
	
)   --- fin	plugin -----------------











