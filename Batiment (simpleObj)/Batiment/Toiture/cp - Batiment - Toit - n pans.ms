

plugin simpleObject		batiment_composant_toiture_nPans
name:"Toit n pans"
classID:#(0x484f89fb, 0x546888a1)
category:"CP | Bâtiment	| Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="batiment_composant_toiture_nPans"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres , 	actualiser_composants 
	local	set_points
	local est_instance
	
	local sequence_tmp
	
	
	---- managers		 -------------------
	local mgr_mesh 			=	str_mgr_mesh ()
	local mgr_shape 			=	str_mgr_shape ()
	local mgr_squelette		=	str_squelettisation ()
	
	
	
	parameters params_general rollout:roll_general	(
		
		----- global ---------------------
		points_surface					type:#point3Tab  	tabSizeVariable:true
		pente		 					type:#float			 	ui:spn_pente				default:20.
		decallage						type:#worldUnits		ui:spn_decallage			default:10.
		
		debord_use						type:#boolean 		ui:shk_debord				default:true
		debord_longueur				type:#worldUnits		ui:spn_debord_lg			default:30.
		debord_hauteur				type:#worldUnits		ui:spn_debord_ht			default:20.
		
	)
	
	parameters params_divers rollout:roll_divers	(
		
		nom	 							type:#string 			default:"Facade"
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_toiture					type:#integer 			ui:spn_toiture				default:5
		matId_corniche				type:#integer 			ui:spn_corniche			default:4
		
	)	-----	fin parametres --------------------
	
	
	rollout roll_points "Points" (
		pickButton pkbtn_pts	"pick shape" 
		
		on pkbtn_pts picked shp do (
			local shp_points = for i = 1 to numknots shp collect getKnotPoint  shp 1 i 
			set_points	shp_points
			
		)
	)
	
	
	rollout roll_general 			"Paramètres"	(
		
		spinner spn_pente	 				"Pente (°)" 				type:#float range:[0,80,0]
		spinner spn_decallage 				"Decallage" 			type:#worldunits range:[0,1e20,0]
		
		group "Corniche" (
			checkbox	shk_debord			"Corniche"
			spinner spn_debord_lg 			"Longueur" 			type:#worldunits range:[0,1e20,0]
			spinner spn_debord_ht 			"Hauteur" 			type:#worldunits range:[0,1e20,0]
		)
		
		fn actualiser =(
			
			spn_debord_lg.indeterminate		=	not debord_use
			spn_debord_lg.enabled 				=	debord_use
			spn_debord_ht.indeterminate		=	not debord_use
			spn_debord_ht.enabled 				=	debord_use
		)
		
		
		on shk_debord changed state do actualiser ()
	)
	
	rollout roll_divers  			"Divers"			(
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_toiture 		"Toiture" 			type:#integer range:[1,1000,1]
			spinner spn_corniche 		"Corniche" 			type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	------------ FONCTIONS	----------------------------------------------------------------------------------
	fn initialiser =(
		mgr_mesh 			=	str_mgr_mesh ()
		mgr_squelette		=	str_squelettisation ()
	)
	
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
-- 		--- rester dans les bonnes limites ------
-- 		if align_prof > profondeur do align_prof = profondeur
		
		/* 
		--- longueur de l'ensemble ----------
		local longueur_est_contrainte = true
		local longueur_contrainte = 0
		for elem_long in sequence_elem_long do
			if elem_long == 0 do longueur_est_contrainte	=	false
		if longueur_est_contrainte and sequence.count > 0  do (
			for elem_long in sequence_elem_long do (
				longueur_contrainte += elem_long
				longueur_contrainte += cadre_largeur
			)
			longueur_contrainte += cadre_largeur
			longueur = longueur_contrainte
		)
		 */
	)
	
	
	
	
	fn set_points _pts =(
		points_surface = for pt in _pts collect pt
	)
	
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (

		
	)  --- fin composants_actualiser  -----------------------------------------------------------------------
	
	fn actualiser = (
		
		corriger_parametres ()		
		actualiser_composants()		
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
		
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		if points_surface.count > 0 do (
			
			
			
-- 			meshop.createPolygon <Mesh mesh> <vertIndex array> smGroup:<int=0> matID:
			
			local pts 		= #()
			local faces		= #()
			local matIds	= #()
			local id_pt		=	1
			
			local pts_toiture
			
			-----	la corniche	------------------------------------------
			local pts_corniche 	= for pt in  points_surface collect pt			
			local pts_sousFace 	= mgr_shape.retrecir_polygone	pts_corniche	-debord_longueur
			local pts_epaisseur 	= deepcopy pts_sousFace
			pts_epaisseur.z +=	debord_hauteur
			local pts_toiture 	
			
			if debord_use then pts_toiture	= mgr_shape.retrecir_polygone	pts_epaisseur	decallage
			else pts_toiture	= mgr_shape.retrecir_polygone	pts_corniche	decallage
			
			for i = 1 to points_surface.count do (
				
				local j= if i == points_surface.count then 1 else i + 1
				
				if debord_use then (
					---- la sous face ------------
					pts 		+= #( pts_corniche[i], pts_corniche[j], pts_sousFace[j], pts_sousFace[i]	)
					faces		+=	#( [ id_pt, id_pt +1 , id_pt +2 ] ,  [ id_pt, id_pt +2 , id_pt +3 ] )
					matIds	+=	#( matId_corniche, matId_corniche )
					
					id_pt 	+=	4
					
					
					---- l'epaisseur --------------
					pts 		+= 	#( pts_sousFace[i], pts_sousFace[j], pts_epaisseur[j], pts_epaisseur[i]	)
					faces		+=	#( [ id_pt, id_pt +1 , id_pt +2 ] ,  [ id_pt, id_pt +2 , id_pt +3 ] )
					matIds	+=	#( matId_corniche, matId_corniche )
					
					id_pt 	+=	4
						
					---- decallage toiture --------------
					pts 		+= 	#( pts_epaisseur[i], pts_epaisseur[j], pts_toiture[j], pts_toiture[i]	)
					faces		+=	#( [ id_pt, id_pt +1 , id_pt +2 ] ,  [ id_pt, id_pt +2 , id_pt +3 ] )
					matIds	+=	#( matId_corniche, matId_corniche )
					
					id_pt 	+=	4
					
					
				) else (
					---- decallage toiture --------------
					pts 		+= 	#( pts_corniche[i], pts_corniche[j], pts_toiture[j], pts_toiture[i]	)
					faces		+=	#( [ id_pt, id_pt +1 , id_pt +2 ] ,  [ id_pt, id_pt +2 , id_pt +3 ] )
					matIds	+=	#( matId_corniche, matId_corniche )
					
					id_pt 	+=	4
				
				)
			)
			
				
			
			
			
			-----	les pans 		---------------
			local faces_squel = mgr_squelette.exe 		pts_toiture 	pente:pente
			
-- 			debug "faces_squel" var:faces_squel
-- 			local pts 		= #()
-- 			local faces		= #()
-- 			local matIds	= #()
-- 			local id_pt		=	1
			
			for face_squel in faces_squel do (
				
				pts 		+=	face_squel.pts
				faces		+=	#( [ id_pt, id_pt +1 , id_pt +2 ] ,  [ id_pt, id_pt +2 , id_pt +3 ] )
				matIds	+=	#( matId_toiture, matId_toiture )
				
				id_pt 	+=	4
			)
			
			
			
			setMesh 	mesh 	verts:pts	faces:faces	materialIDs:matIds
			
			for i = 1 to	faces.count do
				setFaceSmoothGroup mesh i 0
			
			
			meshop.autoEdge mesh (#{1..mesh.Edges.count} as array )  2.
			
			
			----- le mapping 	--------------
			meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
			
			
			
			
			
			
			
		)
		
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
				1: (	
						nodeTM.translation = gridPoint
						#stop
				)
			)
	
	) --- fin tool create ---------
	
	
	on update 	do initialiser ()
	on create  	do initialiser ()
	on load  	do initialiser ()
	
) --------- fin plugin --------------

























