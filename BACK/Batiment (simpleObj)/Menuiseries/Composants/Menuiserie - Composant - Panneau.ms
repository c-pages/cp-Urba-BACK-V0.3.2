
plugin simpleObject		menuiserie_composant_panneau
name:"Panneau"
classID:#(0x7094146b, 0x7896bea1)
category:"CP | Menuiserie | Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="menuiserie_composant_panneau"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	parameters params_general rollout:roll_general
	(
		
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 				default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 				default:0.
		
		----- remplis -------------
		vitrage_epaisseur				type:#worldUnits 	ui:spn_remplis_ep			default:2.
		
		----- les divisions -------------
		div_montants_nbr		 	type:#integer		 	ui:spn_div_montants_nbr	default:0
		div_traverses_nbr			type:#integer		 	ui:spn_div_traverses_nbr	default:0
		div_calage_verti	 			type:#worldUnits	 	ui:spn_div_calage_verti		default:0.
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur			default:4.
		div_profondeur	 			type:#worldUnits 	ui:spn_div_profondeur			default:4.
		
		----- pour rester dans valeurs corrects ------------------------
		on longueur 					set val do corriger_parametres ()
		on profondeur			 		set val do corriger_parametres ()
		on hauteur 					set val do corriger_parametres ()
		
		on vitrage_epaisseur 		set val do corriger_parametres ()
		on div_profondeur		 	set val do corriger_parametres ()
		on div_largeur			 		set val do corriger_parametres ()		
		on div_montants_nbr		set val do corriger_parametres ()
		on div_traverses_nbr 		set val do corriger_parametres ()
		on div_calage_verti			set val do corriger_parametres ()
		
	)	-----	fin parametres --------------------
	
	parameters params_divers rollout:roll_divers
	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis		default:1
		matId_remplis					type:#integer 			ui:spn_matId_remplis		default:2
)
	
	rollout roll_general  "Paramètres"
	(
		spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		
		group "Remplissage" (
			spinner spn_remplis_ep			"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
		)
		group "Division" (
			spinner spn_div_montants_nbr	 "Nbr. montants" 		type:#integer			range:[0,1e20,0]
			spinner spn_div_traverses_nbr	"Nbr. traverses" 		type:#integer			range:[0,1e20,0]
			spinner spn_div_largeur			"Largeur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_div_profondeur		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
			spinner spn_div_calage_verti 	"Calage vertical" 		type:#worldunits		range:[-1e20,1e20,0]
		)
	)
	rollout roll_divers  "Divers"
	(
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 				type:#integer range:[1,1000,1]
			spinner spn_matId_remplis 	"Remplissage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn corriger_parametres 	=(
		
		if div_profondeur < vitrage_epaisseur do  div_profondeur = vitrage_epaisseur 
			
		if longueur  < div_montants_nbr * div_largeur do 
			div_montants_nbr = longueur   / div_largeur
		
		if  hauteur< div_traverses_nbr * div_largeur do 
			div_traverses_nbr = hauteur / div_largeur
		
		local div_decal_max = ( hauteur -  div_traverses_nbr *div_largeur ) / ( div_traverses_nbr  + 1 )		
		if div_calage_verti > div_decal_max do	div_calage_verti = div_decal_max 		
		if div_calage_verti < - div_decal_max do	div_calage_verti = -div_decal_max 
	)
	
	

	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		
		
		----Données ------------	
		local posY_remplis		=	- vitrage_epaisseur/2
		local posY_div			=	- ( div_profondeur/2 )		
		
		local espace_div_H 		= ( longueur - div_montants_nbr * div_largeur ) / ( div_montants_nbr + 1 )
		local depose_div_H		= [ espace_div_H, 	posY_div,		0	]
		
		local espace_div_V 		= ( hauteur - div_traverses_nbr * div_largeur ) / ( div_traverses_nbr + 1 )
		local depose_div_V		= [0, 	posY_div,		 espace_div_V  + div_calage_verti	]
		
		
		
		---- le remplis ----------
		local compo_remplis = if low_poly 	then	 createInstance  urba_primitive_planVertical		matId:matId_remplis
														else	 createInstance  urba_primitive_boite				matId:matId_remplis		
		compo_remplis.longueur		=	longueur
		compo_remplis.hauteur			=	hauteur
		if not low_poly 	do compo_remplis.profondeur		=	vitrage_epaisseur		
		mgr_mesh.attacher		mesh		compo_remplis 	transf:[0,posY_remplis,0]
		
		
		-------- divisions  --------------
		local compo_div = if low_poly 	then	 createInstance  urba_primitive_boite_U		matId:matId_menuis
													else	 createInstance  urba_primitive_boite			matId:matId_menuis
		-------- divisions horizontales --------------
		for i = 1 to div_montants_nbr do (
			
			compo_div.longueur			=	div_largeur
			compo_div.profondeur		=	div_profondeur
			compo_div.hauteur			=	hauteur
			compo_div.symetrie			=	false
			compo_div.horizontal		=	false
			
			mgr_mesh.attacher		mesh		compo_div 	transf:depose_div_H
			
			depose_div_H.x += espace_div_H + div_largeur
		)
		
		-------- divisions verticales --------------
		for i = 1 to div_traverses_nbr do (
			
			compo_div.longueur			=	longueur
			compo_div.profondeur		=	div_profondeur
			compo_div.hauteur			=	div_largeur
			compo_div.symetrie			=	false
			compo_div.horizontal		=	true
			
			mgr_mesh.attacher		mesh		compo_div 	transf:depose_div_V
			
			depose_div_V.z += espace_div_V + div_largeur
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
				3: #stop
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
					
					pt_hauteur				=	gridPoint
				)
				3:	hauteur 					= length ( gridPoint - pt_hauteur )

			)		
	) --- fin tool create ---------
	
	
	
	
)   --- fin	plugin -----------------











