

include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Primitives\\Primitive - Boite.ms"
include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction base.ms"
	
	
	
	
plugin simpleObject		urba_menuis_fixe
name:"Fixe"
classID:#(0x4dd385d2, 0x5dd07f21)
category:"CP | Urba | menuiseries"
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuis_fix"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	--- Optionnel:	le  plug contenant la menuiserie ("ensemble" de mensuierie) pour permettre d'enregistrer les parametres du fix dans le parent.
	local m_parent
	
	local mgr_constr	=	str_contruction_base ()
	
	
	/* 
	fn initialiser	=	(
		debug "initialiser ()"
	) */
	
	
	
	
	
	
	parameters params_general rollout:roll_general
	(
		
		longueur				type:#worldUnits 	ui:spn_longueur 			default:0
		hauteur 				type:#worldUnits 	ui:spn_hauteur 			default:0
		profondeur	 		type:#worldUnits 	ui:spn_profondeur		default:0		
		epaisseur	 		type:#worldUnits 	ui:spn_epaisseur			default:0
		vitrage_ep	 		type:#worldUnits 	default:2
		
		matId_menuis		type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage		type:#integer 			ui:spn_matId_vitrage	default:2
		
		montant_G			type:#boolean 		default:true
		montant_D			type:#boolean 		default:true
		traverse_H			type:#boolean 		default:true
		
	)
	rollout roll_general  "Fixe"
	(
		
		group "Menuiserie" (
			spinner spn_longueur 		"Longueur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 		"Hauteur" 		type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 	"Profondeur" 	type:#worldunits range:[0,1e20,0]
			spinner spn_epaisseur	 	"Epaisseur" 		type:#worldunits range:[0,1e20,0]
		)
		
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage	"Vitrage" 			type:#integer range:[1,1000,1]
		)
		
		on spn_longueur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_hauteur 			changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_profondeur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_epaisseur 		changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_menuis 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		on spn_matId_vitrage 	changed val do		if m_parent != undefined do m_parent.enregistrer_params	()
		
	)
	
	

	
	
	
	
	
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
	
	
	
	
	--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	
	
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		
		
		--- la longueur des traverses------
		local long_trav	=	longueur
		if montant_G	do long_trav -= epaisseur
		if montant_D	do long_trav -= epaisseur
		
		--- la hauteur du vitrage -----
		local ht_vitrage	=	hauteur - epaisseur 
		if traverse_H	do ht_vitrage -= epaisseur 
		
		
		
		
		--- montant  gauche ----------
		if montant_G do
			mgr_constr.ajouter_boite 	mesh		long:		epaisseur		\
															prof:		profondeur		\
															ht:		hauteur			\
															matID:	matId_menuis
		
		--- montant droite ----------
		if montant_D do
			mgr_constr.ajouter_boite 	mesh		long:			epaisseur		\
															prof:			profondeur		\
															ht:			hauteur			\
															transf:		[longueur - epaisseur,0,0]	\
															matID:		matId_menuis
		
		--- traverse basse ----------
		mgr_constr.ajouter_boite 	mesh		long:			long_trav					\
														prof:			profondeur					\
														ht:			epaisseur					\
														transf:		[epaisseur,0,0]				\
														matID:		matId_menuis
							
		--- traverse	haute ----------
		if traverse_H do
			mgr_constr.ajouter_boite 	mesh		long:			long_trav				\
															prof:			profondeur									\
															ht:			epaisseur									\
															transf:		[epaisseur,0,hauteur - epaisseur]	\
															matID:		matId_menuis
		
		--- vitrage ----------
		mgr_constr.ajouter_boite 	mesh		long:			long_trav		\
														prof:			vitrage_ep							\
														ht:			ht_vitrage		\
														transf:		[epaisseur, (profondeur - vitrage_ep) / 2  , epaisseur]	\
														matID:		matId_vitrage
	
	)  ----- fin on buld mesh -----------------
	
	
	
	
	/* 
	on load 						do 	(
		initialiser ()
	)
	on clone 	_original 	do (	
		initialiser ()
	)
	on create do (
		initialiser ()
	)
	on update do	(
		initialiser ()
	)
	 */
	
	
) ----- fin plugin -------------------







	