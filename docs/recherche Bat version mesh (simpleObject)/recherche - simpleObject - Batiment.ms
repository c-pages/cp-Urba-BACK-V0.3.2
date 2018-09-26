
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\mgr - presets.ms"

include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Ensemble.ms"

include	 "$userScripts\\cp-Urba\\modules\\Commun\\Urba - Shapes.ms"

plugin simpleObject 	urba_batiment_temp
name:"Bâtiment"
classID:#(0x3b4d5bbe, 0x5e541a1)
category:"CP | Urba | Bâtiment"
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_batiment_temp"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	
	-----------------    VARIABLES ----------------------------------------------------------------------------------------------------------------------
	local mgr_presets 	=	str_presets_manager ()
	local mgr_shapes		= 	str_outils_shape ()
	
	
	

	
	
	
	
	
	
	
	------------ PARAMETRES	----------------------------------------------------------------------------------------------------------------------
	parameters param_transformation		(
		transformation	type:#matrix3	default:(matrix3 1)
	)
	
	parameters params_general 						rollout:roll_general		(
	
		------- Etages			------------------
		etages_nbre					type: #integer			default:1			 ui:spn_nbres	 		animatable:false		invisibleInTV:true
		etages_hauteur_global		type: #float 			default:250.		 ui:spn_hauteur	 	animatable:false		invisibleInTV:true
		/* 
		---- les etages spécifiques -----------
		etages_min					type:#intTab 				tabSize:0  		tabSizeVariable:true
		etages_max_use			type:#boolTab	 		tabSize:0  		tabSizeVariable:true
		etages_max				type:#intTab		 		tabSize:0  		tabSizeVariable:true
		etages_hauteurs			type:#floatTab	 		tabSize:0  		tabSizeVariable:true
		
		---- Divers --------
		decallage_z					type:#float	 			default:0.		ui:spn_decallageZ	animatable:false		invisibleInTV:true
		
		
		interieur_use			type:#boolean			default:false	 	ui:chk_interieur	 	animatable:false		invisibleInTV:true
			
			
		*/
	)
	parameters params_surface				rollout:roll_surface	(
		
		------- Surface		------------------
		surface_node					type:#node 								 	ui:btn_pick_surface		animatable:false		invisibleInTV:true
		surface_points					type:#point3Tab 			tabSize:0  		tabSizeVariable:true
		
		------- Optimisations		------------------
		optim_aplanir					type:#boolean			default:true		ui:chk_aplanir				animatable:false		invisibleInTV:true
		optim_souder					type:#boolean			default:true		ui:chk_souder				animatable:false		invisibleInTV:true
		optim_orthonormer			type:#boolean			default:false		ui:chk_ortho				animatable:false		invisibleInTV:true
		optim_aligner					type:#boolean			default:false		ui:chk_aligner				animatable:false		invisibleInTV:true
		optim_projeter					type:#boolean			default:false		ui:chk_projeter			animatable:false		invisibleInTV:true
		
		------- Seuils		------------------
		optim_aplanir_seuil			type:#float				default:20.			ui:spn_aplanir				animatable:false		invisibleInTV:true
		optim_souder_seuil			type:#float				default:30.			ui:spn_souder				animatable:false		invisibleInTV:true
		optim_ortho_seuil				type:#float				default:100.		ui:spn_ortho				animatable:false		invisibleInTV:true
		optim_aligner_seuil			type:#float				default:50.			ui:spn_aligner				animatable:false		invisibleInTV:true
		
	)
	
	
	
	
	
	
	
	--- Aquisition shape ---------------------
		fn scanner_shape 	_shape	=(
			
			surface_points				=#()
			
			---- On chope les points de la surface a scanner -----------
			for id_pt = 1 to ( numKnots 	_shape 	1 ) do	(
				local pt_shape 	= getKnotPoint 	_shape 	1 	id_pt
				local pt_surface 	= pt_shape * inverse  _shape.transform
				append surface_points 	 pt_surface
			)
			
			
			--- on fait tourner les spline dans le meme sens ----
			if not mgr_shapes.est_sensPositif 	surface_points 	 do
				surface_points = mgr_shapes.changer_sens		surface_points
			
			debug "surface_points" var:surface_points
			
			surface_points
			
		)
		
	
	
	
	
	
	
	
	
	
	
	
	
	------------ ROLLOUT	----------------------------------------------------------------------------------------------------------------------
	rollout roll_surface "Surface"	(

		fn shape_filt 		obj = superclassof obj == shape

		--- Surface ------
		pickbutton 'btn_pick_surface' "Pick shape"  filter:shape_filt toolTip:"Le shape à utiliser comme surface de base pour la création du bâtiment." autoDisplay:true align:#center  width:150
		
		checkbox 'chk_aplanir' "Aplanir"  align:#left across:2
		spinner 'spn_aplanir' "" range:[0,100,0] type:#float  align:#right width:60
		
		checkbox 'chk_ortho' "Orthonormer"  align:#left across:2
		spinner 'spn_ortho' "" range:[0,100,0] type:#float  align:#right width:60
		
		checkbox 'chk_souder' "Souder"  align:#left across:2
		spinner 'spn_souder' ""  type:#worldunits align:#right width:60

		checkbox 'chk_aligner' "Aligner"  align:#left across:2
		spinner 'spn_aligner' "" range:[0,100,0] align:#right width:60
		
		checkbox 'chk_projeter' "Projeter"  align:#left
		
		
		on btn_pick_surface picked _shape do
			scanner_shape _shape
	
	
	
	)
	rollout roll_general "Général" 	(
		
		
		--- Global ------
		Group  "Etages :" (
			spinner 'spn_nbres' "Nombre"  range:[0,1e+13,0] type:#integer scale:1 align:#right
			spinner 'spn_hauteur' "Hauteur" range:[0,1e+13,0] type:#worldunits scale:1 align:#right
		)
		/* 
		--- etages specifiques -----------
		Group		 "Etages spécifiques"  (
			button 'btn_etages_nouveau' "Nouv."  toolTip:"Ajouter	étages spécifiques" align:#right
			button 'btn_etages_supprimer' "Sup."  toolTip:"Supprimer étages spécifiques" align:#right	
		)
		
		
		listbox 'lbx_etages_specifiques' "" pos:[17,81] width:135 height:4 align:#right
		
		label 'lbl_etage_specifiques' "Etages :" pos:[17,139] width:45 height:19 align:#right
		spinner 'spn_etageMin_specifiques' "" pos:[63,142] width:40 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#right
		label 'lbl_hauteur_specifiques' "Hauteur :" pos:[17,157] width:55 height:22 align:#right
		spinner 'spn_etageMax_specifiques' "" pos:[115,142] width:40 height:16 range:[0,1e+13,0] type:#integer align:#right
		checkbutton 'ckb_etageMax_specifiques' ">" pos:[100,141] width:16 height:16 align:#right
		spinner 'spn_hauteur_specifiques' "" pos:[63,158] width:92 height:16 range:[0,1e+13,0] type:#worldunits align:#right
		 */
		/* 
		---- Divers ------
		GroupBox 'grp_divers' "Divers" pos:[4,200] width:160 height:60 align:#right
		label 'lbl_decallageZ' "Décallage (Z):" pos:[17,217] width:92 height:18 align:#right
		spinner 'spn_decallageZ' "" pos:[86,217] width:72 height:16 range:[-1e+13,1e+13,0] type:#worldunits scale:1 align:#right
		checkbox 'chk_interieur' "Cloisons intèrieures" pos:[16,236] width:141 height:16 align:#right
		
		
		checkbox 'ckb_proxy' "Affichage simplifié" pos:[4,262] width:161 height:19 align:#right
		 */
		
	)
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create	(
		on mousePoint click do ( 
			nodeTM.translation = gridPoint
			#stop
		)
	) --- fin tool create	---------------------------
	
	
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do
	(
		---- on vide le mesh -----------
-- 		delete mesh
		
	) --- fin buildMesh	---------------------------
	
) -----------	fin plugin --------------------















