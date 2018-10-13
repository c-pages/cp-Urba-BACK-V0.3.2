
plugin simpleObject		menuiserie_composant_cadre
name:"Cadre"
classID:#(0x191d683f, 0x345d8d04)
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
	
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -------------
		menuis_epaisseur	 			type:#worldUnits 	ui:spn_epaisseur			default:0.
		
		------ options --------------
		low_poly				type:#boolean 		ui:shk_lowPoly				default:true
		montant_G			type:#boolean 		ui:shk_montant_G		default:true
		montant_D			type:#boolean 		ui:shk_montant_D		default:true
		traverse_B			type:#boolean 		ui:shk_traverse_B		default:true
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		
		----- pour rester dans valeurs corrects ------------------------
		on menuis_epaisseur 	set val do corriger_parametres ()
		on longueur 				set val do corriger_parametres ()
		on hauteur 				set val do corriger_parametres ()
		
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Cadre"
	(
		group "Global" (
			spinner spn_longueur 			"longueur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
		)
		group "Menuiserie" (
			spinner spn_epaisseur	 		"Epaisseur" 				type:#worldunits range:[0,1e20,0]
			checkbox	shk_montant_G	"Montant gauche" 			
			checkbox	shk_montant_D	"Montant droit" 		
			checkbox	shk_traverse_B	"traverse basse" 	
		)
		group "Qualité" (
			checkbox	shk_lowPoly		"Low poly"
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
		)		
	) ---- fin rollout	----------
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
		local longueurMax	=	longueur/2
		if not montant_G	and montant_D 	or not montant_D	and montant_G do longueurMax = longueur
		local hauteurMax		= hauteur /2
		if not	traverse_B do hauteurMax =	hauteur
		
		if montant_G	or  montant_D 	do
			if menuis_epaisseur >longueurMax do menuis_epaisseur = longueurMax
		if menuis_epaisseur >hauteurMax do menuis_epaisseur = hauteurMax
	)
	
	----  construction du mesh	-------------------
	fn transformer_mesh		_mesh		_transf	=(
		if classof _transf == point3 do _transf = transMatrix _transf
		local transf_tab =#()
		for id_pt = 1 to   _mesh.numverts  do (
			local pos_base 	=  meshop.getVert  _mesh 	id_pt
			local pos_dest 	= pos_base * _transf
			append transf_tab ( pos_dest - pos_base)
		)
		meshop.moveVert 	_mesh	#{1.._mesh.numverts} transf_tab
	)
	fn attacher_composant			_composant		_transf	=(
		local compo_mesh	=	copy _composant.mesh
		transformer_mesh		compo_mesh		_transf
		meshop.attach		mesh		compo_mesh
	)
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		--- la longueur des traverses------
		local posX_traverses	=	0
		local long_trav	=	longueur
		if montant_G	do (
			long_trav 			-= menuis_epaisseur
			posX_traverses 	+= menuis_epaisseur
		)
		if montant_D	do long_trav -= menuis_epaisseur
		
		
		----- les composants ----------------
		local composant
		if low_poly 	then	composant = createInstance  urba_primitive_boite_L		matId:matId_menuis
						else	composant = createInstance  urba_primitive_boite		matId:matId_menuis
		
		--- montant  gauche ----------
		if montant_G do (
			composant.longueur			=	menuis_epaisseur
			composant.profondeur		=	profondeur
			composant.hauteur			=	hauteur
			
			meshop.attach		mesh		composant.mesh
		)
		
		--- montant droite ----------
		if montant_D do (
			composant.longueur			=	menuis_epaisseur
			composant.profondeur		=	profondeur
			composant.hauteur			=	hauteur
			composant.symetrie			=	true
			
			attacher_composant 	composant		[longueur - menuis_epaisseur,0,0]				
		)
		
		--- traverse basse ----------
		if traverse_B do (			
			composant.longueur			=	long_trav
			composant.profondeur		=	profondeur
			composant.hauteur			=	menuis_epaisseur
			composant.symetrie			=	false
			composant.horizontal		=	true
			
			attacher_composant 	composant	[posX_traverses,0,0]				
		)
		
		--- traverse	haute ----------
		composant.longueur			=	long_trav
		composant.profondeur		=	profondeur
		composant.hauteur			=	menuis_epaisseur
		composant.symetrie			=	true
		composant.horizontal		=	true
		
		attacher_composant 	composant	[posX_traverses,0,hauteur - menuis_epaisseur]
		
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
				5: menuis_epaisseur 	= length ( gridPoint - pt_epaisseur )
			)		
	) --- fin tool create ---------
	
	
	
	
)