
plugin simpleObject		cp_facadeCompo_mur
name:"Mur"
classID:#(0xd6ac532, 0x76610b21)
category:"CP | Facade	| Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_facadeCompo_mur"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pré déclaration -----------
	local corriger_parametres 
	
	--- composant ---
	local compo_cadre, compo_vitrage
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_global rollout:roll_global	(
		hauteur	 				type:#worldUnits 	ui:spn_hauteur 			default:0.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur		default:0.
	)
	parameters params_general rollout:roll_parametres	(
		nom	 					type:#string 			ui:edTxt_nom				default:"Mur"
		
		longueur 				type:#worldUnits 	ui:spn_longueur 			default:20.
		debord	 				type:#worldUnits 	ui:spn_debord				default:0.
-- 		etirable					type:#boolean 		ui:shk_etirable				default:true
		
		
		parent					type:#maxObject	
	)
	parameters params_divers rollout:roll_divers	(
		
		------ options --------------
		low_poly				type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId				type:#integer 			ui:spn_matId	default:4
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	rollout roll_global  "Global"	(
		spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits 	range:[0,1e20,0]
		spinner 	spn_profondeur		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
	)
	rollout roll_parametres  "Paramètres"	(		
		
		editText 	edTxt_nom		 	"Nom:" 	
		group "Dimensions" (
-- 			checkbox	shk_etirable			"Etirable" 	
			spinner 	spn_longueur 			"longueur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_debord				"Débord" 				type:#worldunits range:[0,1e20,0]
		)
		
-- 		fn actualiser =(
-- 			spn_longueur.indeterminate		=	etirable
-- 			spn_longueur.enabled 				=	not	etirable 
-- 		)
-- 		on roll_parametres	open 					do actualiser ()
-- 		on shk_etirable		changed state  	do actualiser ()
	)
	rollout roll_divers  "Divers"	(
		 group "Qualité" (
			checkbox	shk_lowPoly			"Low poly" 		
		) 
		group "Material ID" (
			spinner spn_matId 		"Mur" 		type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	

	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn actualiser_composants	= with redraw off (
		
	)  --- fin actualiser_composants  ------------------
	
	fn	est_ouvrant = false
	
	
	
	fn get_longueur	=	longueur
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		--- Construction ---------------------------------------------------------------------------------------
		
		
		---- points -----
		local pt_1	=	[0,					0,					0]
		local pt_2	=	[longueur,			0,					0]
		local pt_3	=	[0,					0,					hauteur]
		local pt_4	=	[longueur,			0,					hauteur]
		
		local pts 	= #(pt_1, pt_2, pt_3, pt_4)
		
		----- faces ----------------------------------------------------		
		local faces = #(	[1,2,4], [1,4,3])
	
		--- mat ID ------
		local matIDs	= for i in faces collect matId
		
		--- on creer les vertex ---------
		setMesh 	mesh 	verts:pts	faces:faces	materialIDs:matIDs
		
		----- On clean le mesh 	--------------
		meshop.autoSmooth		mesh 	#{1..mesh.numfaces} 		10
		meshop.autoEdge 		mesh 	#{1..mesh.Edges.count}	10	
		
		
		
		/* 
		----- les composants ----------------
		local composant=	if low_poly 	then	 createInstance  cp_prim_boiteU		matId:matId
													else	 createInstance  cp_prim_boite		matId:matId
		
		composant.longueur			=	longueur
		composant.profondeur		=	profondeur + debord
		composant.hauteur			=	hauteur
		
		mgr_mesh.attacher		mesh		composant 	transf:[0,-debord,0]
		 */
		
		----- le mapping 	--------------
		meshop.applyUVWMap 	mesh  #box		tm:(scaleMatrix [2,2,2]	)
		
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
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
	) --- fin tool create ---------
	
	
) ------- fin plugin ---------------------


