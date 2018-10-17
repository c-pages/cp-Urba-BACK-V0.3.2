

plugin simpleObject		menuiserie_composant_chassisVitre
name:"Chassis vitré"
classID:#(0x7bb20e92, 0x37f7c1e7)
category:"CP | Menuiserie | Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="menuiserie_composant_chassisVitre"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	----- les composants -----------	
	local compo_cadre, compo_vitrage
	
	
	parameters params_general rollout:roll_general	
	(
		----- global ----------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- cadre -------------
		cadre_largeur	 				type:#worldUnits 	ui:spn_cadre_largeur			default:0.
		travBasse_hauteur			type:#worldUnits 	ui:spn_travBasse_ht		default:0.
		
		----- vitrage -------------
		vitrage_epaisseur				type:#worldUnits 	ui:spn_vitrage_ep		default:2.
		div_montants_nbr		 				type:#integer		 	ui:spn_div_montants_nbr			default:0
		div_traverses_nbr			 				type:#integer		 	ui:spn_div_traverses_nbr			default:0
		div_largeur	 					type:#worldUnits 	ui:spn_div_largeur		default:4.
		div_profondeur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:4.
		
		----- pour rester dans valeurs corrects ------------------------
		on cadre_largeur	 			set val do corriger_parametres ()
		on longueur 					set val do corriger_parametres ()
		on hauteur 					set val do corriger_parametres ()
		on profondeur					set val do corriger_parametres ()
		on vitrage_epaisseur		set val do corriger_parametres ()
		on div_profondeur		 	set val do corriger_parametres ()
		on div_largeur			 		set val do corriger_parametres ()		
		on div_montants_nbr			 		set val do corriger_parametres ()
		on div_traverses_nbr 					set val do corriger_parametres ()
		on travBasse_hauteur		set val do corriger_parametres ()
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:true
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	rollout roll_general  "Paramètres"
	(
		group "Global" (
			spinner	 	spn_longueur 			"Longueur" 				type:#worldunits range:[0,1e20,0]
			spinner 	spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
			spinner 	spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
		)
		group "Cadre" (
			spinner 	spn_cadre_largeur	 "Largeur" 			type:#worldunits range:[0,1e20,0]
			spinner 	spn_travBasse_ht	"Trav. basse ht." 		type:#worldunits range:[0,1e20,0]
		)	
		group "Vitrage" (
			spinner 	spn_vitrage_ep		"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
		)
		group "Division" (
			spinner 	spn_div_montants_nbr	 		"Nbr. montants" 			type:#integer			range:[0,1e20,0]
			spinner		spn_div_traverses_nbr	 		"Nbr. traverses" 			type:#integer			range:[0,1e20,0]
			spinner 	spn_div_largeur		"Largeur" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_div_epaisseur	"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
		)
	)
	rollout roll_divers  "Divers"
	(
		group "Qualité" (
			checkbox	shk_lowPoly			"Low poly"
		)
		group "Material ID" (
			spinner 	spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner 	spn_matId_vitrage 	"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) ---- fin rollout	----------
	
	
	--------------- FONCTIONS  --------------------------------------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
		local longueur_passage 	= longueur  - 2* cadre_largeur
		local hauteur_passage 		= hauteur  	- ( cadre_largeur + travBasse_hauteur )
		
		if  longueur_passage < div_montants_nbr * div_largeur do 
			div_montants_nbr = longueur_passage   / div_largeur
		
		if  hauteur_passage < div_traverses_nbr * div_largeur do 
			div_traverses_nbr = hauteur_passage / div_largeur
		
		if travBasse_hauteur > hauteur - cadre_largeur	do
			travBasse_hauteur = hauteur - cadre_largeur
		if travBasse_hauteur <0	do
			travBasse_hauteur = 0
		
		if cadre_largeur > longueur / 2 do cadre_largeur = longueur / 2
		if cadre_largeur > ( hauteur - travBasse_hauteur ) do cadre_largeur = ( hauteur - travBasse_hauteur )
		if cadre_largeur < 0 do cadre_largeur = 0
		
		if vitrage_epaisseur >	profondeur	do  vitrage_epaisseur	= profondeur
		
		if div_profondeur < vitrage_epaisseur	do div_profondeur = vitrage_epaisseur	
		
		if div_profondeur > profondeur	do div_profondeur = profondeur	
		
	)
	fn actualiser_composants	= with redraw off (
	
		----- les composants ----------------
		if compo_cadre 	== undefined do compo_cadre 	= createInstance	menuiserie_composant_cadre
		if compo_vitrage	== undefined do compo_vitrage	= createInstance	menuiserie_composant_panneau
		
		-----	le cadre 	-------------
		compo_cadre.longueur				=	longueur
		compo_cadre.hauteur				=	hauteur
		compo_cadre.profondeur			=	profondeur
		compo_cadre.menuis_largeur		=	cadre_largeur
		compo_cadre.travBasse_hauteur	=	travBasse_hauteur		
		compo_cadre.matId_menuis		=	matId_menuis
		compo_cadre.low_poly				=	low_poly
		
		-----	le vitrage 	-------------
		compo_vitrage.longueur				=	longueur - 2* cadre_largeur
		compo_vitrage.hauteur					=	hauteur	-	( cadre_largeur + travBasse_hauteur )
		
		compo_vitrage.div_montants_nbr				=	div_montants_nbr
		compo_vitrage.div_traverses_nbr				=	div_traverses_nbr
		compo_vitrage.div_largeur				=	div_largeur		
		compo_vitrage.div_profondeur			=	div_profondeur		
		compo_vitrage.vitrage_epaisseur	=	vitrage_epaisseur		
		
		compo_vitrage.matId_menuis			=	matId_menuis
		compo_vitrage.matId_remplis			=	matId_vitrage
		compo_vitrage.low_poly				=	low_poly
		
	)
	
	
	
	--------------- ENVENEMENTS  ----------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre ----
		mgr_mesh.attacher		mesh		compo_cadre
		
		---- le vitrage ----
		mgr_mesh.attacher		mesh		compo_vitrage		transf:[ cadre_largeur, profondeur/2	, travBasse_hauteur]
		
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
					cadre_largeur 			= length ( gridPoint - pt_epaisseur )
					travBasse_hauteur	=	cadre_largeur
					
					---- init de quelques valeurs pour y voir quelque chose -------
					vitrage_epaisseur		=	2
					div_largeur				=	2
					div_profondeur		=	4
				)
			)		
	) --- fin tool create ---------
	
	
)	------- fin plugin ------------------------------------





