
plugin simpleObject		menuiserie_composant_poignee
name:"Poignée"
classID:#(0x277c59b6, 0x7c0f72eb)
category:"CP | Menuiserie | Composant"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="menuiserie_composant_poignee"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	
	
	--- Prédéfinitions ------------------
	local corriger_parametres
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	--- composant ---
	local composant_boite
	
	parameters params_general 	rollout:roll_general		(
		inverser_sens		type:#boolean 		ui:shk_inverser_sens		default:false
		symetrie				type:#boolean 		ui:shk_symetrie		default:false
		
		------ options --------------
		low_poly				type:#boolean 		ui:shk_lowPoly		default:false
		matId				type:#integer 			ui:spn_matId		default:3
	)	-----	fin parametres --------------------
	
	rollout roll_general  "Cadre"
	(
		
			checkbox	shk_inverser_sens	"inverser_sens"
			checkbox	shk_symetrie			"symetrie"
			checkbox	shk_lowPoly			"Low poly"
			spinner 	spn_matId 				"MatID" 			type:#integer range:[1,1000,1]
		
	) ---- fin rollout	----------
	
	
	
	

	
	
--------------- EVENEMENTS  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
			
		local compo_base = if  low_poly then  urba_primitive_planVertical	 else urba_primitive_boite
		composant_boite =createinstance	compo_base 	matId:matId

		---- plaque	----------
		composant_boite.longueur			=	4	
		composant_boite.hauteur			=	18	
		if not low_poly  do	composant_boite.profondeur		=	0.5
		local posY = if symetrie then  posY = -.5	else 0
		
		mgr_mesh.attacher mesh composant_boite 	transf:[0, posY, 0]
		
		---- poignée part 1	----------
		composant_boite.longueur		=	if not low_poly  then	1		else 2.5
		composant_boite.hauteur		=	1
		if not low_poly  do	composant_boite.profondeur		=	2.5
		local posY = if symetrie then  posY = -3	else 0.5
		
		if not low_poly then 
			mgr_mesh.attacher mesh composant_boite 	transf:[1.5, posY, 11.5]
		else (
			local transfo	=	if not inverser_sens 	then	rotateZMatrix 	90	*	transMatrix	[2.5, posY, 11.5] 
																	else	rotateZMatrix 	90	*	transMatrix	[1.5, posY, 11.5] 
			
			mgr_mesh.attacher mesh composant_boite 	transf:transfo
			 
		)
		
		---- poignée part 2	----------
		local decalle_x = 1.5
		if	not inverser_sens then	decalle_x = -7.5		
		composant_boite.longueur			=	10
		composant_boite.hauteur			=	1
		if not low_poly  do	composant_boite.profondeur		=	1
		local posY = if symetrie then  posY = -3	else 3
		
		mgr_mesh.attacher mesh composant_boite 	transf:[ decalle_x , posY, 11.5]
		
	
	)  ----- fin on buld mesh -----------------  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	nodeTM.translation = gridPoint
						#stop
					)
			)
	) --- fin tool create ---------
	
	
	
	
)	------- fin plugin ------------------------------------










